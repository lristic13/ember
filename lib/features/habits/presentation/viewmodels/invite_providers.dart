import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/datasources/invite_remote_datasource.dart';
import '../../data/repositories/invite_repository_impl.dart';
import '../../domain/entities/invite.dart';
import '../../domain/repositories/invite_repository.dart';

part 'invite_providers.g.dart';

@Riverpod(keepAlive: true)
InviteRemoteDatasource inviteRemoteDatasource(Ref ref) =>
    InviteRemoteDatasource();

@Riverpod(keepAlive: true)
InviteRepository inviteRepository(Ref ref) =>
    InviteRepositoryImpl(ref.watch(inviteRemoteDatasourceProvider));

/// The current user's pending incoming invites, live. Empty when signed out.
@riverpod
Stream<List<Invite>> pendingInvites(Ref ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(inviteRepositoryProvider).watchPendingInvites(uid);
}

/// How many pending invites the user has, for badges.
@riverpod
int pendingInviteCount(Ref ref) =>
    ref.watch(pendingInvitesProvider).asData?.value.length ?? 0;

/// Pending invites the current user sent for [habitId], live (owner management).
@riverpod
Stream<List<Invite>> habitInvites(Ref ref, String habitId) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(inviteRepositoryProvider).watchHabitInvites(habitId, uid);
}
