import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../auth/presentation/widgets/ember_primary_button.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/invite_sender.dart';
import 'invite_handle_field.dart';

/// Bottom sheet to invite someone to [habit] by `@handle`. On success it pops
/// with the handle (without the `@`) so the caller can confirm; otherwise it
/// shows the failure inline.
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
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await ref
        .read(inviteSenderProvider.notifier)
        .submit(habit: widget.habit, rawHandle: raw);

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _busy = false;
        _error = failure.message;
      }),
      (_) => Navigator.of(context).pop(raw.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: palette.border),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        child: SafeArea(
          top: false,
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
              const SizedBox(height: 6),
              Text(
                "They'll log it together with you.",
                style: EmberText.mono(12, color: palette.dim),
              ),
              const SizedBox(height: 18),
              InviteHandleField(
                controller: _controller,
                onSubmitted: (_) => _send(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: EmberText.mono(12, color: EmberSemantic.danger),
                ),
              ],
              const SizedBox(height: 18),
              EmberPrimaryButton(
                label: 'Send invite',
                loading: _busy,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
