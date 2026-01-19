import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/habit_gradient_presets.dart';
import '../../../../core/constants/habit_gradients.dart';

class GradientPicker extends StatelessWidget {
  final String selectedGradientId;
  final ValueChanged<String> onGradientSelected;

  const GradientPicker({
    super.key,
    required this.selectedGradientId,
    required this.onGradientSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingSm,
      runSpacing: AppDimensions.paddingSm,
      children: HabitGradientPresets.all.map((gradient) {
        final isSelected = selectedGradientId == gradient.id;
        return _GradientOption(
          gradient: gradient,
          isSelected: isSelected,
          onTap: () => onGradientSelected(gradient.id),
        );
      }).toList(),
    );
  }
}

class _GradientOption extends StatelessWidget {
  final HabitGradient gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _GradientOption({
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: gradient.primaryColor,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.onSurface,
                  width: 3,
                )
              : Border.all(
                  color: theme.dividerColor,
                  width: 2,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.glow.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
