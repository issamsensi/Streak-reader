import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/achievement.dart';
import '../providers/achievements_provider.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  bool _celebrated = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(achievementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.achievements)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(context.l10n.saveFailed)),
        data: (snapshot) {
          if (!_celebrated && snapshot.newlyUnlocked.isNotEmpty) {
            _celebrated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.achievementUnlocked(
                      achievementTitle(
                        context.l10n,
                        snapshot.newlyUnlocked.first.definition,
                      ),
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              _Summary(snapshot: snapshot),
              const SizedBox(height: 20),
              for (final category in AchievementCategory.values) ...[
                Text(
                  achievementCategoryTitle(context.l10n, category),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ...snapshot.achievements
                    .where((item) => item.definition.category == category)
                    .map((item) => _AchievementCard(item: item)),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final AchievementsSnapshot snapshot;

  const _Summary({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final unlocked = snapshot.achievements
        .where((achievement) => achievement.isUnlocked)
        .length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.emoji_events_rounded,
                size: 38, color: context.palette.gold),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.l10n.achievementsProgress(
                  unlocked,
                  snapshot.achievements.length,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementStatus item;

  const _AchievementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = item.isUnlocked
        ? context.palette.gold
        : theme.colorScheme.onSurfaceVariant;
    return Card(
      child: ListTile(
        leading: Icon(
          item.isUnlocked
              ? Icons.workspace_premium_rounded
              : Icons.lock_outline_rounded,
          color: accent,
          size: 30,
        ),
        title: Text(
          achievementTitle(context.l10n, item.definition),
          style: TextStyle(
            fontWeight: item.isUnlocked ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievementDescription(context.l10n, item.definition)),
            if (!item.isUnlocked) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: item.fraction),
              const SizedBox(height: 4),
              Text('${item.value} / ${item.targetValue}'),
            ] else if (item.unlockedAt != null)
              Text(
                context.l10n.achievementUnlockedDate(
                  MaterialLocalizations.of(context)
                      .formatMediumDate(item.unlockedAt!),
                ),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

String achievementCategoryTitle(
  AppLocalizations l10n,
  AchievementCategory category,
) =>
    switch (category) {
      AchievementCategory.streak => l10n.achievementStreaks,
      AchievementCategory.time => l10n.achievementTime,
      AchievementCategory.progress => l10n.achievementProgress,
    };

String achievementTitle(
  AppLocalizations l10n,
  AchievementDefinition definition,
) =>
    switch (definition.id) {
      'first_day' => l10n.achievementFirstDay,
      'streak_3' => l10n.achievementThreeDayStreak,
      'streak_7' => l10n.achievementSevenDayStreak,
      'streak_14' => l10n.achievementFourteenDayStreak,
      'streak_30' => l10n.achievementThirtyDayStreak,
      'streak_100' => l10n.achievementHundredDayStreak,
      'first_hour' => l10n.achievementFirstHour,
      'time_10_hours' => l10n.achievementTenHours,
      'time_50_hours' => l10n.achievementFiftyHours,
      'time_100_hours' => l10n.achievementHundredHours,
      'first_100_pages' => l10n.achievementFirstHundredPages,
      'pages_500' => l10n.achievementFiveHundredPages,
      'pages_1000' => l10n.achievementThousandPages,
      'first_completed_book' => l10n.achievementFirstCompletedBook,
      'books_5' => l10n.achievementFiveCompletedBooks,
      _ => l10n.achievementTenCompletedBooks,
    };

String achievementDescription(
  AppLocalizations l10n,
  AchievementDefinition definition,
) =>
    switch (definition.metric) {
      AchievementMetric.streak => l10n.achievementStreakDescription(
          definition.target,
        ),
      AchievementMetric.minutes => l10n.achievementMinutesDescription(
          definition.target ~/ 60,
        ),
      AchievementMetric.pages => l10n.achievementPagesDescription(
          definition.target,
        ),
      AchievementMetric.books => l10n.achievementBooksDescription(
          definition.target,
        ),
    };
