/// Represents a single entry/log for a habit on a specific date.
class HabitEntry {
  final String id;
  final String habitId;
  final DateTime date;
  final double value;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.value,
  });

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    double? value,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          date == other.date &&
          value == other.value;

  @override
  int get hashCode =>
      id.hashCode ^ habitId.hashCode ^ date.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'HabitEntry{id: $id, habitId: $habitId, date: $date, value: $value}';
  }
}
