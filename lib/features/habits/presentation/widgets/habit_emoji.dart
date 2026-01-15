import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class HabitEmoji extends StatelessWidget {
  final String? emoji;
  final Color? color;

  const HabitEmoji({super.key, this.emoji, this.color});

  @override
  Widget build(BuildContext context) {
    if (emoji != null && emoji!.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        alignment: Alignment.center,
        child: Text(emoji!, style: const TextStyle(fontSize: 24)),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color ?? AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.local_fire_department,
        color: AppColors.textPrimary,
        size: AppDimensions.iconMd,
        shadows: [
          Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8),
          Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
    );
  }
}
