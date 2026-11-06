import '../../core/constants/app_constants.dart';
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
  StreakResult call(List<ReadingSession> sessions, List<Book> books) {
    if (sessions.isEmpty) {
      final completed = books.where((b) => b.isCompleted).length;
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        totalMinutes: 0,
        completedBooks: completed,
        totalPagesRead: 0,
      );
    }

    // Group by date
    final Map<String, int> minutesByDate = {};
    int totalSeconds = 0;
    int totalPages = 0;
    for (final s in sessions) {
      totalSeconds += s.durationSeconds;
      totalPages += s.pagesRead;
      minutesByDate[s.date] = (minutesByDate[s.date] ?? 0) + s.durationSeconds ~/ 60;
    }

    // Get qualifying dates (>= threshold)
    final qualifying = <String>{};
    for (final entry in minutesByDate.entries) {
      if (entry.value >= AppConstants.streakMinMinutes) {
        qualifying.add(entry.key);
      }
    }

    if (qualifying.isEmpty) {
      final completed = books.where((b) => b.isCompleted).length;
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        totalMinutes: totalSeconds ~/ 60,
        completedBooks: completed,
        totalPagesRead: totalPages,
      );
    }

    final sortedDates = qualifying.toList()..sort();
    
    // Calculate longest streak
    int longest = 1;
    int currentRun = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final prev = DateTime.parse(sortedDates[i - 1]);
      final curr = DateTime.parse(sortedDates[i]);
      if (curr.difference(prev).inDays == 1) {
        currentRun++;
      } else {
        if (currentRun > longest) longest = currentRun;
        currentRun = 1;
      }
    }
    if (currentRun > longest) longest = currentRun;

    // Calculate current streak (from today backwards)
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    
    int currentStreakCount = 0;
    if (qualifying.contains(todayStr)) {
      currentStreakCount = 1;
      var checkDate = today.subtract(const Duration(days: 1));
      while (true) {
        final ds = checkDate.toIso8601String().substring(0, 10);
        if (qualifying.contains(ds)) {
          currentStreakCount++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    } else if (qualifying.contains(yesterdayStr)) {
      currentStreakCount = 1;
      var checkDate = today.subtract(const Duration(days: 2));
      while (true) {
        final ds = checkDate.toIso8601String().substring(0, 10);
        if (qualifying.contains(ds)) {
          currentStreakCount++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    } else {
      currentStreakCount = 0;
    }

    final completed = books.where((b) => b.isCompleted).length;
    return StreakResult(
      currentStreak: currentStreakCount,
      longestStreak: longest,
      totalMinutes: totalSeconds ~/ 60,
      completedBooks: completed,
      totalPagesRead: totalPages,
    );
  }
}
