import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/ember_tokens.dart';

/// Secondary action button (subtle, not the accent primary language).
class ViewYearButton extends StatelessWidget {
  final String habitId;
  final Color color;

  const ViewYearButton({super.key, required this.habitId, required this.color});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return Material(
      color: palette.cardHi,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push(AppRoutes.yearHeatmapPath(habitId)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Text(
            'View full year',
            style: EmberText.display(15, color: palette.text),
          ),
        ),
      ),
    );
  }
}
