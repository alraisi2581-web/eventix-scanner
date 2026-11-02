<?php
/**
 * The events this scanner may check guests in for — as scanner/index.php lists them: admins and
 * all-events users see every event, others the events assigned to them. Archived events and demo
 * guests are left out.
 *
 *   GET (Authorization: Bearer <token>)
 *   200 {"user": {...}, "events": [{id, title_en, title_ar, venue_en, venue_ar, starts_at, starts_label,
 *                                   timezone, guest_count, checked_in_count}]}
 */

declare(strict_types=1);

require_once __DIR__ . '/../../includes/scanner_api.php';

api_method('GET');
$user = api_require_user();
api_rate_limit('scanner_api_read_' . (int)$user['id'], 60);

$select = "SELECT e.id, e.title_en, e.title_ar, e.venue_en, e.venue_ar, e.start_time, e.timezone,
                  COUNT(g.id) AS guest_count, COALESCE(SUM(g.checkin_status = 'Scanned'), 0) AS checked_in_count
           FROM events e
           LEFT JOIN guests g ON g.event_id = e.id AND g.is_demo = 0";
if ($user['role'] === 'admin' || (int)$user['has_all_events_access'] === 1) {
    $rows = fetch_all("$select WHERE e.status <> 'archived' GROUP BY e.id ORDER BY e.start_time DESC");
} else {
    $rows = fetch_all(
        "$select JOIN user_event_permissions uep ON uep.event_id = e.id AND uep.user_id = ?
         WHERE e.status <> 'archived' GROUP BY e.id ORDER BY e.start_time DESC",
        [(int)$user['id']]
    );
}

api_send(200, [
    'user'   => ['id' => (int)$user['id'], 'username' => $user['username'], 'role' => $user['role']],
    'events' => array_map('api_event_payload', $rows),
]);
