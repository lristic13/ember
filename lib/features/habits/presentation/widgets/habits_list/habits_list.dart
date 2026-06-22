import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habit_order_provider.dart';
import '../../viewmodels/search_query_provider.dart';
import '../../viewmodels/sort_mode_provider.dart';
import 'habit_card.dart';

class HabitsList extends ConsumerWidget {
  final List<Habit> habits;

  const HabitsList({super.key, required this.habits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortMode = ref.watch(habitsSortModeProvider);
    // Reordering a search-filtered subset would corrupt the saved order.
    final searching = ref.watch(habitsSearchQueryProvider).trim().isNotEmpty;
    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
        AppDimensions.buttonHeightLg +
        AppDimensions.paddingMd * 2;

    if (sortMode == HabitsSortMode.custom && !searching) {
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
        proxyDecorator: _liftedCardDecorator,
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

/// Lifts a dragged habit card with a rounded shadow that matches the card's
/// 22px corners (the default proxy uses a square `Material`, so its shadow
/// shows square corners behind the rounded card).
Widget _liftedCardDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, innerChild) {
      final t = Curves.easeInOut.transform(animation.value);
      return Material(
        color: Colors.transparent,
        elevation: t * 12,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        child: innerChild,
      );
    },
    child: child,
  );
}
