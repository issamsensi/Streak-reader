import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'l10n/app_localizations.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/books/presentation/books_list_screen.dart';
import 'src/features/settings/providers/settings_provider.dart';
import 'src/core/notifications/reading_reminder_service.dart';
import 'src/features/daily_goal/providers/daily_goal_provider.dart';
import 'src/core/sync/sync_service.dart';
import 'src/core/widgets/reading_widget_service.dart';
import 'src/features/books/providers/books_providers.dart';
import 'src/features/stats/providers/stats_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SyncService.initialize();

  // Platform plugin work must not delay first frame. Notifications initialize
  // in the background; widget launch URIs are best-effort with a short timeout.
  unawaited(ReadingReminderService.instance.initialize());
  int? initialBookId;
  try {
    final widgetUri = await HomeWidget.initiallyLaunchedFromHomeWidget()
        .timeout(const Duration(milliseconds: 400));
    initialBookId = int.tryParse(widgetUri?.queryParameters['bookId'] ?? '');
  } catch (_) {
    // Home widgets are not available on every platform/build target.
  }

  runApp(
    ProviderScope(
      child: MyApp(initialBookId: initialBookId),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, this.initialBookId});

  final int? initialBookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    ref.listen(settingsProvider, (_, next) {
      final progress = ref.read(dailyGoalProgressProvider);
      ReadingReminderService.instance.configure(
        next.readingReminder,
        goalCompleted: progress?.isComplete ?? false,
      );
    });
    ref.listen(dailyGoalProgressProvider, (_, next) {
      ReadingReminderService.instance.configure(
        ref.read(settingsProvider).readingReminder,
        goalCompleted: next?.isComplete ?? false,
      );
    });
    ref.listen(statsProvider, (_, next) {
      next.whenData((stats) async {
        final books = await ref.read(booksListProvider.future);
        final current = books
            .where((book) => book.readingStatus == 'currently_reading')
            .firstOrNull;
        await ReadingWidgetService.update(stats: stats, continueBook: current);
      });
    });

    return MaterialApp(
      title: 'Streak Reader',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      home: BooksListScreen(initialBookId: initialBookId),
    );
  }
}
