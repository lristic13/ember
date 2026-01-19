import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../habits/presentation/viewmodels/habits_providers.dart';
import '../../domain/usecases/share_heat_map.dart';

/// Provider for the ShareHeatMap use case.
final shareHeatMapProvider = Provider<ShareHeatMap>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return ShareHeatMap(repository);
});
