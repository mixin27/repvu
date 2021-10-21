import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repvu/auth/domain/auth_failure.dart';
import 'package:repvu/auth/infrastructure/github_authenticator.dart';

part 'auth_notifier.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();
  const factory AuthState.initial() = _Initial;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated() = _Authenticated;
  const factory AuthState.failure(AuthFailure failure) = _Failure;
}

typedef AuthUriCallback = Future<Uri> Function(Uri authorizationUrl);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._authenticator,
  ) : super(const AuthState.initial());

  final GithubAuthenticator _authenticator;

  /// check whether authenicated or unauthenticated and update the auth status.
  /// May be called when the app started.
  ///
  /// Set [AuthState] - [AuthState.authenticated()] or [AuthState.unauthenticated()]
  Future<void> checkAndUpdateAuthStatus() async {
    state = (await _authenticator.isSignedIn())
        ? const AuthState.authenticated()
        : const AuthState.unauthenticated();
  }

  /// Sign in
  ///
  Future<void> signIn(
    AuthUriCallback authorizationCallback,
  ) async {
    final grant = _authenticator.createGrant();
    final redirectUrl =
        await authorizationCallback(_authenticator.getAuthorizationUrl(grant));
    final failureOrSuccess = await _authenticator.handleAuthorizationResponse(
      grant,
      redirectUrl.queryParameters,
    );

    state = failureOrSuccess.fold(
      (l) => AuthState.failure(l),
      (r) => const AuthState.authenticated(),
    );

    // Need to close http client.
    grant.close();
  }

  /// Sign out
  ///
  Future<void> signOut() async {
    final failureOrSuccess = await _authenticator.signOut();

    state = failureOrSuccess.fold(
      (l) => AuthState.failure(l),
      (r) => const AuthState.unauthenticated(),
    );
  }
}
