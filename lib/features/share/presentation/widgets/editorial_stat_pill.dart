import 'package:flutter/material.dart';

import '../../../../core/constants/editorial_card_style.dart';

/// A single translucent stat pill (label + value) in the Editorial card's
/// bottom row. Designed to sit in an [Expanded] within a Row.
class EditorialStatPill extends StatelessWidget {
  final String label;
  final String value;
  final EditorialAccent accent;

  const EditorialStatPill({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: accent.pillFill,
        border: Border.all(color: accent.pillBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: EditorialCardText.mono(6.7)),
          const SizedBox(height: 4),
          Text(
            value,
            style: EditorialCardText.display(
              13,
              color: EditorialCardColors.text,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
