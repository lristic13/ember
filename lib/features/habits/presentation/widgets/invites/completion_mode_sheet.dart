import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/completion_mode.dart';

/// Asks how a habit being shared should complete — Everyone (all check in) or
/// Anyone (one check counts). Used when promoting a personal habit on invite.
Future<HabitCompletionMode?> showCompletionModeSheet(BuildContext context) {
  return showModalBottomSheet<HabitCompletionMode>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const CompletionModeSheet(),
  );
}

class CompletionModeSheet extends StatelessWidget {
  const CompletionModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'How should it work?',
                style: EmberText.display(20, color: palette.text),
              ),
            ),
            const SizedBox(height: 16),
            _ModeOption(
              icon: Icons.groups_2_outlined,
              title: AppStrings.typeEveryone,
              description: AppStrings.typeEveryoneDesc,
              onTap: () => Navigator.of(context).pop(HabitCompletionMode.all),
            ),
            const SizedBox(height: 10),
            _ModeOption(
              icon: Icons.local_fire_department_outlined,
              title: AppStrings.typeAnyone,
              description: AppStrings.typeAnyoneDesc,
              onTap: () => Navigator.of(context).pop(HabitCompletionMode.any),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: palette.field,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: palette.text),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: EmberText.display(16, color: palette.text)),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: EmberText.mono(11, color: palette.dim),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 22, color: palette.dimmer),
          ],
        ),
      ),
    );
  }
}
