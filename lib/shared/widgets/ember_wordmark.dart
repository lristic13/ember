import 'package:flutter/material.dart';

import '../../core/theme/ember_tokens.dart';

/// The "ember" wordmark with a glowing brand-accent dot.
class EmberWordmark extends StatelessWidget {
  final double size;

  const EmberWordmark({super.key, this.size = 23});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'ember',
          style: EmberText.display(
            size,
            color: palette.text,
            letterSpacingEm: -0.04,
          ),
        ),
        SizedBox(width: size * 0.32),
        Container(
          width: size * 0.36,
          height: size * 0.36,
          margin: EdgeInsets.only(top: size * 0.1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [EmberAccent.bright, EmberAccent.deep],
            ),
            boxShadow: [
              BoxShadow(color: EmberAccent.neon, blurRadius: size * 0.5),
            ],
          ),
        ),
      ],
    );
  }
}
