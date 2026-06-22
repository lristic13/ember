import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import 'auth_providers.dart';

part 'sign_in_view_model.g.dart';

enum AuthProviderKind { apple, google }

/// State for the sign-in screen. [loading] names the provider whose button
/// should show a spinner; [error] is shown in the error card.
class SignInState {
  final AuthProviderKind? loading;
  final String? error;

  const SignInState({this.loading, this.error});

  bool get isLoading => loading != null;
}

@riverpod
class SignInViewModel extends _$SignInViewModel {
  @override
  SignInState build() => const SignInState();

  Future<void> signInWithApple() => _run(
    AuthProviderKind.apple,
    () => ref.read(signInWithAppleUseCaseProvider).call(),
  );

  Future<void> signInWithGoogle() => _run(
    AuthProviderKind.google,
    () => ref.read(signInWithGoogleUseCaseProvider).call(),
  );

  Future<void> _run(
    AuthProviderKind kind,
    Future<Result<AppUser, Failure>> Function() action,
  ) async {
    state = SignInState(loading: kind);
    final result = await action();
    result.fold(
      (failure) {
        // Cancellation is not an error — quietly return to idle.
        state = failure is CancelledFailure
            ? const SignInState()
            : SignInState(error: failure.message);
      },
      // On success, the auth-state gate handles navigation.
      (_) => state = const SignInState(),
    );
  }
}
