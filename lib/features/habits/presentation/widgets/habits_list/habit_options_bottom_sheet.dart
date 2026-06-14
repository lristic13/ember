import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import 'habit_option_tile.dart';

enum HabitOptionResult {
  delete,
  cancel,
}

class HabitOptionsBottomSheet extends StatelessWidget {
  const HabitOptionsBottomSheet({super.key});

  static Future<HabitOptionResult?> show(BuildContext context) {
    return showModalBottomSheet<HabitOptionResult>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (context) => const HabitOptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLg),
            HabitOptionTile(
              icon: Icons.delete_outline,
              label: AppStrings.deleteActivity,
              iconColor: theme.colorScheme.error,
              labelColor: theme.colorScheme.error,
              onTap: () => Navigator.of(context).pop(HabitOptionResult.delete),
            ),
            const SizedBox(height: AppDimensions.paddingSm),
            HabitOptionTile(
              icon: Icons.close,
              label: AppStrings.cancel,
              onTap: () => Navigator.of(context).pop(HabitOptionResult.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

