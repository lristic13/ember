/// Data model for widget activity information.
/// This is serialized to JSON and shared with the native iOS widget via UserDefaults.
class WidgetActivityData {
  final String id;
  final String name;
  final String? emoji;
  final bool isCompletion;
  final String? unit;
  final double todayValue;
  final int currentStreak;
  final List<double> weekValues; // Mon-Sun, 7 values
  final String gradientId;

  const WidgetActivityData({
    required this.id,
    required this.name,
    this.emoji,
    required this.isCompletion,
    this.unit,
    required this.todayValue,
    required this.currentStreak,
    required this.weekValues,
    required this.gradientId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'isCompletion': isCompletion,
        'unit': unit,
        'todayValue': todayValue,
        'currentStreak': currentStreak,
        'weekValues': weekValues,
        'gradientId': gradientId,
      };

  factory WidgetActivityData.fromJson(Map<String, dynamic> json) {
    return WidgetActivityData(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      isCompletion: json['isCompletion'] as bool,
      unit: json['unit'] as String?,
      todayValue: (json['todayValue'] as num).toDouble(),
      currentStreak: json['currentStreak'] as int,
      weekValues:
          (json['weekValues'] as List).map((e) => (e as num).toDouble()).toList(),
      gradientId: json['gradientId'] as String,
    );
  }
}
