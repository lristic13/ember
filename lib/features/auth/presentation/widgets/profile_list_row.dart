import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';

/// A tappable card row on the Profile screen: an icon tile, a label + subtitle,
/// and an optional trailing widget (e.g. a chevron).
class ProfileListRow extends StatelessWidget {
  final IconData icon;
  final Color? tint;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileListRow({
    super.key,
    required this.icon,
    required this.label,
    this.tint,
    this.iconColor = EmberAccent.bright,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 31,
              height: 31,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint ?? palette.cardHi,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: EmberText.display(
                      14,
                      color: palette.text,
                      letterSpacingEm: -0.01,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: EmberText.display(
                        10,
                        color: palette.dim,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
