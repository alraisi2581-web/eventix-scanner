<?php
/**
 * Checks for the scanner app's API (app/api/scanner/*.php) as real HTTP requests: a sandbox copy of
 * the app served by `php -S` (with several workers, so parallel requests really run at once) against
 * a private eval database — never production. Run by evals/scanner_api_test.sh.
 *
 *   php scanner_api.php --db=evx_scan --url=http://127.0.0.1:8765 [--socket=/tmp/evx_mysql/run/mysqld.sock]
 *
 * Prints one line per check and exits non-zero if any check fails.
 */

declare(strict_types=1);

$opt    = getopt('', ['db:', 'url:', 'socket::']);
$URL    = rtrim($opt['url'] ?? 'http://127.0.0.1:8765', '/');
$socket = $opt['socket'] ?? '/tmp/evx_mysql/run/mysqld.sock';
$pdo    = new PDO("mysql:unix_socket={$socket};dbname=" . ($opt['db'] ?? 'evx_scan') . ';charset=utf8mb4', 'evx', 'evx', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET time_zone = '+04:00'",
]);
date_default_timezone_set('Asia/Muscat');

$fails = 0;
function check(string $name, bool $ok, string $detail = ''): void {
    global $fails;
    if (!$ok) $fails++;
    echo ($ok ? 'PASS ' : 'FAIL ') . $name . ($detail !== '' && !$ok ? "  — {$detail}" : '') . "\n";
}
function q(string $sql, array $p = []): PDOStatement { global $pdo; $s = $pdo->prepare($sql); $s->execute($p); return $s; }
function id(string $sql, array $p = []): int { global $pdo; q($sql, $p); return (int)$pdo->lastInsertId(); }

/** One request: [status, decoded body, lower-cased headers]. */
function req(string $method, string $path, ?array $json = null, ?string $token = null): array {
    return multi([[$method, $path, $json, $token]])[0];
}
/** Several requests sent at the same moment (curl_multi). */
function multi(array $reqs): array {
    global $URL;
    $mh = curl_multi_init();
    $hs = [];
    foreach ($reqs as $i => [$method, $path, $json, $token]) {
        $ch = curl_init($URL . '/' . ltrim($path, '/'));
        $hdr = ['Accept: application/json'];
        if ($token !== null) $hdr[] = 'Authorization: Bearer ' . $token;
        if ($json !== null) $hdr[] = 'Content-Type: application/json';
        $headers = [];
        curl_setopt_array($ch, [
            CURLOPT_CUSTOMREQUEST => $method, CURLOPT_RETURNTRANSFER => true, CURLOPT_HTTPHEADER => $hdr,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_HEADERFUNCTION => function ($c, $line) use (&$headers, $i) {
                if (str_contains($line, ':')) { [$k, $v] = explode(':', $line, 2); $headers[$i][strtolower(trim($k))] = trim($v); }
                return strlen($line);
            },
        ]);
        if ($json !== null) curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($json));
        curl_multi_add_handle($mh, $ch);
        $hs[$i] = $ch;
    }
    do { curl_multi_exec($mh, $running); curl_multi_select($mh); } while ($running > 0);
    $out = [];
    foreach ($hs as $i => $ch) {
        $body = curl_multi_getcontent($ch);
        $out[$i] = [curl_getinfo($ch, CURLINFO_HTTP_CODE), json_decode((string)$body, true), $headers[$i] ?? [], (string)$body];
        curl_multi_remove_handle($mh, $ch);
    }
    curl_multi_close($mh);
    return $out;
}
function uuid(): string {
    $b = random_bytes(16);
    $b[6] = chr(ord($b[6]) & 0x0f | 0x40);
    $b[8] = chr(ord($b[8]) & 0x3f | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($b), 4));
}
function login(string $user, string $pw, string $device = 'Test phone'): array {
    return req('POST', 'api/scanner/login.php', ['username' => $user, 'password' => $pw, 'device_name' => $device]);
}
function upload(string $token, array $items): array { return req('POST', 'api/scanner/checkins.php', ['checkins' => $items], $token); }
function guest_row(int $id): array { return q("SELECT checkin_status, checkin_time FROM guests WHERE id = ?", [$id])->fetch(); }

