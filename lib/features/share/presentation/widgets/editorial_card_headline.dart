import 'package:flutter/material.dart';

import '../../../../core/constants/editorial_card_style.dart';

/// Three-line editorial headline: the habit name (muted), the day count
/// (accent), and the month (white) — e.g. "Reading / 12 days / in June.".
class EditorialCardHeadline extends StatelessWidget {
  final String habitName;
  final int daysLogged;
  final String monthName;
  final EditorialAccent accent;

  const EditorialCardHeadline({
    super.key,
    required this.habitName,
    required this.daysLogged,
    required this.monthName,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = daysLogged == 1 ? '1 day' : '$daysLogged days';

    return RichText(
      text: TextSpan(
        style: EditorialCardText.display(39, height: 0.92, letterSpacing: -2),
        children: [
          TextSpan(
            text: '$habitName\n',
            style: const TextStyle(color: EditorialCardColors.dim),
          ),
          TextSpan(
            text: '$dayLabel\n',
            style: TextStyle(color: accent.mid),
          ),
          TextSpan(
            text: 'in $monthName.',
            style: const TextStyle(color: EditorialCardColors.text),
          ),
        ],
      ),
    );
  }
}
