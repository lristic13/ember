import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class HabitsEmptyState extends StatelessWidget {
  const HabitsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 64,
              color: AppColors.emberMedium,
            ),
            const SizedBox(height: AppDimensions.marginMd),
            Text(
              AppStrings.noHabits,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppDimensions.marginSm),
            Text(
              AppStrings.noHabitsSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
