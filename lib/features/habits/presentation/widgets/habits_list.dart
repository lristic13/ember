import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/habit.dart';
import 'habit_card.dart';

class HabitsList extends StatelessWidget {
  final List<Habit> habits;

  const HabitsList({
    super.key,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      itemCount: habits.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: AppDimensions.marginSm,
      ),
      itemBuilder: (context, index) => HabitCard(habit: habits[index]),
    );
  }
}
