import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_order_provider.g.dart';

@riverpod
class HabitsOrderNotifier extends _$HabitsOrderNotifier {
  static const boxName = 'habit_order';
  static const _key = 'order';

  @override
  List<String> build() {
    final stored = Hive.box<dynamic>(boxName).get(_key);
    if (stored is List) return List<String>.from(stored);
    return [];
  }

  void reorder(List<String> displayedIds, int oldIndex, int newIndex) {
    final list = List<String>.from(displayedIds);
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    _persist(list);
  }

  /// Stores an already-ordered list of ids (e.g. from the grid's drag result).
  void setOrder(List<String> orderedIds) => _persist(List<String>.from(orderedIds));

  void _persist(List<String> list) {
    state = list;
    Hive.box<dynamic>(boxName).put(_key, list);
  }
}
