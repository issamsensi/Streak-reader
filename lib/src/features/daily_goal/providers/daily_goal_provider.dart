import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/daily_goal_progress.dart';
import '../../stats/providers/stats_provider.dart';

/// Today's progress toward the configured goal.
///
/// [statsProvider] watches the persisted goal history, so changing the goal
/// or saving a reading session automatically recalculates this value.
final dailyGoalProgressProvider = Provider<DailyGoalProgress?>((ref) {
  final stats = ref.watch(statsProvider).valueOrNull;
  if (stats == null) return null;
  return DailyGoalProgress(
    secondsRead: stats.todaySeconds,
    targetMinutes: stats.todayGoalMinutes,
  );
});
