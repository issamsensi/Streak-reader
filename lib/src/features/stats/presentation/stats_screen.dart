import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/streak_banner.dart';
import '../../../domain/entities/reading_statistics.dart';
import '../../../domain/usecases/calculate_streak.dart';
import '../../monthly_goal/presentation/monthly_progress_dashboard.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatisticsPeriod _period = StatisticsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final statsAsync = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AchievementsScreen(),
              ),
            ),
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: l10n.achievements,
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: l10n.errorMessage(error.toString()),
          onRetry: () => ref.invalidate(statsProvider),
        ),
        data: (stats) {
          final insights = stats.readingStatistics;
          final hasData = insights.totalSessions > 0;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              StreakBanner(stats: stats),
              const SizedBox(height: 20),
              _MetricGrid(
                stats: stats,
                insights: insights,
              ),
              const SizedBox(height: 20),
              const MonthlyProgressDashboard(),
              const SizedBox(height: 20),
              Text(l10n.readingActivity, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              _PeriodSelector(
                value: _period,
                onChanged: (value) => setState(() => _period = value),
              ),
              const SizedBox(height: 12),
              _ActivityChart(
                points: insights.activityFor(_period),
                period: _period,
              ),
              const SizedBox(height: 20),
              _ConsistencyCard(insights: insights),
              const SizedBox(height: 20),
              _DailyHistoryCard(entries: insights.dailyHistory),
              const SizedBox(height: 20),
              _BookProgressCard(progress: insights.bookProgress),
              if (!hasData) ...[
                const SizedBox(height: 8),
                _EmptyStatsCard(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final StreakResult stats;
  final ReadingStatistics insights;

  const _MetricGrid({required this.stats, required this.insights});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metrics = [
      (
        l10n.totalReading,
        '${stats.totalMinutes}',
        l10n.minute,
        Icons.timer_outlined,
        context.palette.pages
      ),
      (
        l10n.pagesRead,
        '${stats.totalPagesRead}',
        l10n.page,
        Icons.menu_book_rounded,
        context.palette.success
      ),
      (
        l10n.completedBooks,
        '${stats.completedBooks}',
        l10n.book,
        Icons.check_circle_outline,
        context.palette.gold
      ),
      (
        l10n.currentlyReading,
        '${insights.currentlyReadingBooks}',
        l10n.book,
        Icons.auto_stories_outlined,
        Theme.of(context).colorScheme.primary
      ),
      (
        l10n.totalSessions,
        '${insights.totalSessions}',
        '',
        Icons.history_rounded,
        context.palette.pages
      ),
      (
        l10n.averageDailyReading,
        _formatMinutes(insights.averageDailySeconds),
        l10n.minute,
        Icons.today_outlined,
        context.palette.success
      ),
      (
        l10n.averageSession,
        _formatMinutes(insights.averageSessionSeconds),
        l10n.minute,
        Icons.timelapse_rounded,
        context.palette.gold
      ),
      (
        l10n.mostActiveDay,
        insights.mostActiveDateKey == null
            ? '—'
            : DateFormat.MMMd(l10n.localeName)
                .format(DateTime.parse(insights.mostActiveDateKey!)),
        '',
        Icons.local_fire_department_outlined,
        Theme.of(context).colorScheme.primary,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 112,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _MetricCard(
          label: metric.$1,
          value: metric.$2,
          unit: metric.$3,
          icon: metric.$4,
          accent: metric.$5,
        );
      },
    );
  }

  static String _formatMinutes(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 20),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Text(value, style: theme.textTheme.titleLarge),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final StatisticsPeriod value;
  final ValueChanged<StatisticsPeriod> onChanged;

  const _PeriodSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<StatisticsPeriod>(
      selected: {value},
      onSelectionChanged: (values) => onChanged(values.first),
      segments: [
        ButtonSegment(value: StatisticsPeriod.week, label: Text(l10n.week)),
        ButtonSegment(value: StatisticsPeriod.month, label: Text(l10n.month)),
        ButtonSegment(value: StatisticsPeriod.year, label: Text(l10n.year)),
      ],
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final List<ReadingActivityPoint> points;
  final StatisticsPeriod period;

  const _ActivityChart({required this.points, required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSeconds = points.fold<int>(
      0,
      (max, point) => point.seconds > max ? point.seconds : max,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
        child: SizedBox(
          height: 190,
          child: points.every((point) => point.seconds == 0)
              ? Center(
                  child: Text(
                    context.l10n.noReadingData,
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final point in points)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (point.minutes > 0)
                                Text(
                                  '${point.minutes}',
                                  style: theme.textTheme.labelSmall,
                                ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: maxSeconds == 0
                                    ? 2
                                    : 112 * point.seconds / maxSeconds,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                point.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  final ReadingStatistics insights;

  const _ConsistencyCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    final percentage = (insights.consistencyPercentage * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: insights.consistencyPercentage,
                    strokeWidth: 7,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  Text('$percentage%'),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.l10n.readingConsistency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyHistoryCard extends StatelessWidget {
  final List<DailyReadingHistoryEntry> entries;

  const _DailyHistoryCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dailyHistory,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final entry in entries.reversed.take(7))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 54,
                      child: Text(
                        DateFormat.MMMd(l10n.localeName).format(entry.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (entry.seconds / 3600).clamp(0.0, 1.0),
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${entry.minutes} ${l10n.minute}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookProgressCard extends StatelessWidget {
  final List<BookReadingProgress> progress;

  const _BookProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bookProgress,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (progress.isEmpty)
              Text(l10n.noReadingData,
                  style: Theme.of(context).textTheme.bodySmall)
            else
              for (final item in progress.take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${item.pagesRead} ${l10n.page}'),
                      if (item.book.isCompleted)
                        const Padding(
                          padding: EdgeInsetsDirectional.only(start: 6),
                          child: Icon(Icons.check_circle, size: 16),
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          context.l10n.startReadingForStats,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
