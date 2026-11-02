<?php
/**
 * Scanner app sign-out: revokes the token the request carries. Always 200 — signing out twice, or
 * with a token that already ended, is not an error.
 *
 *   POST (Authorization: Bearer <token>)  →  200 {"ok": true}
 */

declare(strict_types=1);

require_once __DIR__ . '/../../includes/scanner_api.php';

api_method('POST');

$token = api_bearer_token();
if ($token !== null) {
    execute_query(
        "UPDATE api_tokens SET revoked_at = NOW() WHERE token_hash = ? AND revoked_at IS NULL",
        [hash('sha256', $token)]
    );
}
api_send(200, ['ok' => true]);
