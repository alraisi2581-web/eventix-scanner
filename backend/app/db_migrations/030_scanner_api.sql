-- Migration 030: the door-scanner mobile app's API (api/scanner/*.php, includes/scanner_api.php)
--   api_tokens        one row per signed-in phone: the SHA-256 of its bearer token (the token itself is
--                     never stored), when it expires, when it was revoked (sign-out)
--   scanner_checkins  every check-in the app uploaded, keyed by the phone's own id for it (client_id,
--                     a UUID), so a resend after a lost reply is answered from here, never applied twice
-- 2026-11-01. Safe to run again.
--
--   mysql -u <user> <db> < db_migrations/030_scanner_api.sql
--   undo: db_migrations/030_scanner_api.down.sql

CREATE TABLE IF NOT EXISTS api_tokens (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    token_hash    CHAR(64) NOT NULL,
    device_name   VARCHAR(100) NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_used_at  DATETIME NULL,
    expires_at    DATETIME NOT NULL,
    revoked_at    DATETIME NULL,
    UNIQUE KEY uq_api_tokens_hash (token_hash),
    KEY idx_api_tokens_user (user_id),
    CONSTRAINT fk_api_tokens_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scanner_checkins (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id     CHAR(36) NOT NULL,
    user_id       INT NOT NULL,
    event_id      INT NOT NULL,
    guest_id      INT NOT NULL,
    scanned_at    DATETIME NULL,
    received_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    outcome       ENUM('checked_in','already_checked_in') NOT NULL,
    checkin_time  DATETIME NULL,
    UNIQUE KEY uq_scanner_checkins_client (client_id),
    KEY idx_scanner_checkins_event (event_id, received_at),
    CONSTRAINT fk_scanner_checkins_user  FOREIGN KEY (user_id)  REFERENCES users (id)  ON DELETE CASCADE,
    CONSTRAINT fk_scanner_checkins_event FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE,
    CONSTRAINT fk_scanner_checkins_guest FOREIGN KEY (guest_id) REFERENCES guests (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
