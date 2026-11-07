import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/daily_goal_progress.dart';
import '../providers/daily_goal_provider.dart';

/// Compact daily reading progress card for the library screen.
class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyGoalProgressProvider);
    if (progress == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = context.palette;
    final complete = progress.isComplete;
    final accent = complete ? palette.success : scheme.primary;

    final statusLabel = complete
        ? l10n.dailyGoalReached
        : l10n.dailyGoalRemaining(progress.remainingMinutes);

    return Card(
      color: complete ? palette.success.withValues(alpha: 0.10) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _GoalRing(
              progress: progress,
              color: accent,
              trackColor: scheme.surfaceContainerHighest,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_rounded, size: 15, color: accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.dailyGoal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.dailyGoalProgress(
                        progress.minutesRead,
                        progress.targetMinutes,
                      ),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: AppTheme.displayFont,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        complete
                            ? Icons.check_circle_rounded
                            : Icons.timer_outlined,
                        size: 14,
                        color: accent,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          statusLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: complete ? accent : scheme.onSurfaceVariant,
                            fontWeight:
                                complete ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
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

class _GoalRing extends StatelessWidget {
  final DailyGoalProgress progress;
  final Color color;
  final Color trackColor;

  const _GoalRing({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress.fraction,
              strokeWidth: 7,
              backgroundColor: trackColor,
              color: color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${progress.percentage}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontFamily: AppTheme.displayFont,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
