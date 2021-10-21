import 'package:oauth2/oauth2.dart';

/// Base class for credentials storage
/// Android, iOS and Web
abstract class CredentialsStorage {
  /// Read credentials from storage
  ///
  /// return [Credentials]
  Future<Credentials?> read();

  /// Write credentials to storage
  ///
  ///
  Future<void> save(Credentials credentials);

  /// Clear credentials from storage.
  ///
  ///
  Future<void> clear();
}
