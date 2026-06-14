import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habit_order_provider.dart';
import '../../viewmodels/sort_mode_provider.dart';
import 'habit_card.dart';

class HabitsList extends ConsumerWidget {
  final List<Habit> habits;

  const HabitsList({super.key, required this.habits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortMode = ref.watch(habitsSortModeProvider);
    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
        AppDimensions.buttonHeightLg +
        AppDimensions.paddingMd * 2;

    if (sortMode == HabitsSortMode.custom) {
      return ReorderableListView.builder(
        padding: EdgeInsets.only(
          top: 20,
          left: AppDimensions.paddingMd,
          right: AppDimensions.paddingMd,
          bottom: bottomPadding,
        ),
        itemCount: habits.length,
        onReorder: (oldIndex, newIndex) {
          final ids = habits.map((h) => h.id).toList();
          ref.read(habitsOrderProvider.notifier).reorder(ids, oldIndex, newIndex);
        },
        itemBuilder: (context, index) => Padding(
          key: ValueKey(habits[index].id),
          padding: EdgeInsets.only(
            bottom: index < habits.length - 1 ? AppDimensions.marginSm : 0,
          ),
          child: HabitCard(habit: habits[index]),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        top: 20,
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
