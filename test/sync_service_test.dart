import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/core/sync/sync_service.dart';
import 'package:streak_reader/src/core/utils/sync_id.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  test('uninitialized sync service fails closed without throwing', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final sync = SyncService(db);

    // The settings screen reads these before main() initialization (and in
    // tests where Supabase.initialize was never called); they must not throw.
    expect(sync.isAvailable, isFalse);
    expect(sync.currentUser, isNull);
    expect(await sync.authStateChanges.first, isNull);
    expect(
      await sync.signInWithEmail('a@example.com', 'password'),
      'Sync is not available.',
    );
    expect(
      await sync.signUpWithEmail('a@example.com', 'password'),
      'Sync is not available.',
    );
  });

  group('sync records', () {
    test('queued records use stable UUID keys, not local integer IDs', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final bookId = await db.insertBook(BooksCompanion.insert(title: 'Sync'));

      final pending = await db.getPendingSyncRecords();
      expect(pending, hasLength(1));
      expect(pending.single.entityType, 'book');
      expect(pending.single.recordKey, startsWith('book:'));
      expect(pending.single.recordKey, isNot('book:$bookId'));
      final payload = jsonDecode(pending.single.payload) as Map<String, dynamic>;
      expect(SyncId.isValid(payload['syncId'] as String?), isTrue);
    });

    test('deleting a session enqueues a tombstone', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final bookId = await db.insertBook(BooksCompanion.insert(title: 'Sync'));
      final sessionId = await db.insertSession(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          date: '2026-11-09',
          durationSeconds: 60,
        ),
      );
      final session = (await db.getSessionsForBook(bookId)).single;
      await db.markSyncRecordsUploaded(
        (await db.getPendingSyncRecords()).map((record) => record.id),
      );

      await db.deleteSession(sessionId);

      final pending = await db.getPendingSyncRecords();
      final tombstone = pending.firstWhere(
        (record) => record.recordKey == 'session:${session.syncId}',
      );
      expect(tombstone.deleted, isTrue);
      expect(tombstone.entityType, 'reading_session');
    });

    test('applying a remote tombstone removes the local session', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final bookId = await db.insertBook(BooksCompanion.insert(title: 'Sync'));
      await db.insertSession(
        ReadingSessionsCompanion.insert(
          bookId: bookId,
          date: '2026-11-09',
          durationSeconds: 60,
        ),
      );
      final session = (await db.getSessionsForBook(bookId)).single;

      await db.applyRemoteSyncRecord(
        entityType: 'reading_session',
        payload: jsonEncode({'syncId': session.syncId}),
        deleted: true,
      );

      expect(await db.getSessionsForBook(bookId), isEmpty);
    });

    test('applying a remote book uses syncId, not local integer id', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final syncId = SyncId.generate();
      await db.applyRemoteSyncRecord(
        entityType: 'book',
        payload: jsonEncode({
          'syncId': syncId,
          'id': 999999,
          'title': 'Remote book',
          'readingStatus': 'want_to_read',
          'createdAt': DateTime.utc(2026, 11, 9).toIso8601String(),
        }),
      );

      final books = await db.getAllBooks();
      expect(books, hasLength(1));
      expect(books.single.syncId, syncId);
      expect(books.single.title, 'Remote book');
      expect(books.single.id, isNot(999999));
    });
  });
}
