import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

class _SecureTokenStorage implements TokenStorage {
  _SecureTokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

TokenStorage createTokenStorageImpl() => _SecureTokenStorage(const FlutterSecureStorage());

