import 'package:flutter/material.dart';

import '../../core/theme/ember_tokens.dart';

/// A 40×40 rounded icon button on the raised card surface, used in headers.
/// Keeps a ≥44pt tap target while rendering at 40pt.
class EmberIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  const EmberIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    Widget button = Material(
      color: palette.cardHi,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: child,
        ),
      ),
    );
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
