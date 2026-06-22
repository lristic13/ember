import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';

/// A compact Accept / Decline button for [InviteCard]. [filled] uses the ember
/// gradient (Accept); otherwise a `field`-filled ghost (Decline).
class InviteActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const InviteActionButton({
    super.key,
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final fg = filled ? EmberAccent.ink : palette.text;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: filled ? EmberGradients.accent155 : null,
          color: filled ? null : palette.field,
          borderRadius: BorderRadius.circular(11),
          border: filled ? null : Border.all(color: palette.border),
        ),
        child: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            : Text(
                label,
                style: EmberText.display(14, color: fg, letterSpacingEm: -0.01),
              ),
      ),
    );
  }
}
