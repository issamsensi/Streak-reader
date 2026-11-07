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
import 'package:streak_reader/src/domain/usecases/build_reading_calendar.dart';

void main() {
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

  group('BuildReadingCalendar', () {
    const builder = BuildReadingCalendar();

    test('returns an empty month when there are no sessions', () {
      final calendar = builder([], DateTime(2026, 11, 15));

      expect(calendar.days, isEmpty);
      expect(calendar.hasActivity, isFalse);
      expect(calendar.summary.activeDays, 0);
      expect(calendar.summary.totalMinutes, 0);
      expect(calendar.summary.totalPages, 0);
      expect(calendar.summary.longestStreak, 0);
    });

    test('aggregates multiple sessions on the same day', () {
      final calendar = builder(
        [
          session('2026-11-01', seconds: 300, pages: 4),
          session('2026-11-01', seconds: 400, pages: 6),
          session('2026-11-02', seconds: 120, pages: 2),
        ],
        DateTime(2026, 11, 7),
      );

      final day = calendar.days['2026-11-01']!;
      expect(day.sessionCount, 2);
      expect(day.totalSeconds, 700);
      expect(day.totalMinutes, 11);
      expect(day.pagesRead, 10);
      expect(day.goalMet, isTrue);
      expect(day.hasActivity, isTrue);

      final shortDay = calendar.days['2026-11-02']!;
      expect(shortDay.sessionCount, 1);
      expect(shortDay.totalMinutes, 2);
      expect(shortDay.goalMet, isFalse);

      expect(calendar.summary.activeDays, 2);
      expect(calendar.summary.totalMinutes, 13);
      expect(calendar.summary.totalPages, 12);
    });

    test('ignores zero-duration, malformed, and out-of-month sessions', () {
      final calendar = builder(
        [
          session('2026-11-01', seconds: 600),
          session('2026-11-02', seconds: 0),
          session('2026-11-03', seconds: -30),
          session('not-a-date', seconds: 900),
          session('2026-10-31', seconds: 900),
          session('2026-12-01', seconds: 900),
        ],
        DateTime(2026, 11, 20),
      );

      expect(calendar.days.keys, ['2026-11-01']);
      expect(calendar.summary.activeDays, 1);
      expect(calendar.summary.totalMinutes, 10);
    });

    test('treats the goal threshold as inclusive', () {
      final calendar = builder(
        [
          session('2026-11-01', seconds: 599),
          session('2026-11-02', seconds: 600),
        ],
        DateTime(2026, 11, 7),
      );

      expect(calendar.days['2026-11-01']!.goalMet, isFalse);
      expect(calendar.days['2026-11-02']!.goalMet, isTrue);
    });

    test('finds the longest run of goal-completing days', () {
      final calendar = builder(
        [
          session('2026-11-01'),
          session('2026-11-02'),
          session('2026-11-03'),
          session('2026-11-04', seconds: 120),
          session('2026-11-05'),
          session('2026-11-06'),
        ],
        DateTime(2026, 11, 7),
      );

      expect(calendar.summary.activeDays, 6);
      expect(calendar.summary.longestStreak, 3);
    });

    test('does not merge days across a month boundary', () {
      final calendar = builder(
        [
          session('2026-10-31'),
          session('2026-11-01'),
        ],
        DateTime(2026, 11, 1),
      );

      expect(calendar.days.keys, ['2026-11-01']);
      expect(calendar.summary.longestStreak, 1);
    });
  });

  group('AppDatabase.getSessionsForDateRange', () {
    test('returns sessions within the inclusive range only', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));

      for (final date in [
        '2026-10-31',
        '2026-11-01',
        '2026-11-30',
        '2026-12-01',
      ]) {
        await db.insertSession(
          ReadingSessionsCompanion.insert(
            bookId: bookId,
            date: date,
            durationSeconds: 600,
          ),
        );
      }

      final sessions = await db.getSessionsForDateRange(
        '2026-11-01',
        '2026-11-30',
      );

      expect(sessions.map((session) => session.date), [
        '2026-11-01',
        '2026-11-30',
      ]);
    });
  });

  group('Reading calendar screen', () {
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

    testWidgets('opens from the library and shows activity and day details',
        (tester) async {
      final today = DateOnly.fromDate(DateTime.now());
      final todayKey = DateOnly.key(today);

      final db = await pumpApp(
        tester,
        seed: (db) async {
          final bookId =
              await db.insertBook(BooksCompanion.insert(title: 'Book'));
          await db.insertSession(
            ReadingSessionsCompanion.insert(
              bookId: bookId,
              date: todayKey,
              durationSeconds: 300,
              pagesRead: const Value(3),
            ),
          );
          await db.insertSession(
            ReadingSessionsCompanion.insert(
              bookId: bookId,
              date: todayKey,
              durationSeconds: 300,
              pagesRead: const Value(5),
            ),
          );
        },
      );

      await tester.tap(find.byKey(const ValueKey('open-reading-calendar')));
      await tester.pumpAndSettle();

      expect(find.text('تقويم القراءة'), findsOneWidget);
      expect(find.text('10 د'), findsOneWidget);
      expect(find.text('لا يوجد نشاط قراءة هذا الشهر.'), findsNothing);

      await tester.tap(find.byKey(ValueKey('calendar-day-$todayKey')));
      await tester.pumpAndSettle();

      expect(find.text('مدة القراءة'), findsOneWidget);
      expect(find.text('10 دقيقة'), findsOneWidget);
      expect(find.text('8 صفحة'), findsOneWidget);
      expect(find.text('الجلسات'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(find.text('تم تحقيق الهدف'), findsWidgets);

      await tester.tap(find.widgetWithText(FilledButton, 'حسناً'));
      await tester.pumpAndSettle();
      expect(find.text('مدة القراءة'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('ملخص الشهر'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('ملخص الشهر'), findsOneWidget);
      expect(find.text('أيام القراءة النشطة'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('calendar-prev-month')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('لا يوجد نشاط قراءة هذا الشهر.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('لا يوجد نشاط قراءة هذا الشهر.'), findsOneWidget);
      expect(await db.getAllSessions(), hasLength(2));
    });

    testWidgets('shows an empty summary for a month without sessions',
        (tester) async {
      await pumpApp(
        tester,
        seed: (db) => db.insertBook(BooksCompanion.insert(title: 'Book')),
      );

      await tester.tap(find.byKey(const ValueKey('open-reading-calendar')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('لا يوجد نشاط قراءة هذا الشهر.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('لا يوجد نشاط قراءة هذا الشهر.'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });
  });
}
