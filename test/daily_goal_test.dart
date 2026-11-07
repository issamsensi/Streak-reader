import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak_reader/main.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/core/utils/date_only.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/entities/daily_goal_history.dart';
import 'package:streak_reader/src/domain/entities/daily_goal_progress.dart';
import 'package:streak_reader/src/domain/usecases/build_reading_calendar.dart';
import 'package:streak_reader/src/domain/usecases/calculate_streak.dart';
import 'package:streak_reader/src/features/settings/providers/settings_provider.dart';
import 'package:streak_reader/src/features/stats/providers/stats_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ReadingSession session(
    String date, {
    int seconds = 600,
    int pages = 0,
    int bookId = 1,
  }) =>
      ReadingSession(
        id: 0,
        bookId: bookId,
        date: date,
        durationSeconds: seconds,
        pagesRead: pages,
      );

  group('DailyGoalHistory', () {
    test('defaults to the original goal for dates without changes', () {
      const history = DailyGoalHistory();

      expect(history.minutesForDate(DateTime(2026, 11, 7)), 10);
      expect(history.minutesForDateKey('2026-11-07'), 10);
      expect(history.isEmpty, isTrue);
    });

    test('applies each change from its date onward without rewriting history',
        () {
      final history = const DailyGoalHistory()
          .withGoalFrom(DateTime(2026, 11, 5), 5)
          .withGoalFrom(DateTime(2026, 11, 7), 20);

      expect(history.minutesForDate(DateTime(2026, 11, 4)), 10);
      expect(history.minutesForDate(DateTime(2026, 11, 5)), 5);
      expect(history.minutesForDate(DateTime(2026, 11, 6)), 5);
      expect(history.minutesForDate(DateTime(2026, 11, 7)), 20);
      expect(history.minutesForDate(DateTime(2026, 12, 1)), 20);
    });

    test('ignores malformed and out-of-range persisted values', () {
      final history = DailyGoalHistory.fromMap({
        '2026-11-05': 15,
        'not-a-date': 20,
        '2026-02-30': 25,
        '2026-11-06': 0,
        '2026-11-07': 1000,
        '2026-11-08': '30',
      });

      expect(history.changes, {'2026-11-05': 15});
    });

    test('rejects invalid updates', () {
      const history = DailyGoalHistory();

      expect(history.withGoalFrom(DateTime(2026, 11, 7), 0).isEmpty, isTrue);
      expect(history.withGoalFrom(DateTime(2026, 11, 7), -5).isEmpty, isTrue);
    });
  });

  group('DailyGoalProgress', () {
    test('reports minutes, percentage, remaining time, and completion', () {
      const empty = DailyGoalProgress(secondsRead: 0, targetMinutes: 10);
      expect(empty.minutesRead, 0);
      expect(empty.percentage, 0);
      expect(empty.remainingMinutes, 10);
      expect(empty.isComplete, isFalse);

      const half = DailyGoalProgress(secondsRead: 300, targetMinutes: 10);
      expect(half.minutesRead, 5);
      expect(half.percentage, 50);
      expect(half.remainingMinutes, 5);
      expect(half.isComplete, isFalse);

      const almost = DailyGoalProgress(secondsRead: 599, targetMinutes: 10);
      expect(almost.percentage, 99);
      expect(almost.isComplete, isFalse);

      const complete = DailyGoalProgress(secondsRead: 600, targetMinutes: 10);
      expect(complete.minutesRead, 10);
      expect(complete.percentage, 100);
      expect(complete.remainingMinutes, 0);
      expect(complete.isComplete, isTrue);
    });

    test('rounds remaining minutes up and clamps over-achievement', () {
      const short = DailyGoalProgress(secondsRead: 30, targetMinutes: 10);
      expect(short.percentage, 5);
      expect(short.remainingMinutes, 10);

      const over = DailyGoalProgress(secondsRead: 1800, targetMinutes: 10);
      expect(over.fraction, 1);
      expect(over.percentage, 100);
      expect(over.isComplete, isTrue);
    });
  });

  group('Configured daily goals', () {
    final history = const DailyGoalHistory()
        .withGoalFrom(DateTime(2026, 11, 5), 5)
        .withGoalFrom(DateTime(2026, 11, 6), 20);

    test('streak uses the goal that applied on each day', () {
      final result = CalculateStreak(
        now: () => DateTime(2026, 11, 7),
        goalMinutesForDate: history.minutesForDateKey,
      )(
        [
          session('2026-11-05', seconds: 300),
          session('2026-11-06', seconds: 600),
          session('2026-11-07', seconds: 300),
        ],
        [],
      );

      // Nov 5 met its 5-minute goal; Nov 6 and 7 did not meet 20 minutes.
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 1);
      expect(result.todaySeconds, 300);
      expect(result.todayMinutes, 5);
      expect(result.todayGoalMinutes, 20);
    });

    test('calendar marks days using their historical goal', () {
      final calendar = BuildReadingCalendar(
        goalMinutesForDate: history.minutesForDateKey,
      )(
        [
          session('2026-11-05', seconds: 300),
          session('2026-11-06', seconds: 600),
        ],
        DateTime(2026, 11, 7),
      );

      expect(calendar.days['2026-11-05']!.goalMinutes, 5);
      expect(calendar.days['2026-11-05']!.goalMet, isTrue);
      expect(calendar.days['2026-11-06']!.goalMinutes, 20);
      expect(calendar.days['2026-11-06']!.goalMet, isFalse);
      expect(calendar.summary.longestStreak, 1);
    });

    test('stats provider responds to goal changes', () async {
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await container.read(settingsProvider.notifier).initialized;
      await container.read(settingsProvider.notifier).setDailyGoal(20);

      final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
      await db.insertSession(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          date: DateOnly.key(DateOnly.fromDate(DateTime.now())),
          durationSeconds: 600,
        ),
      );
      container.read(dataRevisionProvider.notifier).state++;

      final stats = await container.read(statsProvider.future);
      expect(stats.todayMinutes, 10);
      expect(stats.todayGoalMinutes, 20);
      expect(stats.currentStreak, 0);

      await container.read(settingsProvider.notifier).setDailyGoal(5);
      final updated = await container.read(statsProvider.future);
      expect(updated.todayGoalMinutes, 5);
      expect(updated.currentStreak, 1);
    });
  });

  group('Settings goal persistence', () {
    test('saves a history and restores the latest goal', () async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 11, 5);
      final controller = SettingsController(now: () => now);
      await controller.initialized;

      expect(controller.state.dailyGoalMinutes, 10);
      await controller.setDailyGoal(5);
      expect(controller.state.dailyGoalMinutes, 5);

      now = DateTime(2026, 11, 7);
      await controller.setDailyGoal(20);
      expect(controller.state.dailyGoalMinutes, 20);

      final restored = SettingsController(now: () => DateTime(2026, 11, 10));
      await restored.initialized;
      expect(restored.state.dailyGoalMinutes, 20);
      expect(
        restored.state.dailyGoalHistory.minutesForDate(DateTime(2026, 11, 5)),
        5,
      );
      expect(
        restored.state.dailyGoalHistory.minutesForDate(DateTime(2026, 11, 7)),
        20,
      );

      await restored.setDailyGoal(0);
      expect(restored.state.dailyGoalMinutes, 20);
    });
  });

  group('Daily goal widget', () {
    Future<AppDatabase> pumpApp(
      WidgetTester tester, {
      Future<void> Function(AppDatabase db)? seed,
    }) async {
      SharedPreferences.setMockInitialValues({});
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      if (seed != null) await seed(db);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      return db;
    }

    testWidgets('shows progress and a completion message', (tester) async {
      final todayKey = DateOnly.key(DateOnly.fromDate(DateTime.now()));

      await pumpApp(
        tester,
        seed: (db) async {
          final bookId =
              await db.insertBook(BooksCompanion.insert(title: 'Book'));
          await db.insertSession(
            ReadingSessionsCompanion.insert(
              bookId: bookId,
              date: todayKey,
              durationSeconds: 600,
              pagesRead: const Value(4),
            ),
          );
        },
      );

      expect(find.text('الهدف اليومي'), findsOneWidget);
      expect(find.text('10 / 10 دقيقة'), findsOneWidget);
      expect(find.text('تم إنجاز الهدف اليومي!'), findsOneWidget);
    });

    testWidgets('changes preset and custom goals from settings',
        (tester) async {
      final todayKey = DateOnly.key(DateOnly.fromDate(DateTime.now()));

      await pumpApp(
        tester,
        seed: (db) async {
          final bookId =
              await db.insertBook(BooksCompanion.insert(title: 'Book'));
          await db.insertSession(
            ReadingSessionsCompanion.insert(
              bookId: bookId,
              date: todayKey,
              durationSeconds: 600,
            ),
          );
        },
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('هدف القراءة اليومي'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.widgetWithText(ChoiceChip, '15 دقيقة'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '15 دقيقة'))
            .selected,
        isTrue,
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('10 / 15 دقيقة'), findsOneWidget);
      expect(find.text('متبقٍ 5 دقيقة'), findsOneWidget);
      expect(find.text('تم إنجاز الهدف اليومي!'), findsNothing);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('هدف القراءة اليومي'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'مخصص'));
      await tester.pumpAndSettle();

      expect(find.text('هدف يومي مخصص'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '25');
      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pumpAndSettle();
      expect(find.text('الهدف الحالي: 25 دقيقة'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('10 / 25 دقيقة'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('هدف القراءة اليومي'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'مخصص'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('أدخل عدداً بين 1 و600.'), findsOneWidget);
      expect(find.text('هدف يومي مخصص'), findsOneWidget);
    });
  });
}
