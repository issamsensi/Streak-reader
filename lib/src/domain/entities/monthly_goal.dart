import '../../core/utils/date_only.dart';

enum MonthlyGoalType { minutes, pages, books }

class MonthlyGoal {
  final Map<MonthlyGoalType, int> targets;

  const MonthlyGoal([this.targets = const {}]);

  bool get isEmpty => targets.isEmpty;

  MonthlyGoal copyWithTarget(MonthlyGoalType type, int? target) {
    final next = Map<MonthlyGoalType, int>.from(targets);
    if (target == null || target <= 0) {
      next.remove(type);
    } else {
      next[type] = target;
    }
    return MonthlyGoal(next);
  }

  Map<String, int> toMap() => {
        for (final entry in targets.entries) entry.key.name: entry.value,
      };

  factory MonthlyGoal.fromMap(Map<dynamic, dynamic> raw) {
    final targets = <MonthlyGoalType, int>{};
    for (final type in MonthlyGoalType.values) {
      final value = raw[type.name];
      if (value is num && value.toInt() > 0) {
        targets[type] = value.toInt();
      }
    }
    return MonthlyGoal(targets);
  }
}

class MonthlyGoalHistory {
  final Map<String, MonthlyGoal> _goals;

  const MonthlyGoalHistory([this._goals = const {}]);

  factory MonthlyGoalHistory.fromMap(Map<dynamic, dynamic> raw) {
    final goals = <String, MonthlyGoal>{};
    raw.forEach((key, value) {
      if (key is! String || DateOnly.tryParse('$key-01') == null) return;
      if (value is Map) {
        final goal = MonthlyGoal.fromMap(value);
        if (!goal.isEmpty) goals[key] = goal;
      }
    });
    return MonthlyGoalHistory(goals);
  }

  MonthlyGoal goalFor(DateTime month) {
    final key = monthKey(month);
    String? latest;
    for (final candidate in _goals.keys) {
      if (candidate.compareTo(key) <= 0 &&
          (latest == null || candidate.compareTo(latest) > 0)) {
        latest = candidate;
      }
    }
    return latest == null ? const MonthlyGoal() : _goals[latest]!;
  }

  Map<String, Map<String, int>> toMap() => {
        for (final entry in _goals.entries) entry.key: entry.value.toMap(),
      };

  MonthlyGoalHistory withGoalFor(DateTime month, MonthlyGoal goal) {
    final next = Map<String, MonthlyGoal>.from(_goals);
    final key = monthKey(month);
    if (goal.isEmpty) {
      next.remove(key);
    } else {
      next[key] = goal;
    }
    return MonthlyGoalHistory(next);
  }

  static String monthKey(DateTime date) =>
      DateOnly.key(DateTime.utc(date.year, date.month, 1)).substring(0, 7);
}
