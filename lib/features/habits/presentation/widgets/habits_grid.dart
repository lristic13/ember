import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/habit.dart';
import 'habit_grid_card.dart';

class HabitsGrid extends StatelessWidget {
  final List<Habit> habits;

  const HabitsGrid({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
        AppDimensions.buttonHeightLg +
        AppDimensions.paddingMd * 2;

    return GridView.builder(
      padding: EdgeInsets.only(
        top: topPadding + AppDimensions.paddingMd,
        left: AppDimensions.paddingMd,
        right: AppDimensions.paddingMd,
        bottom: bottomPadding,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingSm,
        mainAxisSpacing: AppDimensions.paddingSm,
        childAspectRatio: 1,
      ),
      itemCount: habits.length,
      itemBuilder: (context, index) => HabitGridCard(habit: habits[index]),
    );
  }
}
