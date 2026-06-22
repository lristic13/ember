import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/completion_mode.dart';

/// Segmented Everyone / Anyone switch for editing a shared completion habit's
/// completion rule.
class CompletionModeToggle extends StatelessWidget {
  final HabitCompletionMode mode;
  final ValueChanged<HabitCompletionMode> onChanged;

  const CompletionModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          _Segment(
            label: AppStrings.typeEveryone,
            selected: mode == HabitCompletionMode.all,
            onTap: () => onChanged(HabitCompletionMode.all),
          ),
          _Segment(
            label: AppStrings.typeAnyone,
            selected: mode == HabitCompletionMode.any,
            onTap: () => onChanged(HabitCompletionMode.any),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? EmberGradients.accent155 : null,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: EmberText.display(
              13,
              color: selected ? EmberAccent.ink : palette.dim,
            ),
          ),
        ),
      ),
    );
  }
}
