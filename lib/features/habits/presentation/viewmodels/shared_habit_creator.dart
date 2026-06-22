import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../domain/entities/habit.dart';
import 'shared_habit_providers.dart';

part 'shared_habit_creator.g.dart';

/// Creates a brand-new shared habit owned by the current user (Everyone/Anyone
/// from the create flow). keepAlive for the same reason as [InviteSender]: the
/// sheet only `read`s it, so auto-dispose could tear it down mid-call.
@Riverpod(keepAlive: true)
class SharedHabitCreator extends _$SharedHabitCreator {
  @override
  void build() {}

  Future<Result<void, Failure>> create(Habit habit) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return const Err(AuthFailure('Sign in first.'));

    return ref
        .read(sharedHabitRepositoryProvider)
        .createSharedHabit(
          habit: habit,
          ownerUid: user.uid,
          ownerHandle: user.handle,
          ownerDisplayName: user.displayName,
        );
  }
}
