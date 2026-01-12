import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/habit.dart';
import 'habit_grid_card.dart';

class HabitsGrid extends StatelessWidget {
  final List<Habit> habits;

  const HabitsGrid({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
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
