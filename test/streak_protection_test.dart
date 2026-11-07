import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/usecases/build_reading_calendar.dart';
import 'package:streak_reader/src/domain/usecases/calculate_streak.dart';

ReadingSession session(String date) => ReadingSession(
      readingMode: 'digital',
      id: 1,
      bookId: 1,
      date: date,
      durationSeconds: 30 * 60,
      pagesRead: 0,
      startTime: null,
      endTime: null,
      startingPage: null,
      endingPage: null,
      activeSegmentStartedAt: null,
    );

void main() {
  test('protected dates preserve streak continuity without reading totals', () {
    final result = CalculateStreak(
      now: () => DateTime(2026, 1, 3, 12),
      goalMinutesForDate: (_) => 30,
      protectedDates: {'2026-01-02'},
    )(
      [session('2026-01-01'), session('2026-01-03')],
      const [],
    );

    expect(result.currentStreak, 3);
    expect(result.longestStreak, 3);
    expect(result.actualLongestStreak, 1);
    expect(result.totalMinutes, 60);
    expect(result.protectedDates, {'2026-01-02'});
  });

  test(
      'calendar marks protected days separately and does not count them as activity',
      () {
    final calendar = const BuildReadingCalendar(
      goalMinutes: 30,
      protectedDates: {'2026-01-02'},
    )(
      [session('2026-01-01')],
      DateTime.utc(2026, 1),
    );

    final protected = calendar.activityFor(DateTime(2026, 1, 2));
    expect(protected?.protected, isTrue);
    expect(protected?.hasActivity, isFalse);
    expect(protected?.goalMet, isFalse);
    expect(calendar.summary.totalMinutes, 30);
  });
}
