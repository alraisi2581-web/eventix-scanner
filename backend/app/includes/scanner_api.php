<?php
/**
 * Eventix — the door-scanner mobile app's API (api/scanner/*.php, migration 030).
 *
 * The app signs in with an Eventix scanner (or admin) account through the same users table, password
 * hashes, roles and event permissions as the website, but keeps a bearer token instead of the PHP
 * session cookie: web sessions end after 24 idle minutes (session.gc_maxlifetime 1440), and a door
 * phone must survive a quiet hour or a lost connection without its user signing in again.
 *
 *   POST api/scanner/login.php     {username, password, device_name?} → {token, expires_at, user}
 *   POST api/scanner/logout.php    revokes the token it was called with
 *   GET  api/scanner/events.php    the events this user may check guests in for
 *   GET  api/scanner/guests.php?event_id=N   the event's guest list for scanning offline
 *   POST api/scanner/checkins.php  {checkins: [{client_id, guest_id, scanned_at}]} → one result each
 *
 * Errors are {"error": {"code", "message"}} with an HTTP status; messages are written for door staff.
 * Responses are never cached: nginx's 1-second microcache keys on the URL only (not the Authorization
 * header) and skips only requests with a PHPSESSID cookie, so every response here sends
 * X-Accel-Expires: 0 — which nginx honours even though it ignores Cache-Control from PHP.
 */

declare(strict_types=1);

define('EVX_STATELESS', true);   // config.php: no session, no cookie (must come before it)

require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/rate_limit.php';

const SCANNER_API_ROLES        = ['admin', 'scanner'];   // as scanner/checkin_ajax.php
const SCANNER_API_TOKEN_DAYS   = 14;
const SCANNER_API_LOGIN_MAX    = 10;    // failed sign-ins per username + IP …
const SCANNER_API_LOGIN_WINDOW = 30;    // … in this many minutes (the website: 10 per IP in 30)
const SCANNER_API_BATCH_MAX    = 100;   // check-ins per upload
const SCANNER_API_BODY_MAX     = 262144;

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
header('X-Accel-Expires: 0');
header('X-Robots-Tag: noindex');

