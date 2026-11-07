import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/date_only.dart';
import '../../../domain/usecases/build_reading_calendar.dart';

/// Reading activity for the month containing the supplied [DateTime].
///
/// The key is normalized to the first day of the month so navigating between
/// months never creates duplicate cache entries for the same month.
final readingCalendarProvider =
    FutureProvider.family<ReadingCalendarMonth, DateTime>((ref, month) async {
  ref.watch(dataRevisionProvider);
  final db = ref.watch(databaseProvider);
  final monthStart = DateOnly.monthStart(month);
  final lastDay = DateTime.utc(monthStart.year, monthStart.month + 1, 0);

  final sessions = await db.getSessionsForDateRange(
    DateOnly.key(monthStart),
    DateOnly.key(lastDay),
  );

  return const BuildReadingCalendar()(sessions, monthStart);
});
