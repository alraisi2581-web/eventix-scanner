-- Undo migration 030 (scanner app API). Remove app/api/scanner/ first, then run this.
-- Guests the app checked in stay checked in (guests.checkin_status is not touched).
--
--   mysql -u <user> <db> < db_migrations/030_scanner_api.down.sql

DROP TABLE IF EXISTS scanner_checkins;
DROP TABLE IF EXISTS api_tokens;
