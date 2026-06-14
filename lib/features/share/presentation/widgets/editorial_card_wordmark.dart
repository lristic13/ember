import 'package:flutter/material.dart';

import '../../../../core/constants/editorial_card_style.dart';

/// The "ember" wordmark with a glowing accent dot, top-left on the card.
class EditorialCardWordmark extends StatelessWidget {
  final EditorialAccent accent;

  const EditorialCardWordmark({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'ember',
          style: EditorialCardText.display(22, letterSpacing: -0.8),
        ),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [accent.bright, accent.deep]),
            boxShadow: [BoxShadow(color: accent.mid, blurRadius: 10)],
          ),
        ),
      ],
    );
  }
}
