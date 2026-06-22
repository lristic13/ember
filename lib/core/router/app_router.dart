import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';

import '../../features/auth/presentation/viewmodels/auth_providers.dart';
import '../../features/habits/presentation/screens/create_habit_screen.dart';
import '../../features/habits/presentation/screens/edit_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_details_screen.dart';
import '../../features/habits/presentation/screens/habits_screen.dart';
import '../../features/habits/presentation/screens/invites_screen.dart';
import '../../features/auth/presentation/screens/handle_setup_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/habits/presentation/screens/year_heatmap_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String habits = '/habits';
  static const String createHabit = '/habits/create';
  static const String habitDetails = '/habits/:id';
  static const String editHabit = '/habits/:id/edit';
  static const String yearHeatmap = '/habits/:id/year';
  static const String insights = '/insights';
  static const String splash = '/splash';
  static const String signIn = '/signin';
  static const String handleSetup = '/handle-setup';
  static const String profile = '/profile';
  static const String invites = '/invites';

  static String habitDetailsPath(String id) => '/habits/$id';
  static String editHabitPath(String id) => '/habits/$id/edit';
  static String yearHeatmapPath(String id) => '/habits/$id/year';
}

final _upgrader = Upgrader();

/// Set by `main()` so the router redirect can read auth state.
ProviderContainer? gRouterContainer;

/// Bumped whenever auth state changes so GoRouter re-runs its redirect.
final gAuthRefresh = ValueNotifier<int>(0);

/// Login wall. Gates the whole app against auth state:
/// - auth still resolving → hold on the splash (no home flash);
/// - signed out → forced to sign in;
/// - signed in without a handle → forced to finish handle setup;
/// - signed in with a handle but stranded on splash/auth screen → home.
String? _accountGuard(BuildContext context, GoRouterState state) {
  final container = gRouterContainer;
  if (container == null) return null;

  final auth = container.read(authStateProvider);
  final loc = state.matchedLocation;

  if (auth.isLoading) {
    return loc == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final user = auth.asData?.value;

  if (user == null) {
    return loc == AppRoutes.signIn ? null : AppRoutes.signIn;
  }
  if (!user.hasHandle) {
    return loc == AppRoutes.handleSetup ? null : AppRoutes.handleSetup;
  }
  if (loc == AppRoutes.splash ||
      loc == AppRoutes.signIn ||
      loc == AppRoutes.handleSetup) {
    return AppRoutes.home;
  }
  return null;
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: gAuthRefresh,
  redirect: _accountGuard,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => UpgradeAlert(
        upgrader: _upgrader,
        dialogStyle: Platform.isIOS
            ? UpgradeDialogStyle.cupertino
            : UpgradeDialogStyle.material,
        showReleaseNotes: true,
        showLater: false,
        showIgnore: false,
        child: const HabitsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.habits,
      builder: (context, state) => const HabitsScreen(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.handleSetup,
      builder: (context, state) => const HandleSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.invites,
      builder: (context, state) => const InvitesScreen(),
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
    GoRoute(
      path: AppRoutes.insights,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const InsightsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
);
