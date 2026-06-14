import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../viewmodels/sort_mode_provider.dart';

/// Compact button showing the current sort mode; opens the sort sheet on tap.
class SortButton extends StatelessWidget {
  final VoidCallback onTap;
  final HabitsSortMode sortMode;

  const SortButton({super.key, required this.onTap, required this.sortMode});

  String get _sortLabel => switch (sortMode) {
    HabitsSortMode.name => AppStrings.sortByName,
    HabitsSortMode.recentlyCreated => AppStrings.sortByRecent,
    HabitsSortMode.custom => AppStrings.sortByCustom,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSm,
          vertical: AppDimensions.paddingXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppDimensions.paddingXs),
            Text(
              _sortLabel,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
