import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habit_order_provider.dart';
import '../../viewmodels/sort_mode_provider.dart';
import 'habit_grid_card.dart';

class HabitsGrid extends ConsumerStatefulWidget {
  final List<Habit> habits;

  const HabitsGrid({super.key, required this.habits});

  @override
  ConsumerState<HabitsGrid> createState() => _HabitsGridState();
}

class _HabitsGridState extends ConsumerState<HabitsGrid> {
  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: AppDimensions.paddingSm,
    mainAxisSpacing: AppDimensions.paddingSm,
    childAspectRatio: 1,
  );

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  EdgeInsets _padding(BuildContext context) {
    final bottom =
        MediaQuery.of(context).padding.bottom +
        AppDimensions.buttonHeightLg +
        AppDimensions.paddingMd * 2;
    return EdgeInsets.only(
      top: 20,
      left: AppDimensions.paddingMd,
      right: AppDimensions.paddingMd,
      bottom: bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortMode = ref.watch(habitsSortModeProvider);

    // Reordering only makes sense in custom order — every other mode is derived.
    if (sortMode != HabitsSortMode.custom) {
      return GridView.builder(
        padding: _padding(context),
        gridDelegate: _gridDelegate,
        itemCount: widget.habits.length,
        itemBuilder: (context, index) =>
            HabitGridCard(habit: widget.habits[index]),
      );
    }

    final children = [
      for (final habit in widget.habits)
        HabitGridCard(key: ValueKey(habit.id), habit: habit),
    ];

    return ReorderableBuilder(
      scrollController: _scrollController,
      dragChildBoxDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      onReorder: (ReorderedListFunction reorderedListFunction) {
        final reordered = reorderedListFunction(widget.habits) as List<Habit>;
        ref
            .read(habitsOrderProvider.notifier)
            .setOrder(reordered.map((h) => h.id).toList());
      },
      children: children,
      builder: (children) {
        return GridView(
          key: _gridViewKey,
          controller: _scrollController,
          padding: _padding(context),
          gridDelegate: _gridDelegate,
          children: children,
        );
      },
    );
  }
}
