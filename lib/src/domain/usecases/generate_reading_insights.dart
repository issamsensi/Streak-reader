import '../entities/reading_insight.dart';
import '../entities/reading_statistics.dart';

class ReadingInsights {
  final List<ReadingInsight> items;
  final int weekSeconds;
  final int previousWeekSeconds;
  final int monthSeconds;
  final int previousMonthSeconds;
  final double consistency;
  final double? pagesPerHour;
  final DateTime? mostActiveDate;

  const ReadingInsights({
    required this.items,
    required this.weekSeconds,
    required this.previousWeekSeconds,
    required this.monthSeconds,
    required this.previousMonthSeconds,
    required this.consistency,
    required this.pagesPerHour,
    required this.mostActiveDate,
  });
}

class GenerateReadingInsights {
  const GenerateReadingInsights();

  ReadingInsights call({
    required ReadingStatistics statistics,
    required DateTime now,
  }) {
    final recent = statistics.dailyHistory.reversed.take(7).toList();
    final previous = statistics.dailyHistory.reversed.skip(7).take(7).toList();
    final weekSeconds = recent.fold(0, (sum, entry) => sum + entry.seconds);
    final previousWeekSeconds =
        previous.fold(0, (sum, entry) => sum + entry.seconds);
    final monthSeconds = statistics.monthlyActivity.fold(
      0,
      (sum, point) => sum + point.seconds,
    );
    final previousMonthSeconds = statistics.previousMonthSeconds;
    final activeDays = recent.where((entry) => entry.seconds > 0).length;
    final consistency = recent.isEmpty ? 0.0 : activeDays / recent.length;
    final totalPages =
        statistics.bookProgress.fold(0, (sum, item) => sum + item.pagesRead);
    final totalSeconds =
        statistics.bookProgress.fold(0, (sum, item) => sum + item.secondsRead);
    final mostActiveDate = statistics.dailyHistory
        .where((entry) => entry.seconds > 0)
        .fold<DailyReadingHistoryEntry?>(
          null,
          (best, entry) =>
              best == null || entry.seconds > best.seconds ? entry : best,
        )
        ?.date;

    final items = <ReadingInsight>[];
    if (statistics.totalSessions > 0) {
      items.add(
        ReadingInsight(
          title: 'Average session',
          detail:
              '${statistics.averageSessionSeconds ~/ 60} minutes per session, based on ${statistics.totalSessions} completed sessions.',
        ),
      );
    }
    if (mostActiveDate != null) {
      items.add(
        ReadingInsight(
          title: 'Most active reading day',
          detail: _weekdayName(mostActiveDate.weekday),
          tone: InsightTone.positive,
        ),
      );
    }
    if (weekSeconds > 0) {
      items.add(
        ReadingInsight(
          title: 'This week',
          detail:
              '${weekSeconds ~/ 60} minutes across $activeDays active days.',
          tone: InsightTone.positive,
        ),
      );
    }
    if (previousWeekSeconds > 0 && weekSeconds != previousWeekSeconds) {
      final direction = weekSeconds > previousWeekSeconds ? 'up' : 'down';
      final percentage = ((weekSeconds - previousWeekSeconds).abs() *
              100 /
              previousWeekSeconds)
          .round();
      items.add(
        ReadingInsight(
          title: 'Weekly comparison',
          detail: '$direction $percentage% compared with the previous period.',
          tone: weekSeconds > previousWeekSeconds
              ? InsightTone.positive
              : InsightTone.actionable,
        ),
      );
    }
    if (monthSeconds > 0) {
      items.add(
        ReadingInsight(
          title: 'This month',
          detail: '${monthSeconds ~/ 60} minutes read so far.',
          tone: InsightTone.positive,
        ),
      );
    }
    if (previousMonthSeconds > 0 && monthSeconds != previousMonthSeconds) {
      final direction = monthSeconds > previousMonthSeconds ? 'up' : 'down';
      final percentage = ((monthSeconds - previousMonthSeconds).abs() *
              100 /
              previousMonthSeconds)
          .round();
      items.add(
        ReadingInsight(
          title: 'Monthly comparison',
          detail: '$direction $percentage% compared with last month.',
          tone: monthSeconds > previousMonthSeconds
              ? InsightTone.positive
              : InsightTone.actionable,
        ),
      );
    }
    if (consistency > 0) {
      items.add(
        ReadingInsight(
          title: 'Consistency',
          detail:
              '${(consistency * 100).round()}% of the last seven days had reading activity.',
        ),
      );
    }
    if (totalPages > 0 && totalSeconds >= 300) {
      items.add(
        ReadingInsight(
          title: 'Reading speed',
          detail:
              '${(totalPages * 3600 / totalSeconds).toStringAsFixed(1)} pages per hour across recorded page progress.',
        ),
      );
    }
    if (items.isEmpty) {
      items.add(
        const ReadingInsight(
          title: 'Start a reading session',
          detail: 'Insights appear after your first completed reading session.',
          tone: InsightTone.actionable,
        ),
      );
    }
    return ReadingInsights(
      items: items,
      weekSeconds: weekSeconds,
      previousWeekSeconds: previousWeekSeconds,
      monthSeconds: monthSeconds,
      previousMonthSeconds: previousMonthSeconds,
      consistency: consistency,
      pagesPerHour: totalPages > 0 && totalSeconds >= 300
          ? totalPages * 3600 / totalSeconds
          : null,
      mostActiveDate: mostActiveDate,
    );
  }

  static String _weekdayName(int weekday) => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][weekday - 1];
}
