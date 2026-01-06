import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/presentation/screens/habits_screen.dart';
import '../../features/habits/presentation/screens/create_habit_screen.dart';
import '../../features/habits/presentation/screens/edit_habit_screen.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String habits = '/habits';
  static const String createHabit = '/habits/create';
  static const String editHabit = '/habits/edit/:id';

  static String editHabitPath(String id) => '/habits/edit/$id';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HabitsScreen(),
    ),
    GoRoute(
      path: AppRoutes.habits,
      builder: (context, state) => const HabitsScreen(),
    ),
    GoRoute(
      path: AppRoutes.createHabit,
      builder: (context, state) => const CreateHabitScreen(),
    ),
    GoRoute(
      path: AppRoutes.editHabit,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditHabitScreen(habitId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);
