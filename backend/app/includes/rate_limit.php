<?php
/**
 * Eventix - Simple Rate Limiting Helper
 *
 * Provides a file‑based rate limiting mechanism to prevent abuse of
 * endpoints such as the QR scanner or search interfaces. Each key
 * represents a separate bucket of requests. If more than $limit
 * requests are recorded within the time window defined by $seconds
 * the request will be denied with HTTP 429.
 *
 * This implementation uses the system temporary directory to store
 * per‑key request timestamps. It is not suitable for distributed
 * deployments but works well on shared hosting environments like
 * cPanel.
 *
 * @param string $key     Unique identifier for the rate limiting bucket.
 * @param int    $limit   Maximum number of allowed requests per window.
 * @param int    $seconds Duration of the window in seconds.
 */
function rateLimit(string $key, int $limit = 10, int $seconds = 60): void {
    if (rate_limit_exceeded($key, $limit, $seconds)) {
        http_response_code(429);
        die('Too many requests. Please try again later.');
    }
}

/**
 * The same counter as rateLimit() without the response: true when the key already had $limit
 * requests in the last $seconds (this one is then not counted), else records it and returns false.
 * For callers that answer in their own format (the scanner app's JSON API).
 */
function rate_limit_exceeded(string $key, int $limit, int $seconds): bool {
    // Compose a filename based on the key. Use MD5 to avoid illegal
    // filesystem characters and limit filename length.
    $file = sys_get_temp_dir() . '/eventix_rate_' . md5($key);

    $now = time();
    $requests = [];

    if (file_exists($file)) {
        $contents = file_get_contents($file);
        if ($contents) {
            $requests = json_decode($contents, true) ?? [];
        }
    }

    // Purge old timestamps outside the current window.
    $requests = array_filter($requests, static function ($timestamp) use ($now, $seconds) {
        return ($timestamp >= ($now - $seconds));
    });

    // If the limit has been exceeded, block the request.
    if (count($requests) >= $limit) {
        return true;
    }

    // Record the current request and persist the timestamps.
    $requests[] = $now;
    file_put_contents($file, json_encode(array_values($requests)));
    return false;
}
