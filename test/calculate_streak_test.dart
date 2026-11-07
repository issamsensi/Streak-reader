import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/usecases/calculate_streak.dart';

void main() {
  Book book(int id, {bool completed = false}) => Book(
        id: id,
        title: 'Book $id',
        lastPage: 0,
        isCompleted: completed,
        createdAt: DateTime(2026),
      );

  ReadingSession session(
    String date, {
    int seconds = 600,
    int pages = 0,
    int bookId = 1,
  }) =>
      ReadingSession(
        id: 0,
        bookId: bookId,
        date: date,
        durationSeconds: seconds,
        pagesRead: pages,
      );

  CalculateStreak calculatorAt(DateTime now) => CalculateStreak(now: () => now);

  group('CalculateStreak', () {
    test('returns empty stats when there are no sessions', () {
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [],
        [book(1, completed: true), book(2)],
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.totalMinutes, 0);
      expect(result.totalPagesRead, 0);
      expect(result.completedBooks, 1);
    });

    test('accumulates short sessions before checking the daily goal', () {
      // 3 x 200s = 600s, exactly the 10 minute threshold. Summing each
      // session's floored minutes would incorrectly yield 9 minutes here.
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [
          session('2026-11-07', seconds: 200, pages: 2),
          session('2026-11-07', seconds: 200, pages: 3),
          session('2026-11-07', seconds: 200, pages: 4),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.totalMinutes, 10);
      expect(result.totalPagesRead, 9);
    });

    test('days below the threshold do not qualify', () {
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [
          session('2026-11-06', seconds: 599),
          session('2026-11-07', seconds: 599),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.totalMinutes, 19);
    });

    test('counts consecutive qualifying days including today', () {
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [
          session('2026-11-05', pages: 10),
          session('2026-11-06', pages: 20),
          session('2026-11-07', pages: 30),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
      expect(result.totalMinutes, 30);
      expect(result.totalPagesRead, 60);
    });

    test('yesterday keeps the current streak alive', () {
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [
          session('2026-11-04'),
          session('2026-11-05'),
          session('2026-11-06'),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test('a missed day breaks the current streak but not the longest', () {
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [
          session('2026-11-04'),
          session('2026-11-05'),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 2);
    });

    test('reports the longest run separately from the current run', () {
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [
          session('2026-10-30'),
          session('2026-10-31'),
          session('2026-11-01'),
          session('2026-11-02'),
          session('2026-11-06'),
          session('2026-11-07'),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 2);
      expect(result.longestStreak, 4);
    });

    test('handles consecutive days across a year boundary', () {
      final result = calculatorAt(DateTime(2026, 1, 1))(
        [
          session('2025-12-30'),
          session('2025-12-31'),
          session('2026-01-01'),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test('handles consecutive days across a month boundary', () {
      final result = calculatorAt(DateTime(2026, 11, 1))(
        [
          session('2026-10-31'),
          session('2026-11-01'),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 2);
      expect(result.longestStreak, 2);
    });

    test('ignores malformed dates instead of throwing', () {
      final result = calculatorAt(DateTime(2026, 11, 7))(
        [
          session('not-a-date'),
          session('2026-11-07'),
        ],
        [book(1)],
      );

      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
    });
  });
}
