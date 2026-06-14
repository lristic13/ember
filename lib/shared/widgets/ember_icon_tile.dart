import 'package:flutter/material.dart';

import '../../core/theme/ember_tokens.dart';

/// A rounded gradient tile showing a habit's emoji, tinted in the habit's
/// identity color. Falls back to a flame glyph when the habit has no emoji.
class EmberIconTile extends StatelessWidget {
  final String? emoji;
  final HabitColor color;
  final double size;

  const EmberIconTile({
    super.key,
    required this.emoji,
    required this.color,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final hasEmoji = emoji != null && emoji!.trim().isNotEmpty;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: color.fill,
        boxShadow: [
          BoxShadow(
            color: color.base.withValues(alpha: 0.2),
            blurRadius: size * 0.34,
            offset: Offset(0, size * 0.13),
          ),
        ],
      ),
      child: hasEmoji
          ? Text(emoji!, style: TextStyle(fontSize: size * 0.5))
          : Icon(
              Icons.local_fire_department,
              size: size * 0.5,
              color: color.ink,
            ),
    );
  }
}
