import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/books/presentation/books_list_screen.dart';
import 'src/features/settings/providers/settings_provider.dart';
import 'src/core/notifications/reading_reminder_service.dart';
import 'src/features/daily_goal/providers/daily_goal_provider.dart';
import 'src/core/sync/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SyncService.initialize();
  await ReadingReminderService.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
      home: const BooksListScreen(),
    );
  }
}
