import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import 'editorial_share_card.dart';

/// Full screen preview of the share card scaled to fit.
class ShareFullPreviewScreen extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final int year;
  final int month;

  const ShareFullPreviewScreen({
    super.key,
    required this.habit,
    required this.entries,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: EditorialShareCard(
            habit: habit,
            entries: entries,
            year: year,
            month: month,
          ),
        ),
      ),
    );
  }
}