// ── Fixtures ───────────────────────────────────────────────────────────────────
$pdo->exec('SET FOREIGN_KEY_CHECKS=0');
foreach ($pdo->query("SHOW FULL TABLES WHERE Table_type='BASE TABLE'")->fetchAll(PDO::FETCH_NUM) as $r) $pdo->exec('TRUNCATE TABLE `' . $r[0] . '`');
$pdo->exec('SET FOREIGN_KEY_CHECKS=1');
foreach (glob(sys_get_temp_dir() . '/eventix_rate_*') ?: [] as $f) if (fileowner($f) === getmyuid()) @unlink($f);

$PW = 'correct horse battery';
$mkUser = fn(string $name, string $role, int $all = 0, int $temp = 0) =>
    id("INSERT INTO users (username, password_hash, role, has_all_events_access, must_change_password) VALUES (?, ?, ?, ?, ?)",
       [$name, password_hash($PW, PASSWORD_DEFAULT), $role, $all, $temp]);
$admin = $mkUser('t_admin', 'admin', 1);
$scanA = $mkUser('t_scanner_a', 'scanner');
$scanB = $mkUser('t_scanner_b', 'scanner');
$scanC = $mkUser('t_scanner_c', 'scanner');       // no events
$scanD = $mkUser('t_scanner_d', 'scanner');       // locked out by wrong passwords
$inviter = $mkUser('t_inviter', 'inviter');
$temp  = $mkUser('t_scanner_temp', 'scanner', 0, 1);

$mkEvent = fn(string $title, ?string $tz, string $status = 'active') =>
    id("INSERT INTO events (title_en, title_ar, venue_en, venue_ar, maps_link, start_time, timezone, status) VALUES (?, ?, 'Hall', 'القاعة', '', '2026-11-23 16:00:00', ?, ?)",
       [$title, $title . ' ع', $tz, $status]);
$e1 = $mkEvent('London reception', 'Europe/London');
$e2 = $mkEvent('Muscat dinner', null);
$e3 = $mkEvent('Old archived', null, 'archived');
foreach ([$scanA, $scanB, $inviter, $temp] as $u) q("INSERT INTO user_event_permissions (user_id, event_id) VALUES (?, ?)", [$u, $e1]);
q("INSERT INTO user_event_permissions (user_id, event_id) VALUES (?, ?)", [$scanA, $e3]);

$tokens = [];
$mkGuest = function (int $eid, string $name, int $demo = 0) use (&$tokens): int {
    $tok = bin2hex(random_bytes(32));
    $gid = id("INSERT INTO guests (event_id, name_en, name_ar, phone, language, token, email, table_number, is_demo, rsvp) VALUES (?, ?, ?, '96890000001', 'en', ?, 'private@example.com', '7', ?, 'Attending')",
              [$eid, $name, $name . ' ع', $tok, $demo]);
    $tokens[$gid] = $tok;
    return $gid;
};
$g = [];
for ($i = 1; $i <= 60; $i++) $g[$i] = $mkGuest($e1, sprintf('Guest %02d', $i));
$demo = $mkGuest($e1, 'Demo guest', 1);
$other = $mkGuest($e2, 'Muscat guest');
q("UPDATE guests SET checkin_status = 'Scanned', checkin_time = '2026-11-23 15:55:00' WHERE id = ?", [$g[60]]);   // checked in on the web

// ── Sign-in ────────────────────────────────────────────────────────────────────
[$s, $b, $h] = login('t_scanner_a', $PW);
check('login: scanner gets a 64-hex bearer token', $s === 200 && preg_match('/^[a-f0-9]{64}$/', $b['token'] ?? '') === 1, json_encode($b));
check('login: user and expiry returned', ($b['user']['username'] ?? '') === 't_scanner_a' && ($b['user']['role'] ?? '') === 'scanner' && str_contains($b['expires_at'] ?? '', '+04:00'), json_encode($b));
check('login: no session cookie is set', !isset($h['set-cookie']), $h['set-cookie'] ?? '');
check('login: response is never cached (X-Accel-Expires: 0, no-store)', ($h['x-accel-expires'] ?? '') === '0' && ($h['cache-control'] ?? '') === 'no-store');
$tA = $b['token'];
$row = q("SELECT token_hash, device_name, expires_at FROM api_tokens WHERE user_id = ?", [$scanA])->fetch();
check('login: only the SHA-256 of the token is stored, with the device name', $row && $row['token_hash'] === hash('sha256', $tA) && $row['device_name'] === 'Test phone');
check('login: token lasts 14 days', abs(strtotime($row['expires_at']) - (time() + 14 * 86400)) < 60);
$tB = login('t_scanner_b', $PW)[1]['token'] ?? '';
$tC = login('t_scanner_c', $PW)[1]['token'] ?? '';
$tAdmin = login('t_admin', $PW)[1]['token'] ?? '';

