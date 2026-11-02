<?php
/**
 * An event's guest list for scanning on the phone without the network.
 *
 *   GET ?event_id=N (Authorization: Bearer <token>)
 *   200 {"event": {...}, "generated_at": "...", "guests": [{id, name_en, name_ar, rsvp, table_number,
 *        token_sha256, checked_in, checked_in_at, checked_in_label}]}
 *
 * Each guest's QR token is sent only as its SHA-256: the token is also the guest's RSVP link, so a lost
 * phone must not hold it. The app hashes what it scans and looks that up. No phone numbers or emails.
 */

declare(strict_types=1);

require_once __DIR__ . '/../../includes/scanner_api.php';

api_method('GET');
$user = api_require_user();
api_rate_limit('scanner_api_read_' . (int)$user['id'], 60);

$eventId = (int)filter_var($_GET['event_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
if ($eventId <= 0) api_fail(400, 'invalid_request', 'Choose an event.');
$event = api_event_for_user($eventId);

$rows = fetch_all(
    "SELECT id, name_en, name_ar, rsvp, table_number, token, checkin_status, checkin_time
     FROM guests WHERE event_id = ? AND is_demo = 0 ORDER BY name_en, id",
    [$eventId]
);

$guests  = [];
$checked = 0;
foreach ($rows as $g) {
    $in = $g['checkin_status'] === 'Scanned';
    $checked += $in ? 1 : 0;
    $guests[] = [
        'id'               => (int)$g['id'],
        'name_en'          => (string)$g['name_en'],
        'name_ar'          => (string)$g['name_ar'],
        'rsvp'             => (string)$g['rsvp'],
        'table_number'     => $g['table_number'] !== null && $g['table_number'] !== '' ? (string)$g['table_number'] : null,
        'token_sha256'     => hash('sha256', (string)$g['token']),
        'checked_in'       => $in,
        'checked_in_at'    => $in ? api_time($g['checkin_time']) : null,
        'checked_in_label' => $in ? event_staff_time($g['checkin_time'], $event, 'g:i a') : null,
    ];
}

api_send(200, [
    'event'        => api_event_payload($event + ['guest_count' => count($guests), 'checked_in_count' => $checked]),
    'generated_at' => api_time(date('Y-m-d H:i:s')),
    'guests'       => $guests,
]);
