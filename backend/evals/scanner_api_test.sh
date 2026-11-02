#!/usr/bin/env bash
# Scanner app API checks (evals/harness/scanner_api.php) on the eval sandbox server — never production.
# Copies this worktree's app/ to $EVX_REMOTE/app_scanapi, gives it its own database (evx_scan, built from
# harness/schema.sql), serves it with `php -S` on 127.0.0.1 (8 workers, so parallel requests really run
# at once), runs the checks, then stops the server and removes the copy.
#
#   EVX_KEY=/path/to/ssh/key EVX_HOST=user@eval-server [EVX_REMOTE=/home/user/evx_eval] bash evals/scanner_api_test.sh
# The server needs the eval sandbox from evals/evx.py setup (private MySQL on /tmp/evx_mysql).
set -euo pipefail
export MSYS_NO_PATHCONV=1
HERE="$(cd "$(dirname "$0")" && pwd)"
KEY="${EVX_KEY:?set EVX_KEY to the SSH key for the eval server}"
HOST="${EVX_HOST:?set EVX_HOST to user@eval-server}"
REMOTE="${EVX_REMOTE:-~/evx_eval}"   # ~ is expanded by the server's shell
SOCK=/tmp/evx_mysql/run/mysqld.sock
PORT="${EVX_PORT:-8765}"
ssh_() { ssh -i "$KEY" -o BatchMode=yes "$HOST" "$@"; }

tar -C "$HERE/.." -czf - --exclude=app/vendor --exclude=app/qr_invitations --exclude=app/logs --exclude=app/graphify-out \
    app evals/harness/scanner_api.php evals/harness/schema.sql \
  | ssh_ "rm -rf $REMOTE/app_scanapi $REMOTE/scanapi && mkdir -p $REMOTE/scanapi && tar -C $REMOTE/scanapi -xzf - \
          && mv $REMOTE/scanapi/app $REMOTE/app_scanapi && mkdir -p $REMOTE/app_scanapi/logs && cp $REMOTE/app/.env $REMOTE/app_scanapi/.env"

ssh_ "set -e
[ -S $SOCK ] || { echo 'sandbox mysqld is not running: python evals/evx.py setup'; exit 1; }
for f in \$(find $REMOTE/app_scanapi/api/scanner $REMOTE/app_scanapi/includes/scanner_api.php $REMOTE/app_scanapi/includes/rate_limit.php $REMOTE/app_scanapi/includes/auth.php $REMOTE/app_scanapi/config/config.php -name '*.php'); do php -l \$f >/dev/null; done
mysql --socket=$SOCK -uroot -e 'DROP DATABASE IF EXISTS evx_scan; CREATE DATABASE evx_scan CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'
mysql --socket=$SOCK -uroot evx_scan < $REMOTE/scanapi/evals/harness/schema.sql
mysql --socket=$SOCK -uroot evx_scan < $REMOTE/app_scanapi/db_migrations/030_scanner_api.sql   # applied twice: must be harmless
cd $REMOTE/app_scanapi
DB_HOST='localhost;unix_socket=$SOCK' DB_NAME=evx_scan DB_USER=evx DB_PASS=evx APP_ENV=local BASE_URL=http://127.0.0.1:$PORT/ \
  PHP_CLI_SERVER_WORKERS=8 nohup php -S 127.0.0.1:$PORT -t $REMOTE/app_scanapi > $REMOTE/scanapi/server.log 2>&1 < /dev/null &
echo \$! > $REMOTE/scanapi/server.pid
sleep 1
rc=0
php $REMOTE/scanapi/evals/harness/scanner_api.php --db=evx_scan --url=http://127.0.0.1:$PORT --socket=$SOCK || rc=\$?
PID=\$(cat $REMOTE/scanapi/server.pid)
pkill -P \$PID 2>/dev/null || true   # the workers (never pkill -f: this shell's own command line matches)
kill \$PID 2>/dev/null || true
grep -i -E 'fatal|warning|error' $REMOTE/app_scanapi/logs/php_errors.log $REMOTE/scanapi/server.log 2>/dev/null | grep -v -E 'Accepted|Closing|\[200\]' | tail -20 || true
mysql --socket=$SOCK -uroot -e 'DROP DATABASE IF EXISTS evx_scan'
rm -rf $REMOTE/app_scanapi $REMOTE/scanapi
exit \$rc"