[$s, $b] = login('t_scanner_a', 'wrong password');
check('login: wrong password → 401 invalid_credentials', $s === 401 && ($b['error']['code'] ?? '') === 'invalid_credentials', json_encode($b));
[$s, $b] = login('nobody_here', $PW);
check('login: unknown user → the same 401', $s === 401 && ($b['error']['code'] ?? '') === 'invalid_credentials');
[$s, $b] = login('t_inviter', $PW);
check('login: inviter → 403 role_not_allowed', $s === 403 && ($b['error']['code'] ?? '') === 'role_not_allowed', json_encode($b));
[$s, $b] = login('t_scanner_temp', $PW);
check('login: temporary password → 403 password_change_required', $s === 403 && ($b['error']['code'] ?? '') === 'password_change_required', json_encode($b));
[$s, $b] = req('POST', 'api/scanner/login.php', ['username' => 't_scanner_a']);
check('login: missing password → 400', $s === 400 && ($b['error']['code'] ?? '') === 'invalid_request');
[$s, , , $raw] = req('POST', 'api/scanner/login.php', null);
check('login: no JSON body → 400', $s === 400, $raw);
[$s] = req('GET', 'api/scanner/login.php');
check('login: GET → 405', $s === 405);
for ($i = 0; $i < 10; $i++) login('t_scanner_d', 'nope');
[$s, $b] = login('t_scanner_d', $PW);
check('login: 10 wrong passwords lock that username for 30 min, even with the right one', $s === 429 && ($b['error']['code'] ?? '') === 'too_many_attempts', json_encode($b));
check('login: the lock-out is per username — others on the same Wi-Fi still sign in', login('t_scanner_b', $PW, 'second')[0] === 200);

// ── Events ─────────────────────────────────────────────────────────────────────
[$s, $b] = req('GET', 'api/scanner/events.php');
check('events: no token → 401 unauthenticated', $s === 401 && ($b['error']['code'] ?? '') === 'unauthenticated');
[$s, $b] = req('GET', 'api/scanner/events.php', null, str_repeat('a', 64));
check('events: unknown token → 401 token_invalid', $s === 401 && ($b['error']['code'] ?? '') === 'token_invalid');
[$s, $b, $h] = req('GET', 'api/scanner/events.php', null, $tA);
$ids = array_column($b['events'] ?? [], 'id');
check('events: scanner sees only their event, not archived ones', $s === 200 && $ids === [$e1], json_encode($ids));
check('events: no cookie, never cached', !isset($h['set-cookie']) && ($h['x-accel-expires'] ?? '') === '0');
$ev = $b['events'][0] ?? [];
check('events: counts leave out demo guests', ($ev['guest_count'] ?? 0) === 60 && ($ev['checked_in_count'] ?? 0) === 1, json_encode($ev));
check('events: start time as ISO with offset + label in the event zone', ($ev['starts_at'] ?? '') === '2026-11-23T16:00:00+04:00'
      && str_contains($ev['starts_label'] ?? '', '12:00 pm (London time)') && ($ev['timezone'] ?? '') === 'Europe/London', json_encode($ev));
check('events: scanner with no events gets an empty list', (req('GET', 'api/scanner/events.php', null, $tC)[1]['events'] ?? null) === []);
$adminIds = array_column(req('GET', 'api/scanner/events.php', null, $tAdmin)[1]['events'] ?? [], 'id');
sort($adminIds);
check('events: admin sees every active event', $adminIds === [$e1, $e2], json_encode($adminIds));

