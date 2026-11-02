<?php
/**
 * Scanner app sign-in: the same accounts and password check as the website's login.php.
 *
 *   POST {"username": "...", "password": "...", "device_name": "Pixel 8"}
 *   200 {"token": "<64 hex>", "token_type": "Bearer", "expires_at": "...", "user": {id, username, role}}
 *   400 invalid_request · 401 invalid_credentials · 403 role_not_allowed | password_change_required
 *   429 too_many_attempts
 *
 * Failed attempts are counted per username + IP (login_attempts, as the website counts per IP): the
 * door team shares the venue's Wi-Fi, so one person's typos must not lock everyone out.
 */

declare(strict_types=1);

require_once __DIR__ . '/../../includes/scanner_api.php';

api_method('POST');
$in = api_body();

$username = is_string($in['username'] ?? null) ? trim($in['username']) : '';
$password = is_string($in['password'] ?? null) ? $in['password'] : '';
$device   = is_string($in['device_name'] ?? null) ? trim(preg_replace('/[\x00-\x1F\x7F]+/u', ' ', $in['device_name']) ?? '') : '';
$device   = $device === '' ? null : mb_substr($device, 0, 100);

if ($username === '' || $password === '' || mb_strlen($username) > 100 || strlen($password) > 1024) {
    api_fail(400, 'invalid_request', 'Enter your username and password.');
}

$ipKey = hash('sha256', ($_SERVER['REMOTE_ADDR'] ?? 'cli') . '|' . mb_strtolower($username) . '|evx_api_bf');
$recent = (int)(fetch_one(
    "SELECT COUNT(*) AS c FROM login_attempts WHERE ip_hash = ? AND attempted_at > NOW() - INTERVAL " . SCANNER_API_LOGIN_WINDOW . " MINUTE",
    [$ipKey]
)['c'] ?? 0);
if ($recent >= SCANNER_API_LOGIN_MAX) {
    api_fail(429, 'too_many_attempts', 'Too many failed sign-ins. Try again in ' . SCANNER_API_LOGIN_WINDOW . ' minutes.');
}

$user = fetch_one(
    "SELECT id, username, password_hash, role, must_change_password FROM users WHERE username = ?",
    [$username]
);
// an unknown username takes as long as a wrong password, so the answer time doesn't reveal which it was
$ok = password_verify($password, $user['password_hash'] ?? '$2y$10$3/FB9AYzVoODL8j5EGmZquWgtNpiz97ITCLDaW31HzLS8.8LYnX6W');
if (!$user || !$ok) {
    execute_query("INSERT INTO login_attempts (ip_hash) VALUES (?)", [$ipKey]);
    api_fail(401, 'invalid_credentials', 'Wrong username or password.');
}
execute_query("DELETE FROM login_attempts WHERE ip_hash = ?", [$ipKey]);

if (!in_array($user['role'], SCANNER_API_ROLES, true)) {
    api_fail(403, 'role_not_allowed', "This account can't check guests in. Sign in with a scanner account.");
}
if ((int)$user['must_change_password'] === 1) {
    api_fail(403, 'password_change_required',
        'Your password is temporary. Sign in once at eventix.om/login to choose your own, then sign in here with it.');
}

[$token, $expires] = api_issue_token((int)$user['id'], $device);

api_send(200, [
    'token'      => $token,
    'token_type' => 'Bearer',
    'expires_at' => api_time($expires),
    'user'       => ['id' => (int)$user['id'], 'username' => $user['username'], 'role' => $user['role']],
]);
