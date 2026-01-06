sealed class HabitEntriesState {
  const HabitEntriesState();
}

final class HabitEntriesInitial extends HabitEntriesState {
  const HabitEntriesInitial();
}

final class HabitEntriesLoading extends HabitEntriesState {
  const HabitEntriesLoading();
}

final class HabitEntriesLoaded extends HabitEntriesState {
  /// Map of date (normalized to midnight) to entry value.
  final Map<DateTime, double> entriesByDate;

  const HabitEntriesLoaded(this.entriesByDate);

  /// Gets the value for a specific date, or 0 if no entry exists.
  double getValueForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return entriesByDate[normalizedDate] ?? 0;
  }

  /// Creates a copy with an updated entry.
  HabitEntriesLoaded copyWithEntry(DateTime date, double value) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final newEntries = Map<DateTime, double>.from(entriesByDate);
    newEntries[normalizedDate] = value;
    return HabitEntriesLoaded(newEntries);
  }
}

final class HabitEntriesError extends HabitEntriesState {
  final String message;

  const HabitEntriesError(this.message);
}
