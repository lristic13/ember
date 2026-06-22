import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../../auth/presentation/widgets/ember_primary_button.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_participant.dart';
import '../../viewmodels/invite_providers.dart';
import '../../viewmodels/invite_sender.dart';
import '../habit_details/shared_members_section.dart';
import 'invite_result_row.dart';

/// Bottom sheet to invite people to [habit]: search by handle, tap to add, then
/// Invite. On a fully successful send it pops with a summary message; partial
/// failures stay open with the offending picks flagged.
Future<String?> showInviteSheet(BuildContext context, Habit habit) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => InviteSheet(habit: habit),
  );
}

class InviteSheet extends ConsumerStatefulWidget {
  final Habit habit;

  const InviteSheet({super.key, required this.habit});

  @override
  ConsumerState<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<InviteSheet> {
  final _controller = TextEditingController();
  final List<HabitParticipant> _selected = [];
  Map<String, String> _failed = const {};
  Timer? _debounce;
  String _query = '';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _add(HabitParticipant user) {
    _debounce?.cancel();
    setState(() {
      if (!_selected.any((u) => u.uid == user.uid)) _selected.add(user);
      _error = null;
      _controller.clear();
      _query = '';
    });
  }

  void _removeSelected(HabitParticipant user) {
    setState(() {
      _selected.removeWhere((u) => u.uid == user.uid);
      if (user.handle != null) {
        _failed = Map.of(_failed)..remove(user.handle);
      }
    });
  }

  Future<void> _invite() async {
    if (_busy) return;
    if (_selected.isEmpty) {
      setState(() => _error = 'Add at least one person.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _failed = const {};
    });

    final handles = _selected
        .map((u) => u.handle)
        .whereType<String>()
        .toList();
    final outcome = await ref
        .read(inviteSenderProvider.notifier)
        .submitMany(habit: widget.habit, rawHandles: handles);

    if (!mounted) return;

    setState(() {
      _selected.removeWhere(
        (u) => u.handle != null && outcome.sent.contains(u.handle),
      );
      _failed = outcome.failed;
      _busy = false;
      _error = outcome.error;
    });

    if (outcome.error == null && outcome.failed.isEmpty) {
      Navigator.of(context).pop(_summary(outcome.sent));
    }
  }

  String _summary(List<String> sent) => sent.length == 1
      ? 'Invite sent to @${sent.first}'
      : 'Invited ${sent.length} people';

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    final selfUid = ref.watch(currentUserProvider)?.uid;
    final excluded = {
      ?selfUid,
      ...widget.habit.participants.map((p) => p.uid),
      ..._selected.map((u) => u.uid),
    };
    final searchAsync = ref.watch(userSearchProvider(_query));
    final results = (searchAsync.asData?.value ?? const <HabitParticipant>[])
        .where((u) => !excluded.contains(u.uid))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: palette.border),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Invite to ${widget.habit.name}',
                style: EmberText.display(20, color: palette.text),
              ),
              const SizedBox(height: 14),
              _SearchField(controller: _controller, onChanged: _onSearchChanged),
              if (_selected.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final u in _selected)
                      _SelectedChip(
                        user: u,
                        error: u.handle != null ? _failed[u.handle] : null,
                        onRemove: () => _removeSelected(u),
                      ),
                  ],
                ),
              ],
              _ResultsArea(
                query: _query,
                loading: searchAsync.isLoading,
                results: results,
                onAdd: _add,
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(
                  _error!,
                  style: EmberText.mono(12, color: EmberSemantic.danger),
                ),
              ],
              const SizedBox(height: 14),
              EmberPrimaryButton(
                label: _selected.isEmpty
                    ? 'Invite'
                    : 'Invite ${_selected.length}',
                enabled: _selected.isNotEmpty,
                loading: _busy,
                onPressed: _invite,
              ),
              if (widget.habit.isShared) ...[
                const SizedBox(height: 18),
                SharedMembersSection(habit: widget.habit),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// Handle-prefix search field with a leading icon; lowercases as you type.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: palette.dim),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              cursorColor: EmberAccent.neon,
              cursorWidth: 2,
              style: EmberText.mono(15, color: palette.text),
              inputFormatters: [
                TextInputFormatter.withFunction(
                  (oldValue, newValue) =>
                      newValue.copyWith(text: newValue.text.toLowerCase()),
                ),
              ],
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                hintText: 'Search by @handle',
                hintStyle: EmberText.mono(15, color: palette.dimmer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The search results (or a loading/empty hint) below the field.
class _ResultsArea extends StatelessWidget {
  final String query;
  final bool loading;
  final List<HabitParticipant> results;
  final ValueChanged<HabitParticipant> onAdd;

  const _ResultsArea({
    required this.query,
    required this.loading,
    required this.results,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    if (query.isEmpty) return const SizedBox(height: 8);

    if (loading && results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'No one found for "$query"',
          style: EmberText.mono(12, color: palette.dim),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          for (final user in results)
            InviteResultRow(user: user, onAdd: () => onAdd(user)),
        ],
      ),
    );
  }
}

/// A picked person, removable; tinted danger when its last send failed.
class _SelectedChip extends StatelessWidget {
  final HabitParticipant user;
  final String? error;
  final VoidCallback onRemove;

  const _SelectedChip({
    required this.user,
    required this.error,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final failed = error != null;
    final label = user.handle != null
        ? '@${user.handle}'
        : (user.displayName ?? 'User');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          decoration: BoxDecoration(
            color: palette.field,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: failed ? EmberSemantic.line : palette.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: EmberText.mono(
                  12,
                  color: failed ? EmberSemantic.danger : palette.text,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.close_rounded, size: 14, color: palette.dim),
              ),
            ],
          ),
        ),
        if (failed)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 3),
            child: Text(
              error!,
              style: EmberText.mono(9, color: EmberSemantic.danger),
            ),
          ),
      ],
    );
  }
}
