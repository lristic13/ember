import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/habit.dart';
import 'habit_card.dart';

class HabitsList extends StatelessWidget {
  final List<Habit> habits;

  const HabitsList({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
        AppDimensions.buttonHeightLg +
        AppDimensions.paddingMd * 2;

    return ListView.separated(
      padding: EdgeInsets.only(
        top: topPadding + AppDimensions.paddingMd,
        left: AppDimensions.paddingMd,
        right: AppDimensions.paddingMd,
        bottom: bottomPadding,
      ),
      itemCount: habits.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimensions.marginSm),
      itemBuilder: (context, index) => HabitCard(habit: habits[index]),
    );
  }
}
