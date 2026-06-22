import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';

/// The primary ember-gradient button. Disabled → `cardHi` fill, `dimmer` text,
/// no glow. Optionally shows a trailing arrow or a spinner while [loading].
class EmberPrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final bool arrow;
  final VoidCallback onPressed;

  const EmberPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.arrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final active = enabled && !loading;
    final fg = enabled ? EmberAccent.ink : palette.dimmer;

    return GestureDetector(
      onTap: active ? onPressed : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: enabled ? EmberGradients.accent155 : null,
          color: enabled ? null : palette.cardHi,
          borderRadius: BorderRadius.circular(11),
          border: enabled ? null : Border.all(color: palette.border),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: EmberAccent.glow(0.27),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            else ...[
              Text(
                label,
                style: EmberText.display(14, color: fg, letterSpacingEm: -0.01),
              ),
              if (arrow) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18, color: fg),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
