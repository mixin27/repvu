import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart';

import 'credentials_storage.dart';

/// Secure storage for credentials.
///
class SecureCredentialsStorage implements CredentialsStorage {
  final FlutterSecureStorage _storage;

  SecureCredentialsStorage(this._storage);

  static const _key = 'oauth2_credentials';
  Credentials? _cachedCredentials;

  @override
  Future<Credentials?> read() async {
    if (_cachedCredentials != null) {
      return _cachedCredentials;
    }

    final result = await _storage.read(key: _key);
    if (result == null) {
      return null;
    }

    try {
      return _cachedCredentials = Credentials.fromJson(result);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(Credentials credentials) {
    _cachedCredentials = credentials;
    return _storage.write(key: _key, value: credentials.toJson());
  }

  @override
  Future<void> clear() {
    _cachedCredentials = null;
    return _storage.delete(key: _key);
  }
}
