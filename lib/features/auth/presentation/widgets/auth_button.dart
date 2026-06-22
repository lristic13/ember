import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';
import 'apple_glyph.dart';
import 'google_glyph.dart';

/// Full-width Apple / Google sign-in button. Apple is a white fill with the
/// black glyph (HIG); Google is a `field` fill with a hairline border and the
/// four-colour G. Shows a spinner + [loadingLabel] while [loading].
class AuthButton extends StatelessWidget {
  final bool isApple;
  final String label;
  final String loadingLabel;
  final bool loading;
  final bool disabled;
  final VoidCallback onPressed;

  const AuthButton.apple({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingLabel = 'Connecting…',
    this.loading = false,
    this.disabled = false,
  }) : isApple = true;

  const AuthButton.google({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingLabel = 'Connecting…',
    this.loading = false,
    this.disabled = false,
  }) : isApple = false;

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final fg = isApple ? Colors.black : palette.text;
    final inactive = disabled || loading;

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: GestureDetector(
        onTap: inactive ? null : onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isApple ? Colors.white : palette.field,
            borderRadius: BorderRadius.circular(11),
            border: isApple ? null : Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              else if (isApple)
                const AppleGlyph(size: 16)
              else
                const GoogleGlyph(size: 15),
              const SizedBox(width: 9),
              Text(
                loading ? loadingLabel : label,
                style: EmberText.display(
                  13,
                  color: fg,
                  letterSpacingEm: -0.01,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
