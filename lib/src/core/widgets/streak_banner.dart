import 'package:flutter/material.dart';

import '../../domain/usecases/calculate_streak.dart';
import '../constants/app_constants.dart';
import '../l10n/l10n_extension.dart';
import '../theme/app_theme.dart';

/// The signature card of the app: current and longest reading streak.
///
/// Used compact on the library screen and larger on the statistics screen.
class StreakBanner extends StatelessWidget {
  final StreakResult stats;
  final bool compact;

  const StreakBanner({
    super.key,
    required this.stats,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final l10n = context.l10n;
    final bannerText = palette.onBanner;
    final fadedText = bannerText.withValues(alpha: 0.72);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [palette.bannerStart, palette.bannerEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.bannerEnd.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            top: -40,
            end: -30,
            child: _Glow(
              size: 130,
              color: bannerText.withValues(alpha: 0.07),
            ),
          ),
          PositionedDirectional(
            bottom: -50,
            start: -40,
            child: _Glow(
              size: 150,
              color: palette.streak.withValues(alpha: 0.10),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 18 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: compact ? 46 : 56,
                      height: compact ? 46 : 56,
                      decoration: BoxDecoration(
                        color: bannerText.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: bannerText.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: palette.streak,
                        size: compact ? 26 : 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentStreak,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: fadedText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.bottomStart,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${stats.currentStreak}',
                                  style: (compact
                                          ? theme.textTheme.headlineLarge
                                          : theme.textTheme.displayMedium)
                                      ?.copyWith(
                                    color: bannerText,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: compact ? 4 : 8,
                                  ),
                                  child: Text(
                                    l10n.day,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: fadedText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 104),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bannerText.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: bannerText.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 16,
                            color: palette.gold,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${stats.longestStreak}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: bannerText,
                              fontFamily: AppTheme.displayFont,
                            ),
                          ),
                          Text(
                            l10n.longestStreak,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: fadedText,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: bannerText.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: bannerText.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.streakGoalHint(AppConstants.streakMinMinutes),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: fadedText,
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
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
