import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  test('achievement unlocks are persisted once and survive later activity',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final inserted = await db.saveAchievementUnlock(
      AchievementUnlocksCompanion.insert(
        achievementId: 'first_day',
        unlockedAt: DateTime(2026, 1, 2),
      ),
    );
    final duplicate = await db.saveAchievementUnlock(
      AchievementUnlocksCompanion.insert(
        achievementId: 'first_day',
        unlockedAt: DateTime(2026, 1, 3),
      ),
    );

    expect(inserted, isTrue);
    expect(duplicate, isFalse);
    final unlocks = await db.getAchievementUnlocks();
    expect(unlocks, hasLength(1));
    expect(unlocks.single.unlockedAt, DateTime(2026, 1, 2));
  });

  test('achievement input data comes from completed sessions and books',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(
      BooksCompanion.insert(
        title: 'Completed book',
        lastPage: const Value(100),
        isCompleted: const Value(true),
        readingStatus: const Value('completed'),
      ),
    );
    await db.insertSession(
      ReadingSessionsCompanion.insert(
        bookId: bookId,
        date: '2026-01-02',
        durationSeconds: 3600,
        pagesRead: const Value(100),
      ),
    );

    final books = await db.getAllBooks();
    final sessions = await db.getAllSessions();
    expect(books.single.isCompleted, isTrue);
    expect(sessions.single.durationSeconds, 3600);
    expect(sessions.single.pagesRead, 100);
  });
}
