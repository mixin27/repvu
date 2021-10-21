import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';

import '../../core/infrastructure/dio_extensions.dart';
import '../../core/shared/encoders.dart';
import '../domain/auth_failure.dart';
import 'credentials_storage/credentials_storage.dart';

class GithubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return httpClient.send(request);
  }
}

/// Github authenticator
///
class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  final Dio _dio;

  GithubAuthenticator(this._credentialsStorage, this._dio);

  static const clientId = 'YOUR_GITHUB_CLIENT_ID';
  // TODO: remove from production code
  static const clientSecret = 'YOUR_GITHUB_CLIENT_SECRET_KEY';
  static const scopes = ['read:user', 'repo'];
  static final authorizationEndpoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  static final tokenEndpoint =
      Uri.parse('https://github.com/login/oauth/access_token');
  static final revocationEndpoint =
      Uri.parse('https://api.github.com/applications/$clientId/$clientSecret');
  static final redirectUrl = Uri.parse('http://localhost:3000/callback');

  /// Get signed in credentials from storage.
  ///
  /// Return [null] if there is no credentials data in storage.
  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();

      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {
          final failureOrCredentials = await refresh(storedCredentials);
          return failureOrCredentials.fold(
            (failure) => null,
            (credentials) => credentials,
          );
        }
      }

      return storedCredentials;
    } on PlatformException {
      return null;
    }
  }

  /// Check whether the use is signed in or not.
  ///
  /// return [true] if signed in, return [false] if not.
  Future<bool> isSignedIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);

  /// Create AuthorizationGrant
  ///
  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecret,
      httpClient: GithubOAuthHttpClient(),
    );
  }

  /// Get authorization url.
  ///
  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  /// Handle authorization response.
  ///
  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error}: ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  /// Sign out user.
  ///
  Future<Either<AuthFailure, Unit>> signOut() async {
    final accessToken = await _credentialsStorage
        .read()
        .then((credentials) => credentials?.accessToken);

    final usernameAndPassword =
        stringToBase64.encode('$clientId:$clientSecret');
    try {
      try {
        _dio.deleteUri(
          revocationEndpoint,
          data: {
            'access_token': accessToken,
          },
          options: Options(
            headers: {
              'Authorization': 'basic $usernameAndPassword',
            },
          ),
        );
      } on DioError catch (e) {
        if (e.isNoConnectionError) {
          // Ignoring
        } else {
          rethrow;
        }
      }

      await _credentialsStorage.clear();
      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  /// Refresh the token.
  ///
  Future<Either<AuthFailure, Credentials>> refresh(
    Credentials credentials,
  ) async {
    try {
      final refreshedCredentials = await credentials.refresh(
        identifier: clientId,
        secret: clientSecret,
        httpClient: GithubOAuthHttpClient(),
      );

      await _credentialsStorage.save(refreshedCredentials);
      return right(refreshedCredentials);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error}: ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }
}
