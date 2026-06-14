import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_dimensions.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../shared/widgets/glowing_brand_dot.dart';

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
            const GlowingBrandDot(),
            const SizedBox(height: AppDimensions.marginMd),
            Text(
              AppStrings.noActivities,
              style: AppTextStyles.headlineMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
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
