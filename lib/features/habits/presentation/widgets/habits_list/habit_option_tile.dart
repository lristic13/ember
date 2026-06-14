import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';

class HabitOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const HabitOptionTile({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.paddingMd,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? theme.colorScheme.onSurface,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Text(
                label,
                style: TextStyle(
                  color: labelColor ?? theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
