class ReadingReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  final Set<int> days;
  final String message;

  const ReadingReminderSettings({
    this.enabled = false,
    this.hour = 20,
    this.minute = 0,
    this.days = const {1, 2, 3, 4, 5, 6, 7},
    this.message = 'Time for your daily reading session.',
  });

  ReadingReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    Set<int>? days,
    String? message,
  }) =>
      ReadingReminderSettings(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        days: days ?? this.days,
        message: message ?? this.message,
      );

  Map<String, Object> toMap() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'days': days.toList()..sort(),
        'message': message,
      };

  factory ReadingReminderSettings.fromMap(Map<dynamic, dynamic> map) {
    final days = map['days'];
    return ReadingReminderSettings(
      enabled: map['enabled'] == true,
      hour: _boundedInt(map['hour'], 20, 0, 23),
      minute: _boundedInt(map['minute'], 0, 0, 59),
      days: days is List
          ? {
              for (final day in days)
                if (day is num && day.toInt() >= 1 && day.toInt() <= 7)
                  day.toInt(),
            }
          : const {1, 2, 3, 4, 5, 6, 7},
      message: map['message'] is String &&
              (map['message'] as String).trim().isNotEmpty
          ? (map['message'] as String).trim()
          : 'Time for your daily reading session.',
    );
  }

  static int _boundedInt(Object? value, int fallback, int min, int max) {
    final parsed = value is num ? value.toInt() : fallback;
    return parsed.clamp(min, max);
  }
}
