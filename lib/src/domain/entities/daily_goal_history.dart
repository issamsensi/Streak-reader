import '../../core/constants/app_constants.dart';
import '../../core/utils/date_only.dart';

/// Daily goal values keyed by the local calendar date they took effect on.
///
/// Storing changes by date means changing the goal never rewrites history:
/// past days keep the goal that applied when they were read, while today and
/// future days use the latest configured value.
class DailyGoalHistory {
  final Map<String, int> _changes;

  const DailyGoalHistory([this._changes = const {}]);

  /// Builds a history from persisted JSON-ish data, dropping malformed dates
  /// and out-of-range values instead of failing the whole settings load.
  factory DailyGoalHistory.fromMap(Map<dynamic, dynamic> values) {
    final changes = <String, int>{};
    values.forEach((key, value) {
      if (key is! String || value is! num) return;
      final date = DateOnly.tryParse(key);
      if (date == null) return;
      final minutes = value.toInt();
      if (!AppConstants.isValidDailyGoal(minutes)) return;
      changes[DateOnly.key(date)] = minutes;
    });
    return DailyGoalHistory(changes);
  }

  Map<String, int> get changes => Map.unmodifiable(_changes);

  Map<String, int> toMap() => Map<String, int>.from(_changes);

  bool get isEmpty => _changes.isEmpty;

  /// Goal in effect on [dateKey] (`YYYY-MM-DD`).
  int minutesForDateKey(String dateKey) {
    var minutes = AppConstants.defaultDailyGoalMinutes;
    String? bestDate;
    for (final entry in _changes.entries) {
      if (entry.key.compareTo(dateKey) > 0) continue;
      if (bestDate == null || entry.key.compareTo(bestDate) > 0) {
        bestDate = entry.key;
        minutes = entry.value;
      }
    }
    return minutes;
  }

  int minutesForDate(DateTime date) =>
      minutesForDateKey(DateOnly.key(DateOnly.fromDate(date)));

  /// Returns a new history where [minutes] applies from [date] onward.
  DailyGoalHistory withGoalFrom(DateTime date, int minutes) {
    if (!AppConstants.isValidDailyGoal(minutes)) return this;
    final changes = Map<String, int>.from(_changes);
    changes[DateOnly.key(DateOnly.fromDate(date))] = minutes;
    return DailyGoalHistory(changes);
  }
}
