import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Who is signed in on this phone. The token lives in the Keychain (iOS) or
/// in Keystore-encrypted storage (Android), never in the SQLite database.
class Session {
  const Session({
    required this.token,
    required this.userId,
    required this.username,
    required this.role,
    required this.expiresAt,
  });
  final String token;
  final int userId;
  final String username;
  final String role;
  final DateTime expiresAt;
}

class SessionStore {
  SessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  static const _keys = ['token', 'user_id', 'username', 'role', 'expires_at'];

  Future<Session?> read() async {
    final v = await _storage.readAll();
    final token = v['token'], id = int.tryParse(v['user_id'] ?? '');
    final expires = DateTime.tryParse(v['expires_at'] ?? '');
    if (token == null || id == null || expires == null) return null;
    return Session(
      token: token,
      userId: id,
      username: v['username'] ?? '',
      role: v['role'] ?? 'scanner',
      expiresAt: expires,
    );
  }

  Future<void> write(Session s) async {
    await _storage.write(key: 'token', value: s.token);
    await _storage.write(key: 'user_id', value: '${s.userId}');
    await _storage.write(key: 'username', value: s.username);
    await _storage.write(key: 'role', value: s.role);
    await _storage.write(key: 'expires_at', value: s.expiresAt.toIso8601String());
    await _storage.write(key: 'last_username', value: s.username);
  }

  /// Forgets the token; the username is kept to fill in the sign-in form.
  Future<void> clear() async {
    for (final k in _keys) {
      await _storage.delete(key: k);
    }
  }

  Future<String?> lastUsername() => _storage.read(key: 'last_username');

  Future<String?> language() => _storage.read(key: 'language');
  Future<void> setLanguage(String code) =>
      _storage.write(key: 'language', value: code);
}
