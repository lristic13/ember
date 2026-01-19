import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

class HeatmapNavigation extends StatelessWidget {
  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const HeatmapNavigation({
    super.key,
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          iconSize: AppDimensions.iconMd,
        ),
        Text(
          title,
          style: AppTextStyles.titleLarge,
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          iconSize: AppDimensions.iconMd,
        ),
      ],
    );
  }
}
