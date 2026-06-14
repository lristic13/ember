import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/habit_gradient_presets.dart';
import 'gradient_picker_sheet.dart';

class GradientPicker extends StatelessWidget {
  final String selectedGradientId;
  final ValueChanged<String> onGradientSelected;

  const GradientPicker({
    super.key,
    required this.selectedGradientId,
    required this.onGradientSelected,
  });

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GradientPickerSheet(
        selectedGradientId: selectedGradientId,
        onGradientSelected: (id) {
          onGradientSelected(id);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = HabitGradientPresets.getById(selectedGradientId);

    return GestureDetector(
      onTap: () => _openSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),

        height: 48,
        decoration: BoxDecoration(
          color: selected.primaryColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: selected.glow.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
