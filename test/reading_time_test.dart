import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/core/utils/date_only.dart';
import 'package:streak_reader/src/core/utils/duration_units.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/entities/daily_goal_history.dart';
import 'package:streak_reader/src/domain/entities/daily_goal_progress.dart';
import 'package:streak_reader/src/domain/entities/monthly_goal.dart';
import 'package:streak_reader/src/domain/entities/reading_statistics.dart';
import 'package:streak_reader/src/domain/usecases/calculate_monthly_progress.dart';
import 'package:streak_reader/src/domain/usecases/calculate_streak.dart';
import 'package:streak_reader/src/features/reader/providers/reading_session_provider.dart';

class FakeClock {
  DateTime current;

  FakeClock(this.current);

  DateTime now() => current;

  void advance(Duration duration) {
    current = current.add(duration);
  }
}

void main() {
  Future<(AppDatabase, int)> createDatabase() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    return (db, bookId);
  }

  group('Reading session timer', () {
    for (final minutes in [5, 20, 60]) {
      test('records exactly $minutes minutes of active reading', () async {
        final (db, bookId) = await createDatabase();
        addTearDown(db.close);
        final clock = FakeClock(DateTime(2026, 11, 8, 9));
        final controller = ReadingSessionController(db, now: clock.now);
        addTearDown(controller.dispose);

        controller.start(bookId, 1);
        clock.advance(Duration(minutes: minutes));
        await controller.finish();

        final session = (await db.getSessionsForBook(bookId)).single;
        expect(
            session.durationSeconds, DurationUnits.minutesToSeconds(minutes));
        expect(session.endTime, clock.current);
        expect(
            controller.elapsedSeconds, DurationUnits.minutesToSeconds(minutes));
      });
    }

    test('autosave checkpoints never compound the elapsed time', () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));
      final controller = ReadingSessionController(db, now: clock.now);
      addTearDown(controller.dispose);

      controller.start(bookId, 1);
      // 20 minutes of reading with the 15-second autosave cadence.
      for (var tick = 1; tick <= 80; tick++) {
        clock.advance(const Duration(seconds: 15));
        await controller.persistCurrentPage();
        expect(controller.elapsedSeconds, tick * 15);
      }

      await controller.finish();

      final sessions = await db.getSessionsForBook(bookId);
      expect(sessions, hasLength(1));
      expect(sessions.single.durationSeconds, 20 * 60);
    });

    test('paused time never contributes to the session duration', () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));
      final controller = ReadingSessionController(db, now: clock.now);
      addTearDown(controller.dispose);

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 5));
      await controller.pause();
      expect(controller.elapsedSeconds, 5 * 60);

      clock.advance(const Duration(minutes: 10));
      await controller.persistCurrentPage();
      expect(controller.elapsedSeconds, 5 * 60);

      await controller.finish();
      final session = (await db.getSessionsForBook(bookId)).single;
      expect(session.durationSeconds, 5 * 60);
    });

    test('resume continues from the accumulated duration', () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));
      final controller = ReadingSessionController(db, now: clock.now);
      addTearDown(controller.dispose);

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 5));
      await controller.pause();
      clock.advance(const Duration(minutes: 10));
      await controller.resume();
      clock.advance(const Duration(minutes: 5));
      await controller.finish();

      final session = (await db.getSessionsForBook(bookId)).single;
      expect(session.durationSeconds, 10 * 60);
    });

    test('backgrounding pauses and returning resumes without duplication',
        () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));
      final controller = ReadingSessionController(db, now: clock.now);
      addTearDown(controller.dispose);

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 7));

      // App goes to the background: the same paths used by the reader's
      // lifecycle observer.
      await controller.pause();
      await controller.persistCurrentPage();
      clock.advance(const Duration(minutes: 30));

      // App returns and the automatic pause is resumed.
      await controller.resume();
      clock.advance(const Duration(minutes: 3));
      await controller.finish();

      final session = (await db.getSessionsForBook(bookId)).single;
      expect(session.durationSeconds, 10 * 60);
    });

    test('restart restores accumulated time without counting offline time',
        () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));

      final first = ReadingSessionController(db, now: clock.now);
      first.start(bookId, 1);
      clock.advance(const Duration(minutes: 5));
      await first.persistCurrentPage();
      first.dispose();

      clock.advance(const Duration(minutes: 45));
      final restored = ReadingSessionController(db, now: clock.now);
      addTearDown(restored.dispose);
      expect(await restored.restore(bookId, 1), isTrue);

      expect(restored.isActive, isFalse);
      expect(restored.isPaused, isTrue);
      expect(restored.elapsedSeconds, 5 * 60);

      await restored.finish();
      final session = (await db.getSessionsForBook(bookId)).single;
      expect(session.durationSeconds, 5 * 60);
    });

    test('finishing repeatedly persists one session and notifies once',
        () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));
      var notifications = 0;
      final controller = ReadingSessionController(
        db,
        now: clock.now,
        onSessionSaved: () => notifications++,
      );
      addTearDown(controller.dispose);

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 5));
      await Future.wait([controller.finish(), controller.finish()]);
      await controller.finish();

      final sessions = await db.getSessionsForBook(bookId);
      expect(sessions, hasLength(1));
      expect(sessions.single.durationSeconds, 5 * 60);
      expect(notifications, 1);
    });

    test('finishing while an autosave is in flight keeps one exact record',
        () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));
      final controller = ReadingSessionController(db, now: clock.now);
      addTearDown(controller.dispose);

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 20));
      await Future.wait([
        controller.persistCurrentPage(),
        controller.finish(),
      ]);

      final sessions = await db.getSessionsForBook(bookId);
      expect(sessions, hasLength(1));
      expect(sessions.single.durationSeconds, 20 * 60);
    });
  });

  group('Statistics aggregation', () {
    test('multiple sessions aggregate once per session', () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final clock = FakeClock(DateTime(2026, 11, 8, 9));
      final controller = ReadingSessionController(db, now: clock.now);
      addTearDown(controller.dispose);

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 5));
      await controller.finish();

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 15));
      await controller.finish();

      controller.start(bookId, 1);
      clock.advance(const Duration(minutes: 10));
      await controller.finish();

      final sessions = await db.getAllSessions();
      final books = await db.getAllBooks();
      final stats = CalculateStreak(now: clock.now)(sessions, books);
      final statistics = ReadingStatistics.fromRecords(
        sessions: sessions,
        books: books,
        now: clock.current,
      );

      expect(sessions, hasLength(3));
      expect(stats.totalMinutes, 30);
      expect(stats.todaySeconds, 30 * 60);
      expect(stats.todayMinutes, 30);
      expect(stats.currentStreak, 1);
      expect(statistics.totalSessions, 3);
      expect(statistics.averageSessionSeconds, 10 * 60);
      expect(statistics.bookProgress.single.secondsRead, 30 * 60);
    });

    test('daily goal keeps the actual duration when the goal is exceeded', () {
      const progress = DailyGoalProgress(
        secondsRead: 30 * 60,
        targetMinutes: 10,
      );

      expect(progress.minutesRead, 30);
      expect(progress.fraction, 1);
      expect(progress.percentage, 100);
      expect(progress.remainingMinutes, 0);
      expect(progress.isComplete, isTrue);
    });

    test('daily and monthly statistics use seconds consistently', () {
      ReadingSession session(String date, int seconds) => ReadingSession(
            readingMode: 'digital',
            id: 0,
            bookId: 1,
            date: date,
            durationSeconds: seconds,
            pagesRead: 0,
          );

      final sessions = [
        session('2026-11-07', 10 * 60),
        session('2026-11-08', 5 * 60),
        session('2026-12-01', 20 * 60),
      ];
      final stats = CalculateStreak(now: () => DateTime(2026, 11, 8))(
        sessions,
        [],
      );
      final monthly = const CalculateMonthlyProgress()(
        month: DateTime(2026, 11),
        goal: const MonthlyGoal({MonthlyGoalType.minutes: 10}),
        sessions: sessions,
        completedBooks: 0,
      );

      expect(stats.todaySeconds, 5 * 60);
      expect(stats.todayMinutes, 5);
      expect(stats.totalMinutes, 35);
      expect(monthly.goals.single.completed, 15);
    });

    test('streak eligibility uses the goal active on each date', () {
      final history = const DailyGoalHistory()
          .withGoalFrom(DateTime(2026, 11, 7), 10)
          .withGoalFrom(DateTime(2026, 11, 8), 5);
      ReadingSession session(String date, int seconds) => ReadingSession(
            readingMode: 'digital',
            id: 0,
            bookId: 1,
            date: date,
            durationSeconds: seconds,
            pagesRead: 0,
          );

      final stats = CalculateStreak(
        now: () => DateTime(2026, 11, 8),
        goalMinutesForDate: history.minutesForDateKey,
      )(
        [
          session('2026-11-06', 10 * 60),
          session('2026-11-07', 10 * 60),
          session('2026-11-08', 5 * 60),
        ],
        [],
      );

      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
      expect(stats.todayGoalMinutes, 5);
    });
  });

  group('Historical data repair', () {
    test('caps only impossible durations and preserves recoverable history',
        () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final start = DateTime(2026, 11, 8, 10);

      final inflatedId = await db.insertSession(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          date: DateOnly.key(start),
          durationSeconds: 456 * 60,
          startTime: Value(start),
          endTime: Value(start.add(const Duration(minutes: 20))),
        ),
      );
      final correctId = await db.insertSession(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          date: DateOnly.key(start),
          durationSeconds: 20 * 60,
          startTime: Value(start),
          endTime: Value(start.add(const Duration(minutes: 20))),
        ),
      );
      final legacyId = await db.insertSession(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          date: DateOnly.key(start),
          durationSeconds: 456 * 60,
        ),
      );

      final repaired = await db.repairInflatedReadingDurations(
        enqueueSync: false,
      );
      expect(repaired, 1);

      final sessions = {
        for (final session in await db.getSessionsForBook(bookId))
          session.id: session,
      };
      expect(sessions[inflatedId]!.durationSeconds, 20 * 60);
      expect(sessions[correctId]!.durationSeconds, 20 * 60);
      // Legacy rows have no timestamps, so there is no safe duration to infer.
      expect(sessions[legacyId]!.durationSeconds, 456 * 60);

      expect(
        await db.repairInflatedReadingDurations(enqueueSync: false),
        0,
      );
    });

    test('repair works inside the migration transaction and queues sync',
        () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final start = DateTime(2026, 11, 8, 10);
      final id = await db.insertSession(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          date: DateOnly.key(start),
          durationSeconds: 456 * 60,
          startTime: Value(start),
          endTime: Value(start.add(const Duration(minutes: 20))),
        ),
      );

      final repaired = await db.transaction(
        () => db.repairInflatedReadingDurations(),
      );

      expect(repaired, 1);
      final session = (await db.getSessionsForBook(bookId)).single;
      expect(session.id, id);
      expect(session.durationSeconds, 20 * 60);
      final pending = await db.getPendingSyncRecords();
      final sessionRecord = pending.firstWhere(
        (record) => record.recordKey == 'session:$id',
      );
      expect(sessionRecord.payload, contains('"durationSeconds":1200'));
    });

    test('remote sync cannot re-introduce an impossible duration', () async {
      final (db, bookId) = await createDatabase();
      addTearDown(db.close);
      final start = DateTime(2026, 11, 8, 10);

      await db.applyRemoteSyncRecord(
        entityType: 'reading_session',
        payload: jsonEncode({
          'id': 77,
          'bookId': bookId,
          'date': DateOnly.key(start),
          'durationSeconds': 456 * 60,
          'pagesRead': 4,
          'startTime': start.toUtc().toIso8601String(),
          'endTime':
              start.add(const Duration(minutes: 20)).toUtc().toIso8601String(),
          'readingMode': 'digital',
        }),
      );

      final session = (await db.getSessionsForBook(bookId)).single;
      expect(session.durationSeconds, 20 * 60);
    });
  });
}
