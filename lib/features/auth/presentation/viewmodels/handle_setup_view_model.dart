import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/validators/handle_rules.dart';
import 'auth_providers.dart';

part 'handle_setup_view_model.g.dart';

enum HandleStatus { idle, invalid, checking, available, taken }

class HandleSetupState {
  final String value; // normalized (lowercased) input
  final HandleStatus status;
  final String? message; // status line
  final bool submitting; // claim in flight
  final String? error; // claim error (non-availability)

  const HandleSetupState({
    this.value = '',
    this.status = HandleStatus.idle,
    this.message,
    this.submitting = false,
    this.error,
  });

  bool get canContinue =>
      status == HandleStatus.available && !submitting && value.isNotEmpty;

  HandleSetupState copyWith({
    String? value,
    HandleStatus? status,
    String? message,
    bool? submitting,
    String? error,
  }) {
    return HandleSetupState(
      value: value ?? this.value,
      status: status ?? this.status,
      message: message,
      submitting: submitting ?? this.submitting,
      error: error,
    );
  }
}

@riverpod
class HandleSetupViewModel extends _$HandleSetupViewModel {
  Timer? _debounce;

  @override
  HandleSetupState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const HandleSetupState();
  }

  /// ~400ms debounce after the last keystroke before the availability call.
  static const _debounceDelay = Duration(milliseconds: 400);

  void onChanged(String raw) {
    _debounce?.cancel();
    final value = HandleRules.normalize(raw);

    if (value.isEmpty) {
      state = const HandleSetupState();
      return;
    }

    final formatError = HandleRules.validate(value);
    if (formatError != null) {
      state = HandleSetupState(
        value: value,
        status: HandleStatus.invalid,
        message: formatError,
      );
      return;
    }

    state = HandleSetupState(
      value: value,
      status: HandleStatus.checking,
      message: 'Checking availability…',
    );
    _debounce = Timer(_debounceDelay, () => _check(value));
  }

  Future<void> _check(String value) async {
    final result = await ref.read(isHandleAvailableUseCaseProvider).call(value);
    if (state.value != value) return; // input changed — drop stale result
    result.fold(
      (failure) => state = state.copyWith(
        status: HandleStatus.invalid,
        message: failure.message,
      ),
      (available) => state = available
          ? state.copyWith(
              status: HandleStatus.available,
              message: '@$value is available',
            )
          : state.copyWith(
              status: HandleStatus.taken,
              message: '@$value is taken — try another',
            ),
    );
  }

  /// Returns true when the handle was claimed successfully.
  Future<bool> claim() async {
    if (!state.canContinue) return false;
    final value = state.value;
    state = state.copyWith(submitting: true);
    final result = await ref.read(claimHandleUseCaseProvider).call(value);
    return result.fold(
      (failure) {
        state = failure is HandleTakenFailure
            ? state.copyWith(
                submitting: false,
                status: HandleStatus.taken,
                message: '@$value is taken — try another',
              )
            : state.copyWith(submitting: false, error: failure.message);
        return false;
      },
      (_) {
        // Keep submitting=true: the auth-state stream re-emits with hasHandle
        // true and the router redirect moves off this screen.
        return true;
      },
    );
  }
}