// ── Guest list ─────────────────────────────────────────────────────────────────
[$s, $b] = req('GET', "api/scanner/guests.php?event_id={$e1}", null, $tA);
$list = $b['guests'] ?? [];
check('guests: 60 guests, demo guest left out', $s === 200 && count($list) === 60 && !in_array($demo, array_column($list, 'id'), true), (string)count($list));
$first = $list[0] ?? [];
check('guests: QR token only as its SHA-256', ($first['token_sha256'] ?? '') === hash('sha256', $tokens[$first['id'] ?? 0] ?? '') && !str_contains(json_encode($b), $tokens[$g[1]]));
check('guests: no phone numbers or emails', !str_contains(json_encode($b), '96890000001') && !str_contains(json_encode($b), 'private@example.com'));
check('guests: fields for the door', ($first['name_ar'] ?? '') !== '' && ($first['rsvp'] ?? '') === 'Attending' && ($first['table_number'] ?? '') === '7' && ($first['checked_in'] ?? null) === false);
$web = array_values(array_filter($list, fn($x) => $x['id'] === $g[60]))[0] ?? [];
check('guests: a web check-in shows, time in the event zone', ($web['checked_in'] ?? false) === true && ($web['checked_in_at'] ?? '') === '2026-11-23T15:55:00+04:00' && ($web['checked_in_label'] ?? '') === '11:55 am (London time)', json_encode($web));
check('guests: other users\' event → 403', req('GET', "api/scanner/guests.php?event_id={$e2}", null, $tA)[0] === 403);
check('guests: unknown event → 404', req('GET', 'api/scanner/guests.php?event_id=99999', null, $tA)[0] === 404);
check('guests: no event id → 400', req('GET', 'api/scanner/guests.php', null, $tA)[0] === 400);
check('guests: admin may load any event', req('GET', "api/scanner/guests.php?event_id={$e2}", null, $tAdmin)[0] === 200);

// ── Check-ins ──────────────────────────────────────────────────────────────────
$c1 = uuid();
$scanTime = (new DateTimeImmutable('-2 minutes', new DateTimeZone('UTC')))->format(DATE_ATOM);
[$s, $b] = upload($tA, [['client_id' => $c1, 'guest_id' => $g[1], 'scanned_at' => $scanTime]]);
$r = $b['results'][0] ?? [];
check('checkins: first check-in → checked_in', $s === 200 && ($r['status'] ?? '') === 'checked_in' && ($r['client_id'] ?? '') === $c1, json_encode($b));
$gr = guest_row($g[1]);
check('checkins: the guest is checked in on the server (as the web scanner does it)', $gr['checkin_status'] === 'Scanned' && $gr['checkin_time'] !== null);
check('checkins: label in the event zone', str_ends_with($r['checked_in_label'] ?? '', '(London time)'), $r['checked_in_label'] ?? '');
$sc = q("SELECT user_id, scanned_at, outcome FROM scanner_checkins WHERE client_id = ?", [$c1])->fetch();
check('checkins: recorded with the phone\'s scan time (in Muscat time)', $sc && (int)$sc['user_id'] === $scanA && $sc['outcome'] === 'checked_in'
      && $sc['scanned_at'] === (new DateTimeImmutable($scanTime))->setTimezone(new DateTimeZone('Asia/Muscat'))->format('Y-m-d H:i:s'), json_encode($sc));
$au = q("SELECT user_id, action_type FROM audit_logs WHERE guest_id = ?", [$g[1]])->fetchAll();
check('checkins: audit log names the scanner (app_checkin)', count($au) === 1 && (int)$au[0]['user_id'] === $scanA && $au[0]['action_type'] === 'app_checkin', json_encode($au));

[$s, $b] = upload($tA, [['client_id' => $c1, 'guest_id' => $g[1], 'scanned_at' => $scanTime]]);
$r2 = $b['results'][0] ?? [];
check('checkins: the same client_id again (lost reply) → same answer, replayed', ($r2['status'] ?? '') === 'checked_in' && ($r2['replayed'] ?? false) === true && ($r2['checked_in_at'] ?? '') === ($r['checked_in_at'] ?? 'x'), json_encode($b));
check('checkins: … and nothing is written twice', (int)q("SELECT COUNT(*) FROM scanner_checkins WHERE guest_id = ?", [$g[1]])->fetchColumn() === 1
      && (int)q("SELECT COUNT(*) FROM audit_logs WHERE guest_id = ?", [$g[1]])->fetchColumn() === 1);

[$s, $b] = upload($tB, [['client_id' => uuid(), 'guest_id' => $g[1], 'scanned_at' => $scanTime]]);
$r3 = $b['results'][0] ?? [];
check('checkins: second phone, same guest → already_checked_in with the first time', ($r3['status'] ?? '') === 'already_checked_in' && ($r3['checked_in_at'] ?? '') === ($r['checked_in_at'] ?? 'x'), json_encode($b));
check('checkins: the first check-in time is kept', guest_row($g[1])['checkin_time'] === $gr['checkin_time']);
check('checkins: answer does not say who checked them in', !array_key_exists('checked_in_by', $r3));
[, $b] = upload($tB, [['client_id' => uuid(), 'guest_id' => $g[60]]]);
check('checkins: a guest checked in on the web → already_checked_in', ($b['results'][0]['status'] ?? '') === 'already_checked_in' && ($b['results'][0]['checked_in_label'] ?? '') === '11:55 am (London time)', json_encode($b));

