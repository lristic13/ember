import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class HabitsEmptyState extends StatelessWidget {
  const HabitsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppDimensions.marginMd),
            Text(AppStrings.noActivities, style: AppTextStyles.headlineMedium.copyWith(
              color: theme.colorScheme.onSurface,
            )),
            const SizedBox(height: AppDimensions.marginSm),
            Text(
              AppStrings.noActivitiesSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
