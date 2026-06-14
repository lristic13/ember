import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'habit_order_provider.dart';

part 'sort_mode_provider.g.dart';

enum HabitsSortMode {
  name,
  recentlyCreated,
  custom,
}

@riverpod
class HabitsSortModeNotifier extends _$HabitsSortModeNotifier {
  static const _key = 'sort_mode';

  @override
  HabitsSortMode build() {
    final stored = Hive.box<dynamic>(HabitsOrderNotifier.boxName).get(_key);
    if (stored is int && stored < HabitsSortMode.values.length) {
      return HabitsSortMode.values[stored];
    }
    return HabitsSortMode.recentlyCreated;
  }

  void setSort(HabitsSortMode mode) {
    state = mode;
    Hive.box<dynamic>(HabitsOrderNotifier.boxName).put(_key, mode.index);
  }
}
