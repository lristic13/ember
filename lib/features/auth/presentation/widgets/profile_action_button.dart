import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';

/// Full-width action button on the Profile screen. Default is a neutral ghost
/// (Sign out); [danger] gives the destructive tinted variant (Delete account).
class ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onPressed;

  const ProfileActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final fg = danger ? EmberSemantic.dangerSoft : palette.text;
    final iconColor = danger ? EmberSemantic.danger : palette.dim;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: danger ? EmberSemantic.tint : palette.cardHi,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: danger ? EmberSemantic.line : palette.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: EmberText.display(14, color: fg, letterSpacingEm: -0.01),
            ),
          ],
        ),
      ),
    );
  }
}
