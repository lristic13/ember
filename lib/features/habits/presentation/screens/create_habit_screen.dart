import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habit_form.dart';

class CreateHabitScreen extends ConsumerWidget {
  const CreateHabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              title: const Text(
                AppStrings.createActivity,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding + AppDimensions.paddingMd,
              left: AppDimensions.paddingMd,
              right: AppDimensions.paddingMd,
              bottom: AppDimensions.paddingMd,
            ),
            child: HabitForm(
              onSubmit: (name, trackingType, unit, emoji, gradientId) async {
                final habit = Habit(
                  id: const Uuid().v4(),
                  name: name,
                  trackingType: trackingType,
                  unit: unit,
                  emoji: emoji,
                  gradientId: gradientId,
                  createdAt: DateTime.now(),
                );

                final success = await ref
                    .read(habitsViewModelProvider.notifier)
                    .createHabit(habit);

                if (success && context.mounted) {
                  context.pop();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
