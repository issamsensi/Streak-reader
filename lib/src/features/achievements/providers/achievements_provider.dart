import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../domain/entities/achievement.dart';
import '../../books/providers/books_providers.dart';
import '../../stats/providers/stats_provider.dart';

final achievementsProvider = FutureProvider<AchievementsSnapshot>((ref) async {
  ref.watch(dataRevisionProvider);
  final db = ref.watch(databaseProvider);
  final stats = await ref.watch(statsProvider.future);
  await ref.watch(booksListProvider.future);
  final sessions = await db.getAllSessions();
  final unlocks = await db.getAchievementUnlocks();
  final unlockById = {
    for (final unlock in unlocks) unlock.achievementId: unlock,
  };
  final totalSeconds = sessions.fold<int>(
      0, (total, session) => total + session.durationSeconds);
  final statuses = <AchievementStatus>[];
  final newlyUnlocked = <AchievementStatus>[];

  for (final definition in achievementDefinitions) {
    final value = achievementValue(
      definition,
      stats: stats,
      totalSeconds: totalSeconds,
    );
    var unlock = unlockById[definition.id];
    if (unlock == null && value >= definition.target) {
      final now = DateTime.now();
      final inserted = await db.saveAchievementUnlock(
        AchievementUnlocksCompanion.insert(
          achievementId: definition.id,
          unlockedAt: now,
        ),
      );
      if (inserted) {
        unlock = AchievementUnlock(
          achievementId: definition.id,
          unlockedAt: now,
        );
        newlyUnlocked.add(
          statusFromUnlock(definition, value, unlock),
        );
      }
    }
    statuses.add(statusFromUnlock(definition, value, unlock));
  }

  return AchievementsSnapshot(
    achievements: statuses,
    newlyUnlocked: newlyUnlocked,
  );
});
