import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/date_only.dart';
import '../../../domain/entities/monthly_goal.dart';
import '../../../domain/entities/monthly_goal_progress.dart';
import '../../../domain/usecases/calculate_monthly_progress.dart';
import '../../settings/providers/settings_provider.dart';

final monthlyProgressProvider =
    FutureProvider.family<MonthlyProgress, DateTime>((ref, month) async {
  ref.watch(dataRevisionProvider);
  final settings = ref.watch(settingsProvider);
  final normalized = DateOnly.monthStart(month);
  final lastDay = DateTime.utc(normalized.year, normalized.month + 1, 0);
  final sessions = await ref.watch(databaseProvider).getSessionsForDateRange(
        DateOnly.key(normalized),
        DateOnly.key(lastDay),
      );
  final key = settings.monthlyGoalHistory.goalFor(normalized);
  final completed =
      settings.completedBookHistory[MonthlyGoalHistory.monthKey(normalized)] ??
          const <int>{};
  return const CalculateMonthlyProgress()(
    month: normalized,
    goal: key,
    sessions: sessions,
    completedBooks: completed.length,
  );
});
