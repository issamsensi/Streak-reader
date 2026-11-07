import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_only.dart';
import '../../../core/widgets/error_state.dart';
import '../../../domain/usecases/build_reading_calendar.dart';
import '../providers/reading_calendar_provider.dart';

class ReadingCalendarScreen extends ConsumerStatefulWidget {
  const ReadingCalendarScreen({super.key});

  @override
  ConsumerState<ReadingCalendarScreen> createState() =>
      _ReadingCalendarScreenState();
}

class _ReadingCalendarScreenState extends ConsumerState<ReadingCalendarScreen> {
  late final DateTime _today;
  late DateTime _visibleMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _today = DateOnly.fromDate(DateTime.now());
    _visibleMonth = DateOnly.monthStart(_today);
    _selectedDate = _today;
  }

  void _changeMonth(int delta) {
    final nextMonth = DateOnly.addMonths(_visibleMonth, delta);
    setState(() {
      _visibleMonth = nextMonth;
      _selectedDate = _isSameMonth(_today, nextMonth) ? _today : null;
    });
  }

  void _goToToday() {
    setState(() {
      _visibleMonth = DateOnly.monthStart(_today);
      _selectedDate = _today;
    });
  }

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  Future<void> _showDayDetails(
    ReadingCalendarMonth calendar,
    DateTime date,
  ) async {
    setState(() => _selectedDate = date);
    final activity = calendar.activityFor(date);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _DayDetailsSheet(
        date: date,
        activity: activity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final calendarAsync = ref.watch(readingCalendarProvider(_visibleMonth));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readingCalendar),
        actions: [
          IconButton(
            key: const ValueKey('calendar-today'),
            tooltip: l10n.today,
            onPressed: _goToToday,
            icon: const Icon(Icons.today_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: _MonthNavigation(
                  month: _visibleMonth,
                  onPrevious: () => _changeMonth(-1),
                  onNext: () => _changeMonth(1),
                ),
              ),
            ),
          ),
          Expanded(
            child: calendarAsync.when(
              data: (calendar) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                    children: [
                      _CalendarCard(
                        calendar: calendar,
                        today: _today,
                        selectedDate: _selectedDate,
                        onDayTap: (date) => _showDayDetails(calendar, date),
                      ),
                      const SizedBox(height: 24),
                      _MonthlySummaryCard(summary: calendar.summary),
                      if (!calendar.hasActivity) ...[
                        const SizedBox(height: 14),
                        const _EmptyMonthNote(),
                      ],
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => ErrorState(
                message: l10n.errorMessage(err.toString()),
                onRetry: () =>
                    ref.invalidate(readingCalendarProvider(_visibleMonth)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavigation extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavigation({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final monthLabel = MaterialLocalizations.of(context).formatMonthYear(month);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final previousIcon =
        isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded;
    final nextIcon =
        isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;

    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.palette.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('calendar-prev-month'),
            tooltip: l10n.previousMonth,
            onPressed: onPrevious,
            icon: Icon(previousIcon),
          ),
          Expanded(
            child: Text(
              monthLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('calendar-next-month'),
            tooltip: l10n.nextMonth,
            onPressed: onNext,
            icon: Icon(nextIcon),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final ReadingCalendarMonth calendar;
  final DateTime today;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarCard({
    required this.calendar,
    required this.today,
    required this.selectedDate,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDayIndex = localizations.firstDayOfWeekIndex;
    final firstOfMonth = calendar.month;
    final sundayBasedFirstDay = firstOfMonth.weekday % 7;
    final leadingBlanks = (sundayBasedFirstDay - firstDayIndex + 7) % 7;
    final daysInMonth =
        DateOnly.daysInMonth(firstOfMonth.year, firstOfMonth.month);
    final itemCount = leadingBlanks + daysInMonth;
    final selectedKey =
        selectedDate == null ? null : DateOnly.key(selectedDate!);
    final todayKey = DateOnly.key(today);

    final weekdays = List.generate(
      7,
      (index) => localizations.narrowWeekdays[(firstDayIndex + index) % 7],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        child: Column(
          children: [
            Row(
              children: [
                for (final weekday in weekdays)
                  Expanded(
                    child: Text(
                      weekday,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.palette.muted,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: itemCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                if (index < leadingBlanks) {
                  return const SizedBox.shrink();
                }
                final dayNumber = index - leadingBlanks + 1;
                final date = DateTime.utc(
                  firstOfMonth.year,
                  firstOfMonth.month,
                  dayNumber,
                );
                final key = DateOnly.key(date);
                return _CalendarDayCell(
                  key: ValueKey('calendar-day-$key'),
                  date: date,
                  activity: calendar.days[key],
                  isToday: key == todayKey,
                  isSelected: key == selectedKey,
                  onTap: () => onDayTap(date),
                );
              },
            ),
            const SizedBox(height: 16),
            const _CalendarLegend(),
          ],
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final ReadingDayActivity? activity;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarDayCell({
    super.key,
    required this.date,
    required this.activity,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = context.palette;

    final hasActivity = activity?.hasActivity ?? false;
    final goalMet = activity?.goalMet ?? false;
    final protected = activity?.protected ?? false;
    final background = protected
        ? context.palette.gold.withValues(alpha: 0.22)
        : goalMet
            ? palette.success
            : hasActivity
                ? palette.success.withValues(alpha: 0.18)
                : scheme.surfaceContainerLow;
    final foreground = goalMet
        ? scheme.onPrimary
        : hasActivity
            ? scheme.onSurface
            : palette.muted;
    final borderColor = isToday
        ? scheme.primary
        : isSelected
            ? scheme.secondary
            : hasActivity
                ? Colors.transparent
                : palette.border.withValues(alpha: 0.6);
    final statusLabel = protected
        ? l10n.streakDayProtected
        : goalMet
            ? l10n.goalAchieved
            : hasActivity
                ? l10n.readingActivity
                : l10n.noActivity;
    final semanticsLabel =
        '${MaterialLocalizations.of(context).formatFullDate(date)}, $statusLabel';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor,
            width: isToday || isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  maxLines: 1,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    height: 1.1,
                    fontWeight: goalMet ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (hasActivity) ...[
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.minutesShort(activity!.totalMinutes),
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontSize: 9,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: palette.success,
          label: l10n.goalAchieved,
        ),
        _LegendItem(
          color: palette.success.withValues(alpha: 0.18),
          borderColor: palette.success.withValues(alpha: 0.4),
          label: l10n.readingActivity,
        ),
        _LegendItem(
          color: palette.gold.withValues(alpha: 0.22),
          borderColor: palette.gold,
          label: l10n.streakDayProtected,
        ),
        _LegendItem(
          color: scheme.surfaceContainerLow,
          borderColor: palette.border,
          label: l10n.noActivity,
        ),
        _LegendItem(
          color: Colors.transparent,
          borderColor: scheme.primary,
          label: l10n.today,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: borderColor ?? Colors.transparent,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  final ReadingMonthSummary summary;

  const _MonthlySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.monthSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: l10n.activeReadingDays,
                      value: '${summary.activeDays}',
                      unit: l10n.day,
                      icon: Icons.event_available_rounded,
                      accent: context.palette.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryTile(
                      label: l10n.totalReading,
                      value: '${summary.totalMinutes}',
                      unit: l10n.minute,
                      icon: Icons.timer_outlined,
                      accent: context.palette.pages,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: l10n.pagesRead,
                      value: '${summary.totalPages}',
                      unit: l10n.page,
                      icon: Icons.menu_book_rounded,
                      accent: context.palette.gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryTile(
                      label: l10n.longestStreak,
                      value: '${summary.longestStreak}',
                      unit: l10n.day,
                      icon: Icons.local_fire_department_rounded,
                      accent: context.palette.streak,
                    ),
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

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.bottomStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(height: 1),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMonthNote extends StatelessWidget {
  const _EmptyMonthNote();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            color: scheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.noReadingThisMonth,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDetailsSheet extends StatelessWidget {
  final DateTime date;
  final ReadingDayActivity? activity;

  const _DayDetailsSheet({
    required this.date,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = context.palette;
    final hasActivity = activity?.hasActivity ?? false;
    final goalMet = activity?.goalMet ?? false;

    final statusColor = goalMet
        ? palette.success
        : hasActivity
            ? palette.success
            : palette.muted;
    final statusBackground = goalMet
        ? palette.success.withValues(alpha: 0.18)
        : hasActivity
            ? palette.success.withValues(alpha: 0.12)
            : scheme.surfaceContainerHigh;
    final statusLabel = goalMet
        ? l10n.goalAchieved
        : hasActivity
            ? l10n.readingActivity
            : l10n.noActivity;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MaterialLocalizations.of(context).formatFullDate(date),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.timer_outlined,
                    label: l10n.readingDuration,
                    value: '${activity?.totalMinutes ?? 0} ${l10n.minute}',
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.menu_book_rounded,
                    label: l10n.pagesRead,
                    value: '${activity?.pagesRead ?? 0} ${l10n.page}',
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.layers_outlined,
                    label: l10n.sessions,
                    value: '${activity?.sessionCount ?? 0}',
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.flag_outlined,
                    label: l10n.dailyGoal,
                    value: goalMet ? l10n.goalAchieved : l10n.goalNotAchieved,
                    valueColor: goalMet ? palette.success : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
