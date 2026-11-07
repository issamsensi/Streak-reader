import '../../data/datasources/local/app_database.dart';
import '../usecases/calculate_streak.dart';

enum AchievementCategory { streak, time, progress }

enum AchievementMetric { streak, minutes, pages, books }

class AchievementDefinition {
  final String id;
  final AchievementCategory category;
  final AchievementMetric metric;
  final int target;
  final bool first;

  const AchievementDefinition({
    required this.id,
    required this.category,
    required this.metric,
    required this.target,
    this.first = false,
  });
}

class AchievementStatus {
  final AchievementDefinition definition;
  final int value;
  final DateTime? unlockedAt;

  const AchievementStatus({
    required this.definition,
    required this.value,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;
  double get fraction =>
      targetValue == 0 ? 0 : (value / targetValue).clamp(0, 1).toDouble();
  int get targetValue => definition.target;
}

class AchievementsSnapshot {
  final List<AchievementStatus> achievements;
  final List<AchievementStatus> newlyUnlocked;

  const AchievementsSnapshot({
    required this.achievements,
    this.newlyUnlocked = const [],
  });
}

const achievementDefinitions = [
  AchievementDefinition(
    id: 'first_day',
    category: AchievementCategory.streak,
    metric: AchievementMetric.streak,
    target: 1,
    first: true,
  ),
  AchievementDefinition(
    id: 'streak_3',
    category: AchievementCategory.streak,
    metric: AchievementMetric.streak,
    target: 3,
  ),
  AchievementDefinition(
    id: 'streak_7',
    category: AchievementCategory.streak,
    metric: AchievementMetric.streak,
    target: 7,
  ),
  AchievementDefinition(
    id: 'streak_14',
    category: AchievementCategory.streak,
    metric: AchievementMetric.streak,
    target: 14,
  ),
  AchievementDefinition(
    id: 'streak_30',
    category: AchievementCategory.streak,
    metric: AchievementMetric.streak,
    target: 30,
  ),
  AchievementDefinition(
    id: 'streak_100',
    category: AchievementCategory.streak,
    metric: AchievementMetric.streak,
    target: 100,
  ),
  AchievementDefinition(
    id: 'first_hour',
    category: AchievementCategory.time,
    metric: AchievementMetric.minutes,
    target: 60,
    first: true,
  ),
  AchievementDefinition(
    id: 'time_10_hours',
    category: AchievementCategory.time,
    metric: AchievementMetric.minutes,
    target: 600,
  ),
  AchievementDefinition(
    id: 'time_50_hours',
    category: AchievementCategory.time,
    metric: AchievementMetric.minutes,
    target: 3000,
  ),
  AchievementDefinition(
    id: 'time_100_hours',
    category: AchievementCategory.time,
    metric: AchievementMetric.minutes,
    target: 6000,
  ),
  AchievementDefinition(
    id: 'first_100_pages',
    category: AchievementCategory.progress,
    metric: AchievementMetric.pages,
    target: 100,
    first: true,
  ),
  AchievementDefinition(
    id: 'pages_500',
    category: AchievementCategory.progress,
    metric: AchievementMetric.pages,
    target: 500,
  ),
  AchievementDefinition(
    id: 'pages_1000',
    category: AchievementCategory.progress,
    metric: AchievementMetric.pages,
    target: 1000,
  ),
  AchievementDefinition(
    id: 'first_completed_book',
    category: AchievementCategory.progress,
    metric: AchievementMetric.books,
    target: 1,
    first: true,
  ),
  AchievementDefinition(
    id: 'books_5',
    category: AchievementCategory.progress,
    metric: AchievementMetric.books,
    target: 5,
  ),
  AchievementDefinition(
    id: 'books_10',
    category: AchievementCategory.progress,
    metric: AchievementMetric.books,
    target: 10,
  ),
];

int achievementValue(
  AchievementDefinition definition, {
  required StreakResult stats,
  required int totalSeconds,
}) {
  if (definition.id == 'first_day') return totalSeconds > 0 ? 1 : 0;
  return switch (definition.metric) {
    AchievementMetric.streak => stats.longestStreak,
    AchievementMetric.minutes => totalSeconds ~/ 60,
    AchievementMetric.pages => stats.totalPagesRead,
    AchievementMetric.books => stats.completedBooks,
  };
}

AchievementStatus statusFromUnlock(
  AchievementDefinition definition,
  int value,
  AchievementUnlock? unlock,
) =>
    AchievementStatus(
      definition: definition,
      value: value,
      unlockedAt: unlock?.unlockedAt,
    );
