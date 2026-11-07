import '../../core/constants/app_constants.dart';
import '../../core/utils/date_only.dart';
import '../../data/datasources/local/app_database.dart';
import 'calculate_streak.dart';

/// Aggregated reading activity for one calendar day.
class ReadingDayActivity {
  /// UTC-midnight date used for calendar layout.
  final DateTime date;
  final int totalSeconds;
  final int totalMinutes;
  final int pagesRead;
  final int sessionCount;
  final int goalMinutes;
  final bool goalMet;
  final bool protected;

  const ReadingDayActivity({
    required this.date,
    required this.totalSeconds,
    required this.totalMinutes,
    required this.pagesRead,
    required this.sessionCount,
    required this.goalMet,
    this.protected = false,
    this.goalMinutes = AppConstants.defaultDailyGoalMinutes,
  });

  bool get hasActivity => sessionCount > 0;
}

class ReadingMonthSummary {
  final int activeDays;
  final int totalSeconds;
  final int totalMinutes;
  final int totalPages;

  /// Longest run of goal-completing days inside the selected month.
  final int longestStreak;

  const ReadingMonthSummary({
    required this.activeDays,
    required this.totalSeconds,
    required this.totalMinutes,
    required this.totalPages,
    required this.longestStreak,
  });
}

class ReadingCalendarMonth {
  final DateTime month;
  final Map<String, ReadingDayActivity> days;
  final ReadingMonthSummary summary;

  const ReadingCalendarMonth({
    required this.month,
    required this.days,
    required this.summary,
  });

  bool get hasActivity => days.isNotEmpty;

  ReadingDayActivity? activityFor(DateTime date) => days[DateOnly.key(date)];
}

/// Builds a month of calendar activity from persisted reading sessions.
///
/// Opening a PDF alone does not create a session, and zero/negative duration
/// records are ignored here as an additional guard. Multiple sessions on the
/// same day are aggregated rather than duplicated.
class BuildReadingCalendar {
  /// Legacy single goal used when [goalMinutesForDate] is not supplied.
  final int? goalMinutes;

  /// Resolves the goal that applied on the stored `YYYY-MM-DD` date.
  final DailyGoalMinutesResolver? goalMinutesForDate;
  final Set<String>? protectedDates;

  const BuildReadingCalendar({
    this.goalMinutes,
    this.goalMinutesForDate,
    this.protectedDates,
  });

  int _goalForDate(String dateKey) =>
      goalMinutesForDate?.call(dateKey) ??
      goalMinutes ??
      AppConstants.defaultDailyGoalMinutes;

  ReadingCalendarMonth call(List<ReadingSession> sessions, DateTime month) {
    final monthStart = DateOnly.monthStart(month);

    final totalsByDate = <String, _DayTotals>{};
    for (final session in sessions) {
      if (session.durationSeconds <= 0) continue;
      final date = DateOnly.tryParse(session.date);
      if (date == null ||
          date.year != monthStart.year ||
          date.month != monthStart.month) {
        continue;
      }

      final key = DateOnly.key(date);
      final totals = totalsByDate.putIfAbsent(key, () => _DayTotals(date));
      totals
        ..sessionCount += 1
        ..totalSeconds += session.durationSeconds
        ..pagesRead += session.pagesRead;
    }

    final days = <String, ReadingDayActivity>{};
    for (final entry in totalsByDate.entries) {
      final totals = entry.value;
      final goalMinutes = _goalForDate(entry.key);
      days[entry.key] = ReadingDayActivity(
        date: totals.date,
        totalSeconds: totals.totalSeconds,
        totalMinutes: totals.totalSeconds ~/ 60,
        pagesRead: totals.pagesRead,
        sessionCount: totals.sessionCount,
        goalMinutes: goalMinutes,
        goalMet: totals.totalSeconds >= goalMinutes * 60,
      );
    }
    for (final dateKey in protectedDates ?? const <String>{}) {
      final date = DateOnly.tryParse(dateKey);
      if (date == null ||
          date.year != monthStart.year ||
          date.month != monthStart.month ||
          days.containsKey(dateKey)) {
        continue;
      }
      days[dateKey] = ReadingDayActivity(
        date: date,
        totalSeconds: 0,
        totalMinutes: 0,
        pagesRead: 0,
        sessionCount: 0,
        goalMinutes: _goalForDate(dateKey),
        goalMet: false,
        protected: true,
      );
    }

    var totalSeconds = 0;
    var totalPages = 0;
    for (final day in days.values) {
      totalSeconds += day.totalSeconds;
      totalPages += day.pagesRead;
    }

    return ReadingCalendarMonth(
      month: monthStart,
      days: days,
      summary: ReadingMonthSummary(
        activeDays: days.length,
        totalSeconds: totalSeconds,
        totalMinutes: totalSeconds ~/ 60,
        totalPages: totalPages,
        longestStreak: _longestStreak(days.values),
      ),
    );
  }

  int _longestStreak(Iterable<ReadingDayActivity> days) {
    final goalDays = days
        .where((day) => day.goalMet)
        .map((day) => day.date)
        .toList()
      ..sort();
    if (goalDays.isEmpty) return 0;

    var longest = 1;
    var run = 1;
    for (var i = 1; i < goalDays.length; i++) {
      if (goalDays[i].difference(goalDays[i - 1]).inDays == 1) {
        run++;
      } else {
        if (run > longest) longest = run;
        run = 1;
      }
    }
    return run > longest ? run : longest;
  }
}

class _DayTotals {
  final DateTime date;
  int totalSeconds = 0;
  int pagesRead = 0;
  int sessionCount = 0;

  _DayTotals(this.date);
}