/** Sends the JSON body with the status and ends the request. */
function api_send(int $status, array $body): never {
    http_response_code($status);
    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function api_fail(int $status, string $code, string $message): never {
    api_send($status, ['error' => ['code' => $code, 'message' => $message]]);
}

function api_method(string ...$allowed): void {
    $m = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    if (!in_array($m, $allowed, true)) {
        header('Allow: ' . implode(', ', $allowed));
        api_fail(405, 'method_not_allowed', 'Method not allowed.');
    }
}

/** The JSON request body as an array; 400 when it is missing, too big or not a JSON object. */
function api_body(): array {
    $raw = (string)file_get_contents('php://input', false, null, 0, SCANNER_API_BODY_MAX + 1);
    if (strlen($raw) > SCANNER_API_BODY_MAX) api_fail(413, 'too_large', 'The request is too large.');
    $data = json_decode($raw, true);
    if (!is_array($data) || array_is_list($data) && $data !== []) api_fail(400, 'invalid_json', 'The request is not valid JSON.');
    return $data;
}

function api_rate_limit(string $key, int $perMinute): void {
    if (rate_limit_exceeded($key, $perMinute, 60)) {
        header('Retry-After: 60');
        api_fail(429, 'rate_limited', 'Too many requests. Wait a minute and try again.');
    }
}

/* =========================
   TOKENS
========================= */

/** The bearer token sent with the request (64 hex characters), or null. */
function api_bearer_token(): ?string {
    $h = (string)($_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '');
    return preg_match('/^Bearer\s+([a-f0-9]{64})$/i', trim($h), $m) ? strtolower($m[1]) : null;
}

/** A new token for the user; only its SHA-256 is stored. Returns [token, expires_at stored]. */
function api_issue_token(int $userId, ?string $deviceName): array {
    $token   = bin2hex(random_bytes(32));
    $expires = date('Y-m-d H:i:s', time() + SCANNER_API_TOKEN_DAYS * 86400);
    execute_query("DELETE FROM api_tokens WHERE user_id = ? AND expires_at < NOW() - INTERVAL 30 DAY", [$userId]);
    insert_query(
        "INSERT INTO api_tokens (user_id, token_hash, device_name, expires_at) VALUES (?, ?, ?, ?)",
        [$userId, hash('sha256', $token), $deviceName, $expires]
    );
    return [$token, $expires];
}

/**
 * The signed-in user for this request, or 401. A token stops working when it expires, is revoked
 * (sign-out), its user's password changes after it was issued, an admin sets a temporary password
 * (must_change_password), or the user is no longer a scanner or admin. Fills $_SESSION in memory
 * (never saved: EVX_STATELESS) so user_has_event_access() and log_audit() work unchanged.
 */
function api_require_user(): array {
    $token = api_bearer_token();
    if ($token === null) api_fail(401, 'unauthenticated', 'Sign in to continue.');

    $row = fetch_one(
        "SELECT t.id AS token_id, t.created_at AS token_created_at, t.expires_at, t.revoked_at, t.last_used_at,
                u.id, u.username, u.role, u.has_all_events_access, u.must_change_password, u.password_changed_at
         FROM api_tokens t JOIN users u ON u.id = t.user_id
         WHERE t.token_hash = ?",
        [hash('sha256', $token)]
    );
    $now = date('Y-m-d H:i:s');
    if (!$row
        || $row['revoked_at'] !== null
        || $row['expires_at'] <= $now
        || (int)$row['must_change_password'] === 1
        || ($row['password_changed_at'] !== null && $row['password_changed_at'] > $row['token_created_at'])
        || !in_array($row['role'], SCANNER_API_ROLES, true)) {
        api_fail(401, 'token_invalid', 'Your sign-in has ended. Sign in again.');
    }

    if ($row['last_used_at'] === null || strtotime($row['last_used_at']) < time() - 300) {
        execute_query("UPDATE api_tokens SET last_used_at = ? WHERE id = ?", [$now, (int)$row['token_id']]);
    }

    $_SESSION['user_id']   = (int)$row['id'];
    $_SESSION['user_role'] = $row['role'];
    $_SESSION['username']  = $row['username'];
    return $row;
}

/* =========================
   TIMES
========================= */

/** A stored (Muscat) time as ISO 8601 with its offset ("2026-11-23T16:00:00+04:00"); null when empty. */
function api_time(?string $stored): ?string {
    $m = event_moment($stored, EVENT_SERVER_TZ);
    return $m ? $m->format(DATE_ATOM) : null;
}

/**
 * The phone's ISO 8601 scan time as a stored (Muscat) time; null when missing, unreadable, or not
 * between 30 days ago and 10 minutes from now (a phone clock that is badly wrong is not recorded).
 */
function api_device_time_to_stored(mixed $iso): ?string {
    if (!is_string($iso) || $iso === '' || strlen($iso) > 40) return null;
    try {
        $m = new DateTimeImmutable($iso);
    } catch (Throwable) {
        return null;
    }
    $ts = $m->getTimestamp();
    if ($ts > time() + 600 || $ts < time() - 30 * 86400) return null;
    return $m->setTimezone(new DateTimeZone(EVENT_SERVER_TZ))->format('Y-m-d H:i:s');
}

/* =========================
   PAYLOADS
========================= */

/** An event as the app sees it; times as ISO 8601, labels in the event's own zone. */
function api_event_payload(array $e): array {
    return [
        'id'               => (int)$e['id'],
        'title_en'         => (string)$e['title_en'],
        'title_ar'         => (string)$e['title_ar'],
        'venue_en'         => (string)$e['venue_en'],
        'venue_ar'         => (string)$e['venue_ar'],
        'starts_at'        => api_time($e['start_time']),
        'starts_label'     => event_staff_time($e['start_time'], $e, 'D j M Y, g:i a'),
        'timezone'         => event_tz_name($e),
        'guest_count'      => (int)($e['guest_count'] ?? 0),
        'checked_in_count' => (int)($e['checked_in_count'] ?? 0),
    ];
}

/** The event row (with timezone) if this user may check its guests in; 403 / 404 otherwise. */
function api_event_for_user(int $eventId): array {
    $e = $eventId > 0 ? fetch_one(
        "SELECT id, title_en, title_ar, venue_en, venue_ar, start_time, timezone, status FROM events WHERE id = ?",
        [$eventId]
    ) : null;
    if (!$e) api_fail(404, 'event_not_found', 'This event no longer exists.');
    if (!user_has_event_access($eventId)) api_fail(403, 'forbidden', "You don't have access to this event.");
    return $e;
}

/* =========================
   CHECK-INS
========================= */

/**
 * Applies one uploaded check-in. The first check-in to reach the server wins: the guest row is locked
 * (FOR UPDATE), so two phones checking in the same guest at once are answered one after the other —
 * the first "checked_in", the second "already_checked_in" with the first one's time. A client_id seen
 * before (the phone resending after a lost reply) gets the answer it got the first time and changes
 * nothing. Returns the result for the app.
 */
function api_apply_checkin(array $item, int $userId, array &$accessCache): array {
    $clientId = is_string($item['client_id'] ?? null) ? strtolower(trim($item['client_id'])) : '';
    $guestId  = (int)filter_var($item['guest_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
    $result   = ['client_id' => $clientId, 'guest_id' => $guestId];

    if (!preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/', $clientId) || $guestId <= 0) {
        return $result + ['status' => 'invalid', 'message' => 'This check-in is malformed and was not recorded.'];
    }
    $scannedAt = api_device_time_to_stored($item['scanned_at'] ?? null);

    $pdo = get_db_connection();
    for ($attempt = 1; ; $attempt++) {
        try {
            $pdo->beginTransaction();
            $g = fetch_one(
                "SELECT g.id, g.event_id, g.is_demo, g.checkin_status, g.checkin_time, e.timezone
                 FROM guests g JOIN events e ON e.id = g.event_id
                 WHERE g.id = ? FOR UPDATE",
                [$guestId]
            );
            if (!$g || (int)$g['is_demo'] === 1) {
                $pdo->rollBack();
                return $result + ['status' => 'not_found', 'message' => 'This guest is no longer on the list.'];
            }
            $eid = (int)$g['event_id'];
            $accessCache[$eid] ??= user_has_event_access($eid);
            if (!$accessCache[$eid]) {
                $pdo->rollBack();
                return $result + ['status' => 'forbidden', 'message' => "You don't have access to this guest's event."];
            }

            $prev = fetch_one(
                "SELECT user_id, guest_id, outcome, checkin_time FROM scanner_checkins WHERE client_id = ? FOR UPDATE",
                [$clientId]
            );
            if ($prev) {
                $pdo->rollBack();
                if ((int)$prev['user_id'] !== $userId || (int)$prev['guest_id'] !== $guestId) {
                    return $result + ['status' => 'invalid', 'message' => 'This check-in id was already used.'];
                }
                return $result + api_checkin_outcome($prev['outcome'], $prev['checkin_time'], $g) + ['replayed' => true];
            }

            if ($g['checkin_status'] !== 'Scanned') {
                $outcome = 'checked_in';
                $time    = date('Y-m-d H:i:s');
                execute_query(
                    "UPDATE guests SET checkin_status = 'Scanned', checkin_time = ? WHERE id = ?",
                    [$time, $guestId]
                );
                log_audit($eid, $guestId, 'app_checkin', 'Not Scanned', 'Scanned');
            } else {
                $outcome = 'already_checked_in';
                $time    = $g['checkin_time'];
            }
            insert_query(
                "INSERT INTO scanner_checkins (client_id, user_id, event_id, guest_id, scanned_at, outcome, checkin_time)
                 VALUES (?, ?, ?, ?, ?, ?, ?)",
                [$clientId, $userId, $eid, $guestId, $scannedAt, $outcome, $time]
            );
            $pdo->commit();
            return $result + api_checkin_outcome($outcome, $time, $g);
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            // a deadlock, or the same client_id inserted by a parallel request: once more reads the stored answer
            $retry = in_array((int)($e->errorInfo[1] ?? 0), [1062, 1213], true);
            if (!$retry || $attempt >= 3) throw $e;
        }
    }
}

function api_checkin_outcome(string $outcome, ?string $time, array $event): array {
    return [
        'status'           => $outcome,
        'checked_in_at'    => api_time($time),
        'checked_in_label' => event_staff_time($time, $event, 'g:i a'),
    ];
}
