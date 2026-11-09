import '../../core/utils/date_only.dart';
import '../../data/datasources/local/app_database.dart';
import 'reading_status.dart';

enum StatisticsPeriod { week, month, year }

class ReadingActivityPoint {
  final String label;
  final int seconds;

  const ReadingActivityPoint({required this.label, required this.seconds});

  int get minutes => seconds ~/ 60;
}

class DailyReadingHistoryEntry {
  final DateTime date;
  final int seconds;

  const DailyReadingHistoryEntry({required this.date, required this.seconds});

  int get minutes => seconds ~/ 60;
}

class BookReadingProgress {
  final Book book;
  final int pagesRead;
  final int secondsRead;
  final int sessionCount;
  final int digitalSecondsRead;
  final int physicalSecondsRead;
  final String? lastReadingDate;

  const BookReadingProgress({
    required this.book,
    required this.pagesRead,
    required this.secondsRead,
    this.sessionCount = 0,
    this.digitalSecondsRead = 0,
    this.physicalSecondsRead = 0,
    this.lastReadingDate,
  });
}

class ReadingStatistics {
  final int currentlyReadingBooks;
  final int totalSessions;
  final int averageDailySeconds;
  final int averageSessionSeconds;
  final String? mostActiveDateKey;
  final int mostActiveDateSeconds;
  final List<ReadingActivityPoint> weeklyActivity;
  final List<ReadingActivityPoint> monthlyActivity;
  final List<ReadingActivityPoint> yearlyActivity;
  final List<DailyReadingHistoryEntry> dailyHistory;
  final List<BookReadingProgress> bookProgress;
  /// Total seconds in the calendar month before [fromRecords]' `now` month.
  final int previousMonthSeconds;

  const ReadingStatistics({
    this.currentlyReadingBooks = 0,
    this.totalSessions = 0,
    this.averageDailySeconds = 0,
    this.averageSessionSeconds = 0,
    this.mostActiveDateKey,
    this.mostActiveDateSeconds = 0,
    this.weeklyActivity = const [],
    this.monthlyActivity = const [],
    this.yearlyActivity = const [],
    this.dailyHistory = const [],
    this.bookProgress = const [],
    this.previousMonthSeconds = 0,
  });

  double get consistencyPercentage {
    if (dailyHistory.isEmpty) return 0;
    final activeDays = dailyHistory.where((entry) => entry.seconds > 0).length;
    return activeDays / dailyHistory.length;
  }

  List<ReadingActivityPoint> activityFor(StatisticsPeriod period) =>
      switch (period) {
        StatisticsPeriod.week => weeklyActivity,
        StatisticsPeriod.month => monthlyActivity,
        StatisticsPeriod.year => yearlyActivity,
      };

