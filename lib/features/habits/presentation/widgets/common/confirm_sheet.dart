import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';

/// A generic confirm/cancel bottom sheet. Returns `true` when confirmed.
/// [danger] tints the confirm button destructively.
class ConfirmSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool danger;

  const ConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.danger = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        danger: danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final confirmFg = danger ? EmberSemantic.ink : EmberAccent.ink;

    return Container(
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
            Text(title, style: EmberText.display(20, color: palette.text)),
            const SizedBox(height: 8),
            Text(message, style: EmberText.mono(12, color: palette.dim)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: danger
                      ? EmberSemantic.dangerFill
                      : EmberGradients.accent155,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  confirmLabel,
                  style: EmberText.display(14, color: confirmFg),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text(
                  'Cancel',
                  style: EmberText.display(14, color: palette.dim),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
