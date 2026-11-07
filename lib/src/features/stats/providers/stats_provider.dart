import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/usecases/calculate_streak.dart';
import '../../books/providers/books_providers.dart';
import '../../settings/providers/settings_provider.dart';

final statsProvider = FutureProvider<StreakResult>((ref) async {
  final db = ref.watch(databaseProvider);
  final settings = ref.watch(settingsProvider);
  final sessions = await db.getAllSessions();
  final booksAsync = await ref.watch(booksListProvider.future);
  final calc = CalculateStreak(
    goalMinutesForDate: settings.dailyGoalHistory.minutesForDateKey,
  );
  return calc(sessions, booksAsync);
});
