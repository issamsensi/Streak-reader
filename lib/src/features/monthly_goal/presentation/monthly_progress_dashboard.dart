import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/monthly_goal.dart';
import '../../../domain/entities/monthly_goal_progress.dart';
import '../providers/monthly_goal_provider.dart';

class MonthlyProgressDashboard extends ConsumerStatefulWidget {
  const MonthlyProgressDashboard({super.key});

  @override
  ConsumerState<MonthlyProgressDashboard> createState() =>
      _MonthlyProgressDashboardState();
}

class _MonthlyProgressDashboardState
    extends ConsumerState<MonthlyProgressDashboard> {
  DateTime _month = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = ref.watch(monthlyProgressProvider(_month));
    final monthLabel = DateFormat.yMMMM(l10n.localeName).format(_month);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: progress.when(
          loading: () => const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text(l10n.errorMessage(error.toString())),
          data: (value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insights_rounded, color: context.palette.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.monthlyGoals,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: AppTheme.displayFont,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.previousMonth,
                    onPressed: () => setState(
                      () => _month = DateOnlyMonth.add(_month, -1),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.nextMonth,
                    onPressed: _month.month == DateTime.now().month &&
                            _month.year == DateTime.now().year
                        ? null
                        : () => setState(
                              () => _month = DateOnlyMonth.add(_month, 1),
                            ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              Text(
                monthLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              if (!value.hasGoals)
                Text(
                  l10n.noMonthlyGoals,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else ...[
                for (final goal in value.goals) ...[
                  _GoalRow(goal: goal),
                  if (goal != value.goals.last) const SizedBox(height: 14),
                ],
                if (value.isComplete) ...[
                  const SizedBox(height: 14),
                  Text(
                    l10n.monthlyGoalsAchieved,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.palette.success,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final MonthlyGoalProgress goal;

  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = switch (goal.type) {
      MonthlyGoalType.minutes => l10n.monthlyMinutes,
      MonthlyGoalType.pages => l10n.monthlyPages,
      MonthlyGoalType.books => l10n.monthlyBooks,
    };
    final unit = switch (goal.type) {
      MonthlyGoalType.minutes => l10n.minute,
      MonthlyGoalType.pages => l10n.page,
      MonthlyGoalType.books => l10n.book,
    };
    final color = goal.isComplete
        ? context.palette.success
        : Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              '${goal.completed} / ${goal.target} $unit',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: goal.fraction,
          minHeight: 8,
          borderRadius: BorderRadius.circular(99),
          color: color,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('${goal.percentage}%'),
            const Spacer(),
            Text(
              goal.isComplete
                  ? l10n.goalAchieved
                  : l10n.monthlyGoalRemaining(goal.remaining, unit),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class DateOnlyMonth {
  static DateTime add(DateTime date, int delta) =>
      DateTime(date.year, date.month + delta, 1);
}
