import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../viewmodels/sort_mode_provider.dart';
import 'sort_option_tile.dart';

/// Shows the bottom sheet for choosing how the habits list is sorted.
void showHabitSortSheet(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final currentSort = ref.read(habitsSortModeProvider);

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sortBy,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSm),
            SortOptionTile(
              title: AppStrings.sortByName,
              icon: Icons.sort_by_alpha,
              isSelected: currentSort == HabitsSortMode.name,
              onTap: () {
                ref
                    .read(habitsSortModeProvider.notifier)
                    .setSort(HabitsSortMode.name);
                Navigator.pop(context);
              },
            ),
            SortOptionTile(
              title: AppStrings.sortByRecent,
              icon: Icons.schedule,
              isSelected: currentSort == HabitsSortMode.recentlyCreated,
              onTap: () {
                ref
                    .read(habitsSortModeProvider.notifier)
                    .setSort(HabitsSortMode.recentlyCreated);
                Navigator.pop(context);
              },
            ),
            SortOptionTile(
              title: AppStrings.sortByCustom,
              icon: Icons.drag_handle,
              isSelected: currentSort == HabitsSortMode.custom,
              onTap: () {
                ref
                    .read(habitsSortModeProvider.notifier)
                    .setSort(HabitsSortMode.custom);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

