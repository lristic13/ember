import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/habit_gradient_presets.dart';

class GradientPickerSheet extends StatelessWidget {
  final String selectedGradientId;
  final ValueChanged<String> onGradientSelected;

  const GradientPickerSheet({
    super.key,
    required this.selectedGradientId,
    required this.onGradientSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMd),
            Wrap(
              spacing: AppDimensions.marginMd,
              runSpacing: AppDimensions.marginMd,
              children: HabitGradientPresets.all.map((gradient) {
                final isSelected = selectedGradientId == gradient.id;
                return GestureDetector(
                  onTap: () => onGradientSelected(gradient.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: gradient.primaryColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: gradient.glow.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.marginSm),
          ],
        ),
      ),
    );
  }
}