  static ReadingStatistics fromRecords({
    required List<ReadingSession> sessions,
    required List<Book> books,
    required DateTime now,
  }) {
    final validSessions =
        sessions.where((session) => session.durationSeconds > 0).toList();
    final secondsByDate = <String, int>{};
    final pagesByBook = <int, int>{};
    final secondsByBook = <int, int>{};
    final sessionsByBook = <int, int>{};
    final digitalSecondsByBook = <int, int>{};
    final physicalSecondsByBook = <int, int>{};
    final lastDateByBook = <int, String>{};
    var totalSeconds = 0;
    for (final session in validSessions) {
      totalSeconds += session.durationSeconds;
      secondsByDate[session.date] =
          (secondsByDate[session.date] ?? 0) + session.durationSeconds;
      pagesByBook[session.bookId] =
          (pagesByBook[session.bookId] ?? 0) + session.pagesRead;
      secondsByBook[session.bookId] =
          (secondsByBook[session.bookId] ?? 0) + session.durationSeconds;
      sessionsByBook[session.bookId] =
          (sessionsByBook[session.bookId] ?? 0) + 1;
      if (session.readingMode == 'physical') {
        physicalSecondsByBook[session.bookId] =
            (physicalSecondsByBook[session.bookId] ?? 0) +
                session.durationSeconds;
      } else {
        digitalSecondsByBook[session.bookId] =
            (digitalSecondsByBook[session.bookId] ?? 0) +
                session.durationSeconds;
      }
      final previousDate = lastDateByBook[session.bookId];
      if (previousDate == null || session.date.compareTo(previousDate) > 0) {
        lastDateByBook[session.bookId] = session.date;
      }
    }

    final activeDays = secondsByDate.values.where((value) => value > 0).length;
    final mostActive = secondsByDate.entries.isEmpty
        ? null
        : (secondsByDate.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first;
    final currentYear = DateOnly.fromDate(now).year;
    final currentMonth = DateOnly.fromDate(now).month;
    final weekStart = DateOnly.fromDate(now).subtract(
      Duration(days: DateOnly.fromDate(now).weekday - 1),
    );
    final historyStart =
        DateOnly.fromDate(now).subtract(const Duration(days: 13));

    int totalForDate(DateTime date) => secondsByDate[DateOnly.key(date)] ?? 0;

    final weekly = [
      for (var index = 0; index < 7; index++)
        ReadingActivityPoint(
          label: _weekdayLabel(weekStart.add(Duration(days: index))),
          seconds: totalForDate(weekStart.add(Duration(days: index))),
        ),
    ];
    final monthly = [
      for (var day = 1;
          day <= DateOnly.daysInMonth(currentYear, currentMonth);
          day++)
        ReadingActivityPoint(
          label: '$day',
          seconds: totalForDate(DateTime.utc(currentYear, currentMonth, day)),
        ),
    ];
    final yearly = [
      for (var month = 1; month <= 12; month++)
        ReadingActivityPoint(
          label: '$month',
          seconds: _sumMonth(secondsByDate, currentYear, month),
        ),
    ];
    final dailyHistory = [
      for (var index = 0; index < 14; index++)
        DailyReadingHistoryEntry(
          date: historyStart.add(Duration(days: index)),
          seconds: totalForDate(historyStart.add(Duration(days: index))),
        ),
    ];
    final progress = books
        .where((book) => pagesByBook.containsKey(book.id))
        .map(
          (book) => BookReadingProgress(
            book: book,
            pagesRead: pagesByBook[book.id]!,
            secondsRead: secondsByBook[book.id]!,
            sessionCount: sessionsByBook[book.id]!,
            digitalSecondsRead: digitalSecondsByBook[book.id] ?? 0,
            physicalSecondsRead: physicalSecondsByBook[book.id] ?? 0,
            lastReadingDate: lastDateByBook[book.id],
          ),
        )
        .toList()
      ..sort((a, b) => b.secondsRead.compareTo(a.secondsRead));

    final previousMonth = currentMonth == 1
        ? DateTime.utc(currentYear - 1, 12)
        : DateTime.utc(currentYear, currentMonth - 1);
    final previousMonthSeconds =
        _sumMonth(secondsByDate, previousMonth.year, previousMonth.month);

    return ReadingStatistics(
      currentlyReadingBooks: books
          .where((book) =>
              book.readingStatus == ReadingStatus.currentlyReading.value)
          .length,
      totalSessions: validSessions.length,
      averageDailySeconds: activeDays == 0 ? 0 : totalSeconds ~/ activeDays,
      averageSessionSeconds:
          validSessions.isEmpty ? 0 : totalSeconds ~/ validSessions.length,
      mostActiveDateKey: mostActive?.key,
      mostActiveDateSeconds: mostActive?.value ?? 0,
      weeklyActivity: weekly,
      monthlyActivity: monthly,
      yearlyActivity: yearly,
      dailyHistory: dailyHistory,
      bookProgress: progress,
      previousMonthSeconds: previousMonthSeconds,
    );
  }

  static int _sumMonth(Map<String, int> byDate, int year, int month) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    return byDate.entries
        .where((entry) => entry.key.startsWith(prefix))
        .fold(0, (total, entry) => total + entry.value);
  }

  static String _weekdayLabel(DateTime date) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
}
