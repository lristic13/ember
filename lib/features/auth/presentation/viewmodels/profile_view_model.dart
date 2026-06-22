import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_providers.dart';

part 'profile_view_model.g.dart';

class ProfileState {
  final bool busy;
  final String? error;

  const ProfileState({this.busy = false, this.error});
}

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  ProfileState build() => const ProfileState();

  Future<void> signOut() async {
    state = const ProfileState(busy: true);
    final result = await ref.read(signOutUseCaseProvider).call();
    state = result.fold(
      (failure) => ProfileState(error: failure.message),
      (_) => const ProfileState(),
    );
  }

  /// Returns true when the account was deleted.
  Future<bool> deleteAccount() async {
    state = const ProfileState(busy: true);
    final result = await ref.read(deleteAccountUseCaseProvider).call();
    return result.fold(
      (failure) {
        state = ProfileState(error: failure.message);
        return false;
      },
      (_) {
        state = const ProfileState();
        return true;
      },
    );
  }
}
