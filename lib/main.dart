import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/habits/data/datasources/habit_local_datasource.dart';
import 'features/habits/data/models/habit_entry_model.dart';
import 'features/habits/data/models/habit_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeHive();

  runApp(const ProviderScope(child: EmberApp()));
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
