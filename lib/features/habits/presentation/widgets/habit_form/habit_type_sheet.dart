import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/ember_tokens.dart';

/// What kind of habit the user is creating.
enum HabitCreateType { personal, everyone, anyone }

/// First step of creating a habit: pick Personal / Everyone / Anyone. Each
/// option explains itself, so the labels don't have to. Tapping picks it.
Future<HabitCreateType?> showHabitTypeSheet(BuildContext context) {
  return showModalBottomSheet<HabitCreateType>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const HabitTypeSheet(),
  );
}

class HabitTypeSheet extends StatelessWidget {
  const HabitTypeSheet({super.key});

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
                AppStrings.chooseHabitType,
                style: EmberText.display(20, color: palette.text),
              ),
            ),
            const SizedBox(height: 16),
            _TypeOption(
              icon: Icons.person_outline_rounded,
              title: AppStrings.typePersonal,
              description: AppStrings.typePersonalDesc,
              onTap: () => Navigator.of(context).pop(HabitCreateType.personal),
            ),
            const SizedBox(height: 10),
            _TypeOption(
              icon: Icons.groups_2_outlined,
              title: AppStrings.typeEveryone,
              description: AppStrings.typeEveryoneDesc,
              onTap: () => Navigator.of(context).pop(HabitCreateType.everyone),
            ),
            const SizedBox(height: 10),
            _TypeOption(
              icon: Icons.local_fire_department_outlined,
              title: AppStrings.typeAnyone,
              description: AppStrings.typeAnyoneDesc,
              onTap: () => Navigator.of(context).pop(HabitCreateType.anyone),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _TypeOption({
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
