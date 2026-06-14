import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';

class EntryEditorCompletionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  const EntryEditorCompletionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingLg,
          horizontal: AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                icon,
                size: 32,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            const SizedBox(height: AppDimensions.paddingSm),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
