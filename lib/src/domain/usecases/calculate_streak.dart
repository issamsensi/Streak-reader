import '../../core/constants/app_constants.dart';
import '../../core/utils/date_only.dart';
import '../../data/datasources/local/app_database.dart';
import '../entities/reading_statistics.dart';

/// Resolves the daily goal that applied on a stored `YYYY-MM-DD` date.
typedef DailyGoalMinutesResolver = int Function(String dateKey);

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final int totalMinutes;
  final int completedBooks;
  final int totalPagesRead;
  final int todaySeconds;
  final int todayMinutes;
  final int todayGoalMinutes;
  final ReadingStatistics readingStatistics;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalMinutes,
    required this.completedBooks,
    required this.totalPagesRead,
    this.todaySeconds = 0,
    this.todayMinutes = 0,
    this.todayGoalMinutes = AppConstants.defaultDailyGoalMinutes,
    this.readingStatistics = const ReadingStatistics(),
  });
}

class CalculateStreak {
  /// Injectable clock so streak boundaries can be tested deterministically.
  final DateTime Function() _now;

  /// Per-day goal lookup. Defaults to the pre-customization goal so old data
  /// and existing callers keep their historical completion records.
  final DailyGoalMinutesResolver _goalMinutesForDate;

  CalculateStreak({
    DateTime Function()? now,
    DailyGoalMinutesResolver? goalMinutesForDate,
  })  : _now = now ?? DateTime.now,
        _goalMinutesForDate = goalMinutesForDate ?? _defaultGoalForDate;

  static int _defaultGoalForDate(String _) =>
      AppConstants.defaultDailyGoalMinutes;

  StreakResult call(List<ReadingSession> sessions, List<Book> books) {
    final completedBooks = books.where((b) => b.isCompleted).length;
    final todayKey = DateOnly.key(DateOnly.fromDate(_now()));

    final readingStatistics = ReadingStatistics.fromRecords(
      sessions: sessions,
      books: books,
      now: _now(),
    );

    if (sessions.isEmpty) {
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        totalMinutes: 0,
        completedBooks: completedBooks,
        totalPagesRead: 0,
        todaySeconds: 0,
        todayMinutes: 0,
        todayGoalMinutes: _goalMinutesForDate(todayKey),
        readingStatistics: readingStatistics,
      );
    }

    // Accumulate seconds per calendar day *before* converting to minutes.
    // Summing each session's floored minutes would lose short sessions and
    // could keep a day below the threshold despite enough total reading.
    final secondsByDate = <String, int>{};
    int totalSeconds = 0;
    int totalPages = 0;
    for (final session in sessions) {
      totalSeconds += session.durationSeconds;
      totalPages += session.pagesRead;
      secondsByDate[session.date] =
          (secondsByDate[session.date] ?? 0) + session.durationSeconds;
    }

    final qualifyingDates = <DateTime>{};
    for (final entry in secondsByDate.entries) {
      final goalSeconds = _goalMinutesForDate(entry.key) * 60;
      if (entry.value < goalSeconds) continue;
      final date = DateOnly.tryParse(entry.key);
      if (date != null) qualifyingDates.add(date);
    }

    final longest = _longestRun(qualifyingDates);
    final current = _currentRun(qualifyingDates);
    final todaySeconds = secondsByDate[todayKey] ?? 0;

    return StreakResult(
      currentStreak: current,
      longestStreak: longest,
      totalMinutes: totalSeconds ~/ 60,
      completedBooks: completedBooks,
      totalPagesRead: totalPages,
      todaySeconds: todaySeconds,
      todayMinutes: todaySeconds ~/ 60,
      todayGoalMinutes: _goalMinutesForDate(todayKey),
      readingStatistics: readingStatistics,
    );
  }

  /// Longest run of consecutive qualifying days.
  int _longestRun(Set<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final sorted = dates.toList()..sort();
    int longest = 1;
    int run = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        run++;
      } else {
        if (run > longest) longest = run;
        run = 1;
      }
    }
    return run > longest ? run : longest;
  }

  /// Current streak from today backwards. Yesterday also keeps the streak
  /// alive so a user who has not read yet today sees their real streak.
  int _currentRun(Set<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final now = _now();
    var cursor = DateOnly.fromDate(now);

    if (!dates.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!dates.contains(cursor)) return 0;
    }

    int count = 0;
    while (dates.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }
}
