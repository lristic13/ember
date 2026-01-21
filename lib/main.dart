import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/habits/data/datasources/habit_local_datasource.dart';
import 'features/habits/data/models/habit_entry_model.dart';
import 'features/habits/data/models/habit_model.dart';
import 'features/widgets/presentation/providers/home_widget_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeHive();

  // Create provider container for widget initialization
  final container = ProviderContainer();

  // Initialize home widget service
  await _initializeHomeWidget(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EmberApp(),
    ),
  );
}

Future<void> _initializeHomeWidget(ProviderContainer container) async {
  final homeWidgetService = container.read(homeWidgetServiceProvider);

  // Initialize the service (sets App Group ID and registers click listener)
  await homeWidgetService.initialize();

  // Update all widgets with current data
  await homeWidgetService.updateAllWidgets();

  // Check if app was launched from widget click
  final initialUri = await homeWidgetService.getInitialUri();
  if (initialUri != null) {
    _handleWidgetUri(initialUri, container);
  }

  // Listen for widget clicks while app is running
  HomeWidget.widgetClicked.listen((uri) {
    if (uri != null) {
      _handleWidgetUri(uri, container);
    }
  });
}

void _handleWidgetUri(Uri uri, ProviderContainer container) {
  final action = uri.host;
  final habitId = uri.queryParameters['habitId'];

  if (habitId == null) return;

  switch (action) {
    case 'log':
      // Quick log is handled by the service
      final service = container.read(homeWidgetServiceProvider);
      service.updateActivityWidget(habitId);
      break;
    case 'open':
      // Navigate to activity detail - handled by router
      appRouter.go('/habits/$habitId');
      break;
  }
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(HabitEntryModelAdapter());

  await Hive.openBox<HabitModel>(HabitLocalDatasourceImpl.habitsBoxName);
  await Hive.openBox<HabitEntryModel>(HabitLocalDatasourceImpl.entriesBoxName);
}

class EmberApp extends ConsumerWidget {
  const EmberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'ember.',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
