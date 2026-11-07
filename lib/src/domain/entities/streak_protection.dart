class StreakProtection {
  final Map<String, DateTime> history;

  const StreakProtection({this.history = const {}});

  Set<String> get protectedDates => history.keys.toSet();

  StreakProtection protect(String dateKey, DateTime at) {
    if (history.containsKey(dateKey)) return this;
    return StreakProtection(history: {...history, dateKey: at});
  }

  Map<String, String> toMap() => {
        for (final entry in history.entries)
          entry.key: entry.value.toIso8601String(),
      };

  factory StreakProtection.fromMap(Map<dynamic, dynamic> map) {
    final values = <String, DateTime>{};
    for (final entry in map.entries) {
      if (entry.key is! String || entry.value is! String) continue;
      final parsed = DateTime.tryParse(entry.value as String);
      if (parsed != null) values[entry.key as String] = parsed;
    }
    return StreakProtection(history: values);
  }
}
