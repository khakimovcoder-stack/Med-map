import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around flutter_secure_storage for the auth token.
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  final FlutterSecureStorage _storage;

  static const String _kAuthToken = 'auth_token';
  static const String _kUserPhone = 'user_phone';
  static const String _kUserName = 'user_name';
  static const String _kUserId = 'user_id';

  Future<String?> getAuthToken() => _storage.read(key: _kAuthToken);

  Future<void> setAuthToken(String token) =>
      _storage.write(key: _kAuthToken, value: token);

  Future<void> clearAuth() async {
    await _storage.delete(key: _kAuthToken);
    await _storage.delete(key: _kUserPhone);
    await _storage.delete(key: _kUserName);
    await _storage.delete(key: _kUserId);
  }

  Future<String?> getUserPhone() => _storage.read(key: _kUserPhone);
  Future<String?> getUserName() => _storage.read(key: _kUserName);
  Future<String?> getUserId() => _storage.read(key: _kUserId);

  Future<void> setUser({
    required String id,
    required String phone,
    String? fullName,
  }) async {
    await _storage.write(key: _kUserId, value: id);
    await _storage.write(key: _kUserPhone, value: phone);
    if (fullName != null) {
      await _storage.write(key: _kUserName, value: fullName);
    }
  }
}
