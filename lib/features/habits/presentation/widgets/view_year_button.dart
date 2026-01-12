import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';

class ViewYearButton extends StatelessWidget {
  final String habitId;
  final Color color;

  const ViewYearButton({super.key, required this.habitId, required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.push(AppRoutes.yearHeatmapPath(habitId)),
      icon: const Icon(Icons.calendar_month),
      label: const Text(AppStrings.viewYear),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
      ),
    );
  }
}
