import '../../../habits/domain/entities/habit.dart';

class ActivityInsight {
  final Habit activity;
  final int daysLogged;
  final int totalDays;
  final double consistencyPercent; // 0-100
  final double pieSharePercent; // 0-100, normalized across all activities

  const ActivityInsight({
    required this.activity,
    required this.daysLogged,
    required this.totalDays,
    required this.consistencyPercent,
    required this.pieSharePercent,
  });

  ActivityInsight copyWith({
    Habit? activity,
    int? daysLogged,
    int? totalDays,
    double? consistencyPercent,
    double? pieSharePercent,
  }) {
    return ActivityInsight(
      activity: activity ?? this.activity,
      daysLogged: daysLogged ?? this.daysLogged,
      totalDays: totalDays ?? this.totalDays,
      consistencyPercent: consistencyPercent ?? this.consistencyPercent,
      pieSharePercent: pieSharePercent ?? this.pieSharePercent,
    );
  }
}
