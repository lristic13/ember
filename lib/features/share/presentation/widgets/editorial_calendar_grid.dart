import 'package:flutter/material.dart';

import '../../../../core/constants/editorial_card_style.dart';
import 'editorial_day_cell.dart';

/// Monday-start month grid for the Editorial card: a weekday header row above a
/// wrapped grid of [EditorialDayCell]s.
class EditorialCalendarGrid extends StatelessWidget {
  final Set<int> loggedDays;
  final int leadingBlanks;
  final int daysInMonth;
  final double cell;
  final double gap;
  final EditorialAccent accent;

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const EditorialCalendarGrid({
    super.key,
    required this.loggedDays,
    required this.leadingBlanks,
    required this.daysInMonth,
    required this.cell,
    required this.gap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++)
        SizedBox(width: cell, height: cell),
      for (var d = 1; d <= daysInMonth; d++)
        EditorialDayCell(
          day: d,
          logged: loggedDays.contains(d),
          size: cell,
          accent: accent,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _weekdays.length; i++)
              Container(
                width: cell,
                margin: EdgeInsets.only(right: i == _weekdays.length - 1 ? 0 : gap),
                alignment: Alignment.center,
                child: Text(_weekdays[i], style: EditorialCardText.mono(cell * 0.2)),
              ),
          ],
        ),
        SizedBox(height: gap),
        Wrap(spacing: gap, runSpacing: gap, children: cells),
      ],
    );
  }
}
