import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../habits/presentation/viewmodels/habits_providers.dart';
import '../../domain/usecases/get_activity_insights.dart';

final getActivityInsightsProvider = Provider<GetActivityInsights>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetActivityInsights(repository);
});
