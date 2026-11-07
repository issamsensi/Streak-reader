import '../../core/constants/app_constants.dart';
import '../../core/utils/date_only.dart';
import '../../data/datasources/local/app_database.dart';

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final int totalMinutes;
  final int completedBooks;
  final int totalPagesRead;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalMinutes,
    required this.completedBooks,
    required this.totalPagesRead,
  });
}

class CalculateStreak {
  /// Injectable clock so streak boundaries can be tested deterministically.
  final DateTime Function() _now;

  CalculateStreak({DateTime Function()? now}) : _now = now ?? DateTime.now;

  StreakResult call(List<ReadingSession> sessions, List<Book> books) {
    final completedBooks = books.where((b) => b.isCompleted).length;

    if (sessions.isEmpty) {
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        totalMinutes: 0,
        completedBooks: completedBooks,
        totalPagesRead: 0,
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

    const thresholdSeconds = AppConstants.streakMinMinutes * 60;
    final qualifyingDates = <DateTime>{};
    for (final entry in secondsByDate.entries) {
      if (entry.value < thresholdSeconds) continue;
      final date = DateOnly.tryParse(entry.key);
      if (date != null) qualifyingDates.add(date);
    }

    final longest = _longestRun(qualifyingDates);
    final current = _currentRun(qualifyingDates);

    return StreakResult(
      currentStreak: current,
      longestStreak: longest,
      totalMinutes: totalSeconds ~/ 60,
      completedBooks: completedBooks,
      totalPagesRead: totalPages,
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
