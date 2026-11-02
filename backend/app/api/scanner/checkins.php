<?php
/**
 * Uploads check-ins made on the phone — live, or queued while it was offline.
 *
 *   POST {"checkins": [{"client_id": "<uuid v4>", "guest_id": 12, "scanned_at": "2026-11-23T12:03:10+00:00"}]}
 *   200 {"results": [{client_id, guest_id, status, checked_in_at?, checked_in_label?, message?, replayed?}]}
 *
 * status: checked_in (this upload checked the guest in) · already_checked_in (someone reached the
 * server first; checked_in_at is theirs) · not_found · forbidden · invalid. The results are in the
 * order sent. A client_id seen before gets its first answer again (replayed: true) and changes nothing,
 * so the app can resend whatever it did not hear back about. See api_apply_checkin().
 */

declare(strict_types=1);

require_once __DIR__ . '/../../includes/scanner_api.php';

api_method('POST');
$user = api_require_user();
api_rate_limit('scanner_api_checkins_' . (int)$user['id'], 120);

$items = api_body()['checkins'] ?? null;
if (!is_array($items) || !array_is_list($items) || $items === []) {
    api_fail(400, 'invalid_request', 'No check-ins were sent.');
}
if (count($items) > SCANNER_API_BATCH_MAX) {
    api_fail(400, 'too_many', 'Send at most ' . SCANNER_API_BATCH_MAX . ' check-ins at a time.');
}

$access  = [];
$results = [];
foreach ($items as $item) {
    $results[] = api_apply_checkin(is_array($item) ? $item : [], (int)$user['id'], $access);
}
api_send(200, ['results' => $results]);
