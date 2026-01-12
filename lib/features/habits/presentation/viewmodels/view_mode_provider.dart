import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_mode_provider.g.dart';

enum HabitsViewMode { week, month }

@riverpod
class HabitsViewModeNotifier extends _$HabitsViewModeNotifier {
  @override
  HabitsViewMode build() => HabitsViewMode.week;

  void toggle() {
    state = state == HabitsViewMode.week
        ? HabitsViewMode.month
        : HabitsViewMode.week;
  }
}
