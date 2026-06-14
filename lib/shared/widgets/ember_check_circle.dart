import 'package:flutter/material.dart';

import '../../core/theme/ember_tokens.dart';

/// Circular completion toggle: a filled habit-color disc with a checkmark when
/// done, or a hollow ring when not. Visual is [size]; the tap target is ≥44pt.
class EmberCheckCircle extends StatelessWidget {
  final bool done;
  final HabitColor color;
  final double size;
  final VoidCallback? onTap;

  const EmberCheckCircle({
    super.key,
    required this.done,
    required this.color,
    this.size = 34,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: done ? color.fill : null,
        border: done ? null : Border.all(color: palette.dimmer, width: 2),
        boxShadow: done
            ? [BoxShadow(color: color.base.withValues(alpha: 0.45), blurRadius: 16)]
            : null,
      ),
      child: done
          ? Icon(Icons.check_rounded, size: size * 0.56, color: color.ink)
          : null,
    );

    if (onTap == null) return circle;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size < 44 ? 44 : size,
        height: size < 44 ? 44 : size,
        child: Center(child: circle),
      ),
    );
  }
}
