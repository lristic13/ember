import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../viewmodels/auth_providers.dart';
import '../viewmodels/profile_view_model.dart';
import 'warn_triangle.dart';

/// Presents the destructive delete-account confirmation as a modal sheet.
/// Returns true if the account was deleted.
Future<bool?> showDeleteAccountSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xBC020406), // rgba(2,4,6,0.74)
    builder: (_) => const DeleteAccountSheet(),
  );
}

class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  ConsumerState<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<DeleteAccountSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final handle = ref.watch(currentUserProvider)?.handle ?? '';
    final busy = ref.watch(profileViewModelProvider).busy;
    final matches =
        _controller.text.trim().toLowerCase() == handle.toLowerCase() &&
        handle.isNotEmpty;
    final canDelete = matches && !busy;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        decoration: BoxDecoration(
          color: palette.card,
          border: Border(top: BorderSide(color: palette.border)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 35,
              height: 3,
              decoration: BoxDecoration(
                color: palette.dimmer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EmberSemantic.tint,
                border: Border.all(color: EmberSemantic.line),
              ),
              child: const WarnTriangle(size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete account?',
              style: EmberText.display(
                21,
                color: palette.text,
                letterSpacingEm: -0.03,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text:
                    'This permanently erases your account, every activity, and '
                    'your entire history. ',
                children: [
                  TextSpan(
                    text: "This can't be undone.",
                    style: EmberText.display(
                      12,
                      color: EmberSemantic.dangerSoft,
                      weight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: EmberText.display(
                12,
                color: palette.dim,
                weight: FontWeight.w400,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TYPE @${handle.toUpperCase()} TO CONFIRM',
                style: EmberText.mono(9, color: palette.dimmer),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: palette.field,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: EmberSemantic.line, width: 2),
              ),
              child: Row(
                children: [
                  Text('@', style: EmberText.mono(16, color: palette.dimmer)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autocorrect: false,
                      enableSuggestions: false,
                      cursorColor: EmberSemantic.danger,
                      cursorWidth: 2,
                      onChanged: (_) => setState(() {}),
                      style: EmberText.mono(16, color: palette.text),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _DeleteButton(
              enabled: canDelete,
              loading: busy,
              onPressed: () async {
                final ok = await ref
                    .read(profileViewModelProvider.notifier)
                    .deleteAccount();
                if (ok && context.mounted) Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.cardHi,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: palette.border),
                ),
                child: Text(
                  'Cancel',
                  style: EmberText.display(14, color: palette.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  const _DeleteButton({
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onPressed : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: enabled ? EmberSemantic.dangerFill : null,
          color: enabled ? null : palette.cardHi,
          borderRadius: BorderRadius.circular(11),
          border: enabled ? null : Border.all(color: palette.border),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: EmberSemantic.danger.withValues(alpha: 0.23),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Delete account',
                style: EmberText.display(
                  14,
                  color: enabled ? Colors.white : palette.dimmer,
                ),
              ),
      ),
    );
  }
}
