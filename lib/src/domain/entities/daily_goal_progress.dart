/// Immutable snapshot of today's reading progress toward the daily goal.
class DailyGoalProgress {
  final int secondsRead;
  final int targetMinutes;

  const DailyGoalProgress({
    required this.secondsRead,
    required this.targetMinutes,
  });

  int get targetSeconds => targetMinutes * 60;

  int get minutesRead => secondsRead ~/ 60;

  bool get isComplete => secondsRead >= targetSeconds;

  double get fraction {
    if (targetSeconds <= 0) return 1;
    return (secondsRead / targetSeconds).clamp(0.0, 1.0);
  }

  /// Whole percentage. It only reaches 100 once the goal is actually met.
  int get percentage => (fraction * 100).floor().clamp(0, 100);

  /// Minutes still needed, rounded up so "1 min left" never shows 0 early.
  int get remainingMinutes {
    final remainingSeconds = targetSeconds - secondsRead;
    if (remainingSeconds <= 0) return 0;
    return (remainingSeconds / 60).ceil();
  }
}
