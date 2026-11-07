import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/entities/monthly_goal.dart';
import 'package:streak_reader/src/domain/usecases/calculate_monthly_progress.dart';

void main() {
  ReadingSession session(
    String date, {
    int seconds = 600,
    int pages = 0,
    int id = 0,
  }) =>
      ReadingSession(
        id: id,
        bookId: 1,
        date: date,
        durationSeconds: seconds,
        pagesRead: pages,
      );

  test('aggregates all sessions once and calculates multiple goal types', () {
    const goal = MonthlyGoal({
      MonthlyGoalType.minutes: 30,
      MonthlyGoalType.pages: 10,
      MonthlyGoalType.books: 2,
    });

    final progress = const CalculateMonthlyProgress()(
      month: DateTime(2026, 11),
      goal: goal,
      sessions: [
        session('2026-11-02', seconds: 900, pages: 4, id: 1),
        session('2026-11-18', seconds: 900, pages: 6, id: 2),
        session('2026-12-01', seconds: 3600, pages: 100, id: 3),
      ],
      completedBooks: 2,
    );

    expect(progress.goals, hasLength(3));
    expect(progress.goals[0].completed, 30);
    expect(progress.goals[0].isComplete, isTrue);
    expect(progress.goals[1].completed, 10);
    expect(progress.goals[2].completed, 2);
    expect(progress.isComplete, isTrue);
  });

  test('goal history is scoped by month', () {
    final history = const MonthlyGoalHistory().withGoalFor(
      DateTime(2026, 11),
      const MonthlyGoal({MonthlyGoalType.minutes: 600}),
    );

    expect(history.goalFor(DateTime(2026, 11)).targets, {
      MonthlyGoalType.minutes: 600,
    });
    expect(history.goalFor(DateTime(2026, 12)).targets, {
      MonthlyGoalType.minutes: 600,
    });
  });
}
