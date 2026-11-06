import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/usecases/calculate_streak.dart';
import '../../books/providers/books_providers.dart';

final statsProvider = FutureProvider<StreakResult>((ref) async {
  final db = ref.watch(databaseProvider);
  final sessions = await db.getAllSessions();
  final booksAsync = await ref.watch(booksListProvider.future);
  final calc = CalculateStreak();
  return calc(sessions, booksAsync);
});
