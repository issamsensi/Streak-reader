import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/entities/reading_statistics.dart';

void main() {
  Book book(int id, {bool completed = false}) => Book(
        id: id,
        title: 'Book $id',
        lastPage: 0,
        isCompleted: completed,
        readingStatus: completed ? 'completed' : 'want_to_read',
        createdAt: DateTime(2026),
      );

  ReadingSession session(
    String date, {
    required int bookId,
    required int seconds,
    required int pages,
  }) =>
      ReadingSession(
        id: 0,
        bookId: bookId,
        date: date,
        durationSeconds: seconds,
        pagesRead: pages,
      );

  test('calculates aggregate metrics from valid reading sessions', () {
    final statistics = ReadingStatistics.fromRecords(
      now: DateTime(2026, 11, 7),
      books: [book(1), book(2, completed: true), book(3)],
      sessions: [
        session('2026-11-03', bookId: 1, seconds: 600, pages: 4),
        session('2026-11-03', bookId: 2, seconds: 300, pages: 2),
        session('2026-11-07', bookId: 1, seconds: 1200, pages: 6),
        session('2026-11-07', bookId: 3, seconds: 0, pages: 99),
      ],
    );

    expect(statistics.totalSessions, 3);
    expect(statistics.averageSessionSeconds, 700);
    expect(statistics.averageDailySeconds, 1050);
    expect(statistics.currentlyReadingBooks, 1);
    expect(statistics.mostActiveDateKey, '2026-11-07');
    expect(statistics.mostActiveDateSeconds, 1200);
    expect(statistics.weeklyActivity, hasLength(7));
    expect(statistics.monthlyActivity, hasLength(30));
    expect(statistics.yearlyActivity, hasLength(12));
    expect(statistics.dailyHistory, hasLength(14));
    expect(statistics.bookProgress.first.pagesRead, 10);
  });

  test('consistency is based on the fourteen-day daily history window', () {
    final statistics = ReadingStatistics.fromRecords(
      now: DateTime(2026, 11, 7),
      books: [book(1)],
      sessions: [
        session('2026-11-07', bookId: 1, seconds: 60, pages: 1),
        session('2026-11-01', bookId: 1, seconds: 60, pages: 1),
      ],
    );

    expect(statistics.consistencyPercentage, closeTo(2 / 14, 0.001));
  });

  test('empty records produce zeroed insights and empty charts', () {
    final statistics = ReadingStatistics.fromRecords(
      now: DateTime(2026, 11, 7),
      books: [book(1)],
      sessions: const [],
    );

    expect(statistics.totalSessions, 0);
    expect(statistics.currentlyReadingBooks, 0);
    expect(statistics.bookProgress, isEmpty);
    expect(statistics.consistencyPercentage, 0);
  });
}