[, $b] = upload($tA, [['client_id' => $c1, 'guest_id' => $g[2]]]);
check('checkins: a used client_id for another guest → invalid, nothing changed', ($b['results'][0]['status'] ?? '') === 'invalid' && guest_row($g[2])['checkin_status'] === 'Not Scanned', json_encode($b));
[, $b] = upload($tB, [['client_id' => $c1, 'guest_id' => $g[1]]]);
check('checkins: another user\'s client_id → invalid', ($b['results'][0]['status'] ?? '') === 'invalid', json_encode($b));
[, $b] = upload($tC, [['client_id' => uuid(), 'guest_id' => $g[3]]]);
check('checkins: guest of an event the user can\'t access → forbidden, not checked in', ($b['results'][0]['status'] ?? '') === 'forbidden' && guest_row($g[3])['checkin_status'] === 'Not Scanned', json_encode($b));
[, $b] = upload($tA, [['client_id' => uuid(), 'guest_id' => $demo], ['client_id' => uuid(), 'guest_id' => 999999]]);
check('checkins: demo guest and unknown guest → not_found', ($b['results'][0]['status'] ?? '') === 'not_found' && ($b['results'][1]['status'] ?? '') === 'not_found', json_encode($b));
[, $b] = upload($tA, [['client_id' => 'not-a-uuid', 'guest_id' => $g[4]], ['guest_id' => $g[4]], ['client_id' => uuid(), 'guest_id' => 'x'], 'junk']);
check('checkins: malformed items → invalid each, the rest still answered', array_column($b['results'] ?? [], 'status') === ['invalid', 'invalid', 'invalid', 'invalid'] && guest_row($g[4])['checkin_status'] === 'Not Scanned', json_encode($b));
[, $b] = upload($tA, [['client_id' => uuid(), 'guest_id' => $g[5], 'scanned_at' => '2001-01-01T00:00:00Z']]);
$bad = q("SELECT scanned_at FROM scanner_checkins WHERE guest_id = ?", [$g[5]])->fetchColumn();
check('checkins: a phone clock far off → checked in, scan time not recorded', ($b['results'][0]['status'] ?? '') === 'checked_in' && $bad === null, json_encode($b));
check('checkins: empty upload → 400', upload($tA, [])[0] === 400);
check('checkins: more than 100 → 400', upload($tA, array_fill(0, 101, ['client_id' => uuid(), 'guest_id' => $g[6]]))[0] === 400);
check('checkins: no token → 401', req('POST', 'api/scanner/checkins.php', ['checkins' => [['client_id' => uuid(), 'guest_id' => $g[6]]]])[0] === 401);

// offline queue: one upload of many, in order
$batch = [];
for ($i = 10; $i < 40; $i++) $batch[] = ['client_id' => uuid(), 'guest_id' => $g[$i], 'scanned_at' => $scanTime];
$batch[] = ['client_id' => uuid(), 'guest_id' => $g[1]];
[$s, $b] = upload($tA, $batch);
$st = array_column($b['results'] ?? [], 'status');
check('checkins: an offline batch of 31 → answered in order', $s === 200 && count($st) === 31 && array_column($b['results'], 'client_id') === array_column($batch, 'client_id'));
check('checkins: … 30 checked in, the one already in → already_checked_in', count(array_keys($st, 'checked_in')) === 30 && end($st) === 'already_checked_in');
[, $b] = upload($tA, $batch);
check('checkins: the whole batch resent → all replayed, nothing new', count(array_filter($b['results'] ?? [], fn($x) => !empty($x['replayed']))) === 31
      && (int)q("SELECT COUNT(*) FROM scanner_checkins WHERE event_id = ?", [$e1])->fetchColumn() === 1 + 1 + 1 + 1 + 31, (string)q("SELECT COUNT(*) FROM scanner_checkins")->fetchColumn());

