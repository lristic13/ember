import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/presentation/screens/create_habit_screen.dart';
import '../../features/habits/presentation/screens/edit_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_details_screen.dart';
import '../../features/habits/presentation/screens/habits_screen.dart';
import '../../features/habits/presentation/screens/year_heatmap_screen.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String habits = '/habits';
  static const String createHabit = '/habits/create';
  static const String habitDetails = '/habits/:id';
  static const String editHabit = '/habits/:id/edit';
  static const String yearHeatmap = '/habits/:id/year';

  static String habitDetailsPath(String id) => '/habits/$id';
  static String editHabitPath(String id) => '/habits/$id/edit';
  static String yearHeatmapPath(String id) => '/habits/$id/year';
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
      path: AppRoutes.habitDetails,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return HabitDetailsScreen(habitId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.editHabit,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditHabitScreen(habitId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.yearHeatmap,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return YearHeatmapScreen(habitId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);
