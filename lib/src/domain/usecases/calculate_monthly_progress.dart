import '../../core/utils/date_only.dart';
import '../../data/datasources/local/app_database.dart';
import '../entities/monthly_goal.dart';
import '../entities/monthly_goal_progress.dart';

class CalculateMonthlyProgress {
  const CalculateMonthlyProgress();

  MonthlyProgress call({
    required DateTime month,
    required MonthlyGoal goal,
    required List<ReadingSession> sessions,
    required int completedBooks,
  }) {
    final monthStart = DateOnly.monthStart(month);
    final monthKey = MonthlyGoalHistory.monthKey(monthStart);
    var seconds = 0;
    var pages = 0;
    for (final session in sessions) {
      final date = DateOnly.tryParse(session.date);
      if (date == null ||
          MonthlyGoalHistory.monthKey(date) != monthKey ||
          session.durationSeconds <= 0) {
        continue;
      }
      seconds += session.durationSeconds;
      pages += session.pagesRead;
    }

    final values = <MonthlyGoalType, int>{
      MonthlyGoalType.minutes: seconds ~/ 60,
      MonthlyGoalType.pages: pages,
      MonthlyGoalType.books: completedBooks,
    };
    return MonthlyProgress(
      month: monthStart,
      goals: [
        for (final entry in goal.targets.entries)
          MonthlyGoalProgress(
            type: entry.key,
            completed: values[entry.key] ?? 0,
            target: entry.value,
          ),
      ],
    );
  }
}
