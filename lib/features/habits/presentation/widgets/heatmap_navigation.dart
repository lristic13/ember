import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

class HeatmapNavigation extends StatelessWidget {
  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Widget? trailing;

  const HeatmapNavigation({
    super.key,
    required this.title,
    required this.onPrevious,
    required this.onNext,
    this.trailing,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              iconSize: AppDimensions.iconMd,
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}
