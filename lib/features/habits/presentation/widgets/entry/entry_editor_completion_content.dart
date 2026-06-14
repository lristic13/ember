import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import 'entry_editor_completion_button.dart';

/// Done / Not done toggle buttons for completion-type habits.
class EntryEditorCompletionContent extends StatelessWidget {
  final bool isCompleted;
  final bool isSaving;
  final void Function(bool completed) onSave;

  const EntryEditorCompletionContent({
    super.key,
    required this.isCompleted,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toggle buttons
        Row(
          children: [
            Expanded(
              child: EntryEditorCompletionButton(
                label: AppStrings.markAsDone,
                icon: Icons.check_circle_outline,
                isSelected: isCompleted,
                isLoading: isSaving && isCompleted,
                onTap: isSaving ? null : () => onSave(true),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMd),
            Expanded(
              child: EntryEditorCompletionButton(
                label: AppStrings.markAsNotDone,
                icon: Icons.cancel_outlined,
                isSelected: !isCompleted,
                isLoading: isSaving && !isCompleted,
                onTap: isSaving ? null : () => onSave(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
