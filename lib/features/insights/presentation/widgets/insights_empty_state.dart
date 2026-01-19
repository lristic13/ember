import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class InsightsEmptyState extends StatelessWidget {
  const InsightsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppDimensions.paddingLg),
          Text(
            AppStrings.noInsightsYet,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSm),
          Text(
            AppStrings.noInsightsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
