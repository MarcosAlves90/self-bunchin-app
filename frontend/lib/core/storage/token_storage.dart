import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  final FlutterSecureStorage _secureStorage;

  Future<void> saveAccessToken(String token) {
    return _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearAccessToken() {
    return _secureStorage.delete(key: _tokenKey);
  }
}
