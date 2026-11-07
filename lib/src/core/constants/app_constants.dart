class AppConstants {
  /// Goal used before the user changes it, and for historical days that
  /// predate the customizable-goal feature.
  static const int defaultDailyGoalMinutes = 10;

  /// Kept for backwards compatibility with the original hardcoded streak goal.
  static const int streakMinMinutes = defaultDailyGoalMinutes;

  static const List<int> dailyGoalPresets = [5, 10, 15, 20, 30];

  static const int minDailyGoalMinutes = 1;
  static const int maxDailyGoalMinutes = 600;

  static bool isValidDailyGoal(int minutes) =>
      minutes >= minDailyGoalMinutes && minutes <= maxDailyGoalMinutes;

  static const int idleTimeoutMinutes = 2;
  static const String dateFormat = 'yyyy-MM-dd';
}