// ── Races: requests that really run at the same time ───────────────────────────
$par = [];
for ($i = 0; $i < 16; $i++) $par[] = ['POST', 'api/scanner/checkins.php', ['checkins' => [['client_id' => uuid(), 'guest_id' => $g[50]]]], $i % 2 ? $tA : $tB];
$res = multi($par);
$outs = array_map(fn($x) => $x[1]['results'][0]['status'] ?? ('HTTP ' . $x[0]), $res);
$times = array_unique(array_map(fn($x) => $x[1]['results'][0]['checked_in_at'] ?? '', $res));
check('race: 16 phones check in one guest at once → exactly one checked_in', count(array_keys($outs, 'checked_in')) === 1 && count(array_keys($outs, 'already_checked_in')) === 15, json_encode(array_count_values($outs)));
check('race: … and all 16 are told the same check-in time', count($times) === 1);
check('race: … one audit line, 16 upload records', (int)q("SELECT COUNT(*) FROM audit_logs WHERE guest_id = ?", [$g[50]])->fetchColumn() === 1
      && (int)q("SELECT COUNT(*) FROM scanner_checkins WHERE guest_id = ?", [$g[50]])->fetchColumn() === 16);
$same = uuid();
$res = multi(array_fill(0, 12, ['POST', 'api/scanner/checkins.php', ['checkins' => [['client_id' => $same, 'guest_id' => $g[51]]]], $tA]));
$outs = array_map(fn($x) => ($x[1]['results'][0]['status'] ?? ('HTTP ' . $x[0])) . (!empty($x[1]['results'][0]['replayed']) ? '+replayed' : ''), $res);
check('race: the same upload sent 12 times at once → one check-in, 11 replays', count(array_keys($outs, 'checked_in')) === 1 && count(array_keys($outs, 'checked_in+replayed')) === 11, json_encode(array_count_values($outs)));
check('race: … stored once', (int)q("SELECT COUNT(*) FROM scanner_checkins WHERE client_id = ?", [$same])->fetchColumn() === 1);

// ── Token life ─────────────────────────────────────────────────────────────────
[$s, $b] = req('POST', 'api/scanner/logout.php', null, $tB);
check('logout: 200', $s === 200 && ($b['ok'] ?? false) === true);
check('logout: the token stops working', req('GET', 'api/scanner/events.php', null, $tB)[0] === 401);
check('logout: twice is fine', req('POST', 'api/scanner/logout.php', null, $tB)[0] === 200);
$tA2 = login('t_scanner_a', $PW, 'second phone')[1]['token'] ?? '';
check('token: a user may have two phones signed in', req('GET', 'api/scanner/events.php', null, $tA)[0] === 200 && req('GET', 'api/scanner/events.php', null, $tA2)[0] === 200);
q("UPDATE users SET password_changed_at = NOW() + INTERVAL 1 SECOND WHERE id = ?", [$scanA]);
check('token: the user changes their password → older tokens stop working', req('GET', 'api/scanner/events.php', null, $tA2)[0] === 401);
q("UPDATE users SET password_changed_at = NULL WHERE id = ?", [$scanA]);
check('token: (back again once that is undone)', req('GET', 'api/scanner/events.php', null, $tA2)[0] === 200);
q("UPDATE users SET must_change_password = 1 WHERE id = ?", [$scanA]);
check('token: an admin resets the password (temporary) → token stops working', req('GET', 'api/scanner/events.php', null, $tA2)[0] === 401);
q("UPDATE users SET must_change_password = 0, role = 'inviter' WHERE id = ?", [$scanA]);
check('token: the user is no longer a scanner → token stops working', req('GET', 'api/scanner/events.php', null, $tA2)[0] === 401);
q("UPDATE users SET role = 'scanner' WHERE id = ?", [$scanA]);
q("UPDATE api_tokens SET expires_at = NOW() - INTERVAL 1 SECOND WHERE token_hash = ?", [hash('sha256', $tA2)]);
check('token: expired → 401 token_invalid', (req('GET', 'api/scanner/events.php', null, $tA2)[1]['error']['code'] ?? '') === 'token_invalid');
q("DELETE FROM users WHERE id = ?", [$scanB]);
check('token: deleting a user removes their tokens and upload records', (int)q("SELECT COUNT(*) FROM api_tokens WHERE user_id = ?", [$scanB])->fetchColumn() === 0
      && (int)q("SELECT COUNT(*) FROM scanner_checkins WHERE user_id = ?", [$scanB])->fetchColumn() === 0);
q("DELETE FROM guests WHERE id = ?", [$g[1]]);
check('guest delete still works (upload records go with the guest)', (int)q("SELECT COUNT(*) FROM scanner_checkins WHERE guest_id = ?", [$g[1]])->fetchColumn() === 0);

foreach (glob(sys_get_temp_dir() . '/eventix_rate_*') ?: [] as $f) if (fileowner($f) === getmyuid()) @unlink($f);
echo $fails === 0 ? "\nALL PASS\n" : "\n{$fails} FAILED\n";
exit($fails === 0 ? 0 : 1);
