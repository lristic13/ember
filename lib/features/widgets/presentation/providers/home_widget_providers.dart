import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../habits/presentation/viewmodels/habits_providers.dart';
import '../../data/services/home_widget_service.dart';

/// Provider for the HomeWidgetService.
/// This service manages home screen widget data synchronization.
final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HomeWidgetService(habitRepository: repository);
});
