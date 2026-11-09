import 'package:drift/drift.dart';
import 'dart:convert';

import '../../../core/utils/sync_id.dart';
import 'connection/connection.dart' as connection;
import 'tables/books_table.dart';
import 'tables/book_completions_table.dart';
import 'tables/annotations_tables.dart';
import 'tables/reading_sessions_table.dart';
import 'tables/sync_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Books,
    BookCompletions,
    ReadingSessions,
    Bookmarks,
    Highlights,
    Notes,
    JournalEntries,
    Collections,
    BookCollections,
    AchievementUnlocks,
    SyncRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(readingSessions, readingSessions.startTime);
            await m.addColumn(readingSessions, readingSessions.endTime);
            await m.addColumn(readingSessions, readingSessions.startingPage);
            await m.addColumn(readingSessions, readingSessions.endingPage);
            await m.addColumn(
              readingSessions,
              readingSessions.activeSegmentStartedAt,
            );
          }
          if (from < 3) {
            await m.createTable(bookmarks);
            await m.createTable(highlights);
          }
          if (from < 4) {
            await m.createTable(notes);
          }
          if (from < 5) {
            await m.createTable(journalEntries);
          }
          if (from < 6) {
            await m.addColumn(books, books.author);
            await m.addColumn(books, books.totalPages);
            await m.addColumn(books, books.readingStatus);
            await m.createTable(collections);
            await m.createTable(bookCollections);
            await customStatement(
              "UPDATE books SET reading_status = 'completed' "
              'WHERE is_completed = 1',
            );
          }
          if (from < 7) {
            await m.createTable(achievementUnlocks);
          }
          if (from < 8) {
            await m.createTable(syncRecords);
          }
          if (from < 9) {
            await m.addColumn(readingSessions, readingSessions.readingMode);
            await m.addColumn(readingSessions, readingSessions.note);
          }
          if (from < 10) {
            await m.addColumn(books, books.coverPath);
            await m.addColumn(books, books.description);
            await m.addColumn(books, books.completionDate);
            await m.addColumn(books, books.addedAsPreviouslyCompleted);
            await m.createTable(bookCompletions);
          }
          if (from < 12) {
            await m.addColumn(books, books.syncId);
            await m.addColumn(readingSessions, readingSessions.syncId);
            await _backfillSyncIds();
          }
          if (from < 11) {
            // Older builds compounded elapsed time on every autosave. Finished
            // sessions can never contain more active time than their own
            // start/end window, so cap only the impossible records while
            // preserving everything that is recoverable.
            await repairInflatedReadingDurations();
          }
        },
      );

  // Books
  Future<List<Book>> getAllBooks() => select(books).get();
  Future<List<BookCompletion>> getBookCompletions(int bookId) =>
      (select(bookCompletions)
            ..where((table) => table.bookId.equals(bookId))
            ..orderBy([(table) => OrderingTerm.desc(table.completedAt)]))
          .get();
  Future<int> addBookCompletion({
    required int bookId,
    required DateTime completedAt,
    required bool historical,
  }) =>
      into(bookCompletions).insert(
        BookCompletionsCompanion.insert(
          bookId: bookId,
          completedAt: completedAt,
          historical: Value(historical),
        ),
      );
  Future<int> insertBook(BooksCompanion book) async {
    final companion = book.syncId.present
        ? book
        : book.copyWith(syncId: Value(SyncId.generate()));
    final id = await into(books).insert(companion);
    await _queueBook(id);
    return id;
  }

  Future<bool> updateBook(BooksCompanion book) async {
    final updated = await update(books).replace(book);
    if (updated) await _queueBook(book.id.value);
    return updated;
  }

  /// Deletes a book and its reading sessions in one transaction so streak and
  /// page totals never keep counting sessions from a removed book.
  ///
  /// Tombstones are queued for the book and its sessions so cloud sync can
  /// propagate the deletion. The explicit session delete also works when
  /// SQLite foreign-key enforcement is disabled.
  Future<int> deleteBook(int id) {
    return transaction(() async {
      final book = await (select(books)..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();
      final sessions = await (select(readingSessions)
            ..where((tbl) => tbl.bookId.equals(id)))
          .get();
      final now = DateTime.now().toUtc();
      for (final session in sessions) {
        await _enqueueSyncTombstone(
          recordKey: _sessionSyncKey(session),
          entityType: 'reading_session',
          updatedAt: now,
        );
      }
      if (book != null) {
        await _enqueueSyncTombstone(
          recordKey: _bookSyncKey(book),
          entityType: 'book',
          updatedAt: now,
        );
      }
      await (delete(readingSessions)..where((tbl) => tbl.bookId.equals(id)))
          .go();
      await (delete(bookmarks)..where((tbl) => tbl.bookId.equals(id))).go();
      await (delete(highlights)..where((tbl) => tbl.bookId.equals(id))).go();
      await (delete(notes)..where((tbl) => tbl.bookId.equals(id))).go();
      await (delete(journalEntries)..where((tbl) => tbl.bookId.equals(id)))
          .go();
      await (delete(bookCompletions)..where((tbl) => tbl.bookId.equals(id)))
          .go();
      await (delete(bookCollections)..where((tbl) => tbl.bookId.equals(id)))
          .go();
      return (delete(books)..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  Future<void> updateBookLastPage(int id, int lastPage) async {
    final updated = await (update(books)..where((tbl) => tbl.id.equals(id)))
        .write(BooksCompanion(lastPage: Value(lastPage)));
    if (updated > 0) await _queueBook(id);
  }

  Future<void> updateBookStatus(
    int id,
    String status, {
    DateTime? completionDate,
    bool? historical,
  }) async {
    final current = await (select(books)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    final isCompleted = status == 'completed';
    await (update(books)..where((tbl) => tbl.id.equals(id))).write(
      BooksCompanion(
        readingStatus: Value(status),
        isCompleted: Value(isCompleted),
        completionDate: isCompleted
            ? Value(completionDate)
            : const Value(null),
        addedAsPreviouslyCompleted: isCompleted
            ? Value(historical ?? false)
            : const Value(false),
      ),
    );
    if (isCompleted && current?.readingStatus != 'completed') {
      final when = completionDate ?? DateTime.now();
      final existing = await getBookCompletions(id);
      if (existing.isEmpty || existing.first.completedAt != when) {
        await addBookCompletion(
          bookId: id,
          completedAt: when,
          historical: historical ?? false,
        );
      }
    } else if (!isCompleted && current?.readingStatus == 'completed') {
      // Undo the current completion without destroying older explicit history.
      final completions = await getBookCompletions(id);
      if (completions.isNotEmpty) {
        final currentDate = current?.completionDate;
        BookCompletion? target;
        if (currentDate != null) {
          for (final row in completions) {
            if (row.completedAt == currentDate && !row.historical) {
              target = row;
              break;
            }
          }
        }
        target ??= completions.firstWhere(
          (row) => !row.historical,
          orElse: () => completions.first,
        );
        await (delete(bookCompletions)
              ..where((tbl) => tbl.id.equals(target!.id)))
            .go();
      }
    }
    await _queueBook(id);
  }

  // Reading sessions
  Future<int> insertSession(ReadingSessionsCompanion session) async {
    final companion = session.syncId.present
        ? session
        : session.copyWith(syncId: Value(SyncId.generate()));
    final id = await into(readingSessions).insert(companion);
    await _queueSession(id);
    return id;
  }

  Future<List<ReadingSession>> getAllSessions() => (select(readingSessions)
        ..where((tbl) => tbl.startTime.isNull() | tbl.endTime.isNotNull()))
      .get();
  Future<ReadingSession?> getActiveSession(int bookId) async {
    final rows = await (select(readingSessions)
          ..where((tbl) =>
              tbl.bookId.equals(bookId) &
              tbl.startTime.isNotNull() &
              tbl.endTime.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> insertActiveSession(ReadingSessionsCompanion session) {
    return transaction(() async {
      final existing = await (select(readingSessions)
            ..where((tbl) =>
                tbl.bookId.equals(session.bookId.value) &
                tbl.startTime.isNotNull() &
                tbl.endTime.isNull())
            ..limit(1))
          .getSingleOrNull();
      if (existing != null) return existing.id;
      final companion = session.syncId.present
          ? session
          : session.copyWith(syncId: Value(SyncId.generate()));
      return into(readingSessions).insert(companion);
    });
  }

  Future<bool> updateSession(
    int id,
    ReadingSessionsCompanion session,
  ) async {
    final updated = await (update(readingSessions)
          ..where((tbl) => tbl.id.equals(id)))
        .write(session);
    if (updated > 0) await _queueSession(id);
    return updated > 0;
  }

  Future<int> deleteSession(int id) async {
    final session = await (select(readingSessions)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    final deleted = await (delete(readingSessions)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    if (deleted > 0 && session != null) {
      await _enqueueSyncTombstone(
        recordKey: _sessionSyncKey(session),
        entityType: 'reading_session',
        updatedAt: DateTime.now().toUtc(),
      );
    }
    return deleted;
  }

  /// Repairs historical sessions whose persisted duration is larger than the
  /// wall-clock window in which the session existed.
  ///
  /// The old timer wrote an inflated cumulative value on every autosave, but
  /// active reading can never exceed `endTime - startTime`. Capping such rows
  /// keeps the recoverable upper bound instead of deleting user history.
  /// Sessions without both timestamps (legacy records) are left untouched.
  Future<int> repairInflatedReadingDurations({bool enqueueSync = true}) async {
    final rows = await select(readingSessions).get();
    var repaired = 0;
    for (final session in rows) {
      final start = session.startTime;
      final end = session.endTime;
      if (start == null || end == null) continue;
      final wallClockSeconds = end.difference(start).inSeconds;
      if (wallClockSeconds < 0) continue;
      if (session.durationSeconds <= wallClockSeconds) continue;

      await (update(readingSessions)
            ..where((table) => table.id.equals(session.id)))
          .write(
        ReadingSessionsCompanion(
          durationSeconds: Value(wallClockSeconds),
        ),
      );
      repaired++;
      if (enqueueSync) await _queueSession(session.id);
    }
    return repaired;
  }

  Future<List<ReadingSession>> getSessionsForDate(String date) =>
      (select(readingSessions)..where((tbl) => tbl.date.equals(date))).get();
  Future<List<ReadingSession>> getSessionsForBook(int bookId) =>
      (select(readingSessions)
            ..where((tbl) =>
                tbl.bookId.equals(bookId) &
                (tbl.startTime.isNull() | tbl.endTime.isNotNull()))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)]))
          .get();

  /// Inclusive range query over the `YYYY-MM-DD` date column.
  Future<List<ReadingSession>> getSessionsForDateRange(
    String startDate,
    String endDate,
  ) =>
      (select(readingSessions)
            ..where((tbl) =>
                tbl.date.isBetweenValues(startDate, endDate) &
                (tbl.startTime.isNull() | tbl.endTime.isNotNull())))
          .get();

  // PDF annotations
  Future<List<Bookmark>> getBookmarks(int bookId) => (select(bookmarks)
        ..where((tbl) => tbl.bookId.equals(bookId))
        ..orderBy([
          (tbl) => OrderingTerm.asc(tbl.pageNumber),
          (tbl) => OrderingTerm.asc(tbl.id),
        ]))
      .get();

  Future<int> addBookmark(BookmarksCompanion bookmark) =>
      into(bookmarks).insert(bookmark);

  Future<bool> updateBookmark(int id, BookmarksCompanion bookmark) =>
      (update(bookmarks)..where((tbl) => tbl.id.equals(id)))
          .write(bookmark)
          .then((count) => count > 0);

  Future<int> deleteBookmark(int id) =>
      (delete(bookmarks)..where((tbl) => tbl.id.equals(id))).go();

  Future<Bookmark?> getBookmarkForPage(int bookId, int pageNumber) =>
      (select(bookmarks)
            ..where((tbl) =>
                tbl.bookId.equals(bookId) & tbl.pageNumber.equals(pageNumber))
            ..limit(1))
          .getSingleOrNull();

  Future<List<Highlight>> getHighlights(int bookId) => (select(highlights)
        ..where((tbl) => tbl.bookId.equals(bookId))
        ..orderBy([
          (tbl) => OrderingTerm.asc(tbl.pageNumber),
          (tbl) => OrderingTerm.asc(tbl.id),
        ]))
      .get();

  Future<int> addHighlight(HighlightsCompanion highlight) =>
      into(highlights).insert(highlight);

  Future<bool> updateHighlight(int id, HighlightsCompanion highlight) =>
      (update(highlights)..where((tbl) => tbl.id.equals(id)))
          .write(highlight)
          .then((count) => count > 0);

  Future<int> deleteHighlight(int id) =>
      (delete(highlights)..where((tbl) => tbl.id.equals(id))).go();

  // Personal notes
  Future<List<Note>> getNotes(int bookId, {String query = ''}) {
    final normalizedQuery = query.trim();
    final statement = select(notes)
      ..where((tbl) => tbl.bookId.equals(bookId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.modifiedAt)]);
    if (normalizedQuery.isNotEmpty) {
      statement.where(
        (tbl) => tbl.content.like('%$normalizedQuery%'),
      );
    }
    return statement.get();
  }

  Future<int> addNote(NotesCompanion note) => into(notes).insert(note);

  Future<bool> updateNote(int id, NotesCompanion note) =>
      (update(notes)..where((tbl) => tbl.id.equals(id)))
          .write(note)
          .then((count) => count > 0);

  Future<int> deleteNote(int id) =>
      (delete(notes)..where((tbl) => tbl.id.equals(id))).go();

  // Reading journal
  Future<List<JournalEntry>> getJournalEntries({
    int? bookId,
    String query = '',
  }) {
    final normalizedQuery = query.trim();
    final statement = select(journalEntries)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    if (bookId != null) {
      statement.where((tbl) => tbl.bookId.equals(bookId));
    }
    if (normalizedQuery.isNotEmpty) {
      statement.where(
        (tbl) =>
            tbl.title.like('%$normalizedQuery%') |
            tbl.reflection.like('%$normalizedQuery%'),
      );
    }
    return statement.get();
  }

  Future<int> addJournalEntry(JournalEntriesCompanion entry) =>
      into(journalEntries).insert(entry);

  Future<bool> updateJournalEntry(
    int id,
    JournalEntriesCompanion entry,
  ) =>
      (update(journalEntries)..where((tbl) => tbl.id.equals(id)))
          .write(entry)
          .then((count) => count > 0);

  Future<int> deleteJournalEntry(int id) =>
      (delete(journalEntries)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<Collection>> getCollections() =>
      (select(collections)..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
          .get();

  Future<int> addCollection(CollectionsCompanion collection) =>
      into(collections).insert(collection);

  Future<bool> updateCollection(int id, CollectionsCompanion collection) =>
      (update(collections)..where((tbl) => tbl.id.equals(id)))
          .write(collection)
          .then((count) => count > 0);

  Future<int> deleteCollection(int id) async {
    await (delete(bookCollections)..where((tbl) => tbl.collectionId.equals(id)))
        .go();
    return (delete(collections)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<int>> getBookCollectionIds(int bookId) async {
    final rows = await (select(bookCollections)
          ..where((tbl) => tbl.bookId.equals(bookId)))
        .get();
    return rows.map((row) => row.collectionId).toList();
  }

  Future<void> setBookCollections(int bookId, Iterable<int> collectionIds) {
    return transaction(() async {
      await (delete(bookCollections)..where((tbl) => tbl.bookId.equals(bookId)))
          .go();
      await batch((batch) {
        batch.insertAll(
          bookCollections,
          collectionIds
              .map(
                (collectionId) => BookCollectionsCompanion.insert(
                  bookId: bookId,
                  collectionId: collectionId,
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<int> countBooksInCollection(int collectionId) async {
    final rows = await (select(bookCollections)
          ..where((tbl) => tbl.collectionId.equals(collectionId)))
        .get();
    return rows.length;
  }

  Future<void> _backfillSyncIds() async {
    final allBooks = await select(books).get();
    for (final book in allBooks) {
      if (SyncId.isValid(book.syncId)) continue;
      await (update(books)..where((tbl) => tbl.id.equals(book.id))).write(
        BooksCompanion(syncId: Value(SyncId.generate())),
      );
    }
    final allSessions = await select(readingSessions).get();
    for (final session in allSessions) {
      if (SyncId.isValid(session.syncId)) continue;
      await (update(readingSessions)
            ..where((tbl) => tbl.id.equals(session.id)))
          .write(ReadingSessionsCompanion(syncId: Value(SyncId.generate())));
    }
    await _migrateLegacyPendingSyncRecords();
  }

  Future<void> _migrateLegacyPendingSyncRecords() async {
    final pending = await getPendingSyncRecords();
    for (final record in pending) {
      if (record.entityType == 'book' && record.recordKey.startsWith('book:')) {
        final suffix = record.recordKey.substring('book:'.length);
        if (SyncId.isValid(suffix)) continue;
        final id = int.tryParse(suffix);
        if (id == null) continue;
        final book = await (select(books)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (book == null) continue;
        await (delete(syncRecords)..where((t) => t.id.equals(record.id))).go();
        await _queueBook(book.id);
      } else if (record.entityType == 'reading_session' &&
          record.recordKey.startsWith('session:')) {
        final suffix = record.recordKey.substring('session:'.length);
        if (SyncId.isValid(suffix)) continue;
        final id = int.tryParse(suffix);
        if (id == null) continue;
        final session = await (select(readingSessions)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (session == null) continue;
        await (delete(syncRecords)..where((t) => t.id.equals(record.id))).go();
        await _queueSession(session.id);
      }
    }
  }

  String _bookSyncKey(Book book) {
    final syncId = book.syncId;
    if (SyncId.isValid(syncId)) return 'book:$syncId';
    return 'book:legacy:${book.id}';
  }

  String _sessionSyncKey(ReadingSession session) {
    final syncId = session.syncId;
    if (SyncId.isValid(syncId)) return 'session:$syncId';
    return 'session:legacy:${session.id}';
  }

  Future<String> _ensureBookSyncId(int id) async {
    final book =
        await (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (book == null) {
      throw StateError('Book $id not found');
    }
    if (SyncId.isValid(book.syncId)) return book.syncId!;
    final syncId = SyncId.generate();
    await (update(books)..where((t) => t.id.equals(id))).write(
      BooksCompanion(syncId: Value(syncId)),
    );
    return syncId;
  }

  Future<String> _ensureSessionSyncId(int id) async {
    final session = await (select(readingSessions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (session == null) {
      throw StateError('Session $id not found');
    }
    if (SyncId.isValid(session.syncId)) return session.syncId!;
    final syncId = SyncId.generate();
    await (update(readingSessions)..where((t) => t.id.equals(id))).write(
      ReadingSessionsCompanion(syncId: Value(syncId)),
    );
    return syncId;
  }

  Future<Book?> _bookBySyncId(String syncId) =>
      (select(books)..where((t) => t.syncId.equals(syncId))).getSingleOrNull();

  Future<void> _queueBook(int id) async {
    final book = await (select(books)..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    if (book == null) return;
    final syncId = SyncId.isValid(book.syncId)
        ? book.syncId!
        : await _ensureBookSyncId(id);
    await enqueueSyncRecord(
      recordKey: 'book:$syncId',
      entityType: 'book',
      payload: jsonEncode({
        'syncId': syncId,
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'totalPages': book.totalPages,
        'lastPage': book.lastPage,
        'isCompleted': book.isCompleted,
        'readingStatus': book.readingStatus,
        'coverPath': book.coverPath,
        'description': book.description,
        'completionDate': book.completionDate?.toUtc().toIso8601String(),
        'addedAsPreviouslyCompleted': book.addedAsPreviouslyCompleted,
        'createdAt': book.createdAt.toUtc().toIso8601String(),
      }),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _queueSession(int id) async {
    final session = await (select(readingSessions)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    if (session == null) return;
    final syncId = SyncId.isValid(session.syncId)
        ? session.syncId!
        : await _ensureSessionSyncId(id);
    final book = await (select(books)
          ..where((table) => table.id.equals(session.bookId)))
        .getSingleOrNull();
    final bookSyncId = book == null
        ? null
        : (SyncId.isValid(book.syncId)
            ? book.syncId!
            : await _ensureBookSyncId(book.id));
    await enqueueSyncRecord(
      recordKey: 'session:$syncId',
      entityType: 'reading_session',
      payload: jsonEncode({
        'syncId': syncId,
        'id': session.id,
        'bookId': session.bookId,
        'bookSyncId': bookSyncId,
        'date': session.date,
        'startTime': session.startTime?.toUtc().toIso8601String(),
        'endTime': session.endTime?.toUtc().toIso8601String(),
        'durationSeconds': session.durationSeconds,
        'pagesRead': session.pagesRead,
        'startingPage': session.startingPage,
        'endingPage': session.endingPage,
        'readingMode': session.readingMode,
        'note': session.note,
      }),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _enqueueSyncTombstone({
    required String recordKey,
    required String entityType,
    required DateTime updatedAt,
  }) {
    final payload = jsonEncode(
      entityType == 'book'
          ? {
              'syncId': recordKey.startsWith('book:')
                  ? recordKey.substring('book:'.length)
                  : recordKey,
            }
          : {
              'syncId': recordKey.startsWith('session:')
                  ? recordKey.substring('session:'.length)
                  : recordKey,
            },
    );
    return enqueueSyncRecord(
      recordKey: recordKey,
      entityType: entityType,
      payload: payload,
      updatedAt: updatedAt,
      deleted: true,
    );
  }

  Future<List<AchievementUnlock>> getAchievementUnlocks() =>
      select(achievementUnlocks).get();

  Future<bool> saveAchievementUnlock(
    AchievementUnlocksCompanion unlock,
  ) async {
    final existing = await (select(achievementUnlocks)
          ..where(
              (tbl) => tbl.achievementId.equals(unlock.achievementId.value)))
        .getSingleOrNull();
    if (existing != null) return false;
    final inserted = await into(achievementUnlocks).insert(
      unlock,
    );
    return inserted > 0;
  }

  Future<List<SyncRecord>> getPendingSyncRecords() =>
      (select(syncRecords)..where((table) => table.pending.equals(true))).get();

  Future<List<SyncRecord>> getAllSyncRecords() => select(syncRecords).get();

  Future<void> saveSyncRecord(SyncRecordsCompanion record) async {
    await transaction(() async {
      final key = record.recordKey.value;
      await (delete(syncRecords)..where((table) => table.recordKey.equals(key)))
          .go();
      await into(syncRecords).insert(record);
    });
  }

  Future<void> applyRemoteSyncRecord({
    required String entityType,
    required String payload,
    bool deleted = false,
  }) async {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final syncId = data['syncId'] as String? ?? data['sync_id'] as String?;
    if (entityType == 'book') {
      if (deleted) {
        if (SyncId.isValid(syncId)) await _deleteBookBySyncId(syncId!);
        return;
      }
      await _applyRemoteBook(data, syncId);
    } else if (entityType == 'reading_session') {
      if (deleted) {
        if (SyncId.isValid(syncId)) await _deleteSessionBySyncId(syncId!);
        return;
      }
      await _applyRemoteSession(data, syncId);
    }
  }

  Future<void> _deleteBookBySyncId(String syncId) async {
    final book = await _bookBySyncId(syncId);
    if (book == null) return;
    await deleteBook(book.id);
  }

  Future<void> _deleteSessionBySyncId(String syncId) async {
    final session = await (select(readingSessions)
          ..where((t) => t.syncId.equals(syncId)))
        .getSingleOrNull();
    if (session == null) return;
    await (delete(readingSessions)..where((t) => t.id.equals(session.id))).go();
  }

  Future<void> _applyRemoteBook(
    Map<String, dynamic> data,
    String? syncId,
  ) async {
    final validSyncId = SyncId.isValid(syncId) ? syncId : null;
    final legacyId = data['id'] as int?;
    Book? existing;
    if (validSyncId != null) {
      existing = await _bookBySyncId(validSyncId);
    } else if (legacyId != null) {
      // Legacy local-id payloads are unsafe across devices; only reuse a local
      // row if it already has no sync identity (pre-migration edge case).
      existing = await (select(books)..where((t) => t.id.equals(legacyId)))
          .getSingleOrNull();
      if (existing != null && SyncId.isValid(existing.syncId)) {
        return;
      }
    }
    if (validSyncId == null && existing == null) return;

    final resolvedSyncId = validSyncId ?? existing?.syncId ?? SyncId.generate();
    final companion = BooksCompanion(
      syncId: Value(resolvedSyncId),
      title: Value(data['title'] as String? ?? 'Untitled'),
      author: Value(data['author'] as String?),
      totalPages: Value(data['totalPages'] as int?),
      lastPage: Value(data['lastPage'] as int? ?? 0),
      isCompleted: Value(data['isCompleted'] as bool? ?? false),
      readingStatus:
          Value(data['readingStatus'] as String? ?? 'want_to_read'),
      coverPath: Value(data['coverPath'] as String?),
      description: Value(data['description'] as String?),
      completionDate: Value(data['completionDate'] == null
          ? null
          : DateTime.parse(data['completionDate'] as String)),
      addedAsPreviouslyCompleted:
          Value(data['addedAsPreviouslyCompleted'] as bool? ?? false),
      createdAt: Value(
        data['createdAt'] == null
            ? DateTime.now().toUtc()
            : DateTime.parse(data['createdAt'] as String),
      ),
      filePath:
          existing == null ? const Value.absent() : Value(existing.filePath),
      fileName:
          existing == null ? const Value.absent() : Value(existing.fileName),
      fileSize:
          existing == null ? const Value.absent() : Value(existing.fileSize),
    );
    final existingBook = existing;
    if (existingBook == null) {
      await into(books).insert(companion);
    } else {
      await (update(books)..where((table) => table.id.equals(existingBook.id)))
          .write(companion);
    }
  }

  Future<void> _applyRemoteSession(
    Map<String, dynamic> data,
    String? syncId,
  ) async {
    final validSyncId = SyncId.isValid(syncId) ? syncId : null;
    if (validSyncId == null) return;

    final bookSyncId =
        data['bookSyncId'] as String? ?? data['book_sync_id'] as String?;
    int? localBookId;
    if (SyncId.isValid(bookSyncId)) {
      localBookId = (await _bookBySyncId(bookSyncId!))?.id;
    }
    localBookId ??= await _resolveLegacySessionBookId(data);
    if (localBookId == null) return;

    final existing = await (select(readingSessions)
          ..where((t) => t.syncId.equals(validSyncId)))
        .getSingleOrNull();
    final startTime = data['startTime'] == null
        ? null
        : DateTime.parse(data['startTime'] as String);
    final endTime = data['endTime'] == null
        ? null
        : DateTime.parse(data['endTime'] as String);
    final remoteSeconds = data['durationSeconds'] as int? ?? 0;
    final companion = ReadingSessionsCompanion(
      syncId: Value(validSyncId),
      bookId: Value(localBookId),
      date: Value(
        data['date'] as String? ??
            (startTime == null
                ? ''
                : startTime.toIso8601String().substring(0, 10)),
      ),
      durationSeconds: Value(
        _sanitizeSessionDuration(remoteSeconds, startTime, endTime),
      ),
      pagesRead: Value(data['pagesRead'] as int? ?? 0),
      startingPage: Value(data['startingPage'] as int?),
      endingPage: Value(data['endingPage'] as int?),
      readingMode: Value(data['readingMode'] as String? ?? 'digital'),
      note: Value(data['note'] as String?),
      startTime: Value(startTime),
      endTime: Value(endTime),
    );
    if (existing == null) {
      await into(readingSessions).insert(companion);
    } else {
      await (update(readingSessions)
            ..where((t) => t.id.equals(existing.id)))
          .write(companion);
    }
  }

  Future<int?> _resolveLegacySessionBookId(Map<String, dynamic> data) async {
    final legacyBookId = data['bookId'] as int?;
    if (legacyBookId == null) return null;
    final local = await (select(books)..where((t) => t.id.equals(legacyBookId)))
        .getSingleOrNull();
    if (local != null && !SyncId.isValid(local.syncId)) return local.id;
    return null;
  }

  /// Prevents an inflated remote payload from re-introducing impossible
  /// durations after the local repair has run.
  int _sanitizeSessionDuration(
    int seconds,
    DateTime? startTime,
    DateTime? endTime,
  ) {
    if (seconds <= 0 || startTime == null || endTime == null) return seconds;
    final wallClockSeconds = endTime.difference(startTime).inSeconds;
    if (wallClockSeconds < 0) return seconds;
    return seconds > wallClockSeconds ? wallClockSeconds : seconds;
  }

  Future<void> markSyncRecordsUploaded(Iterable<int> ids) async {
    if (ids.isEmpty) return;
    await (update(syncRecords)..where((table) => table.id.isIn(ids))).write(
      const SyncRecordsCompanion(pending: Value(false)),
    );
  }

  Future<void> enqueueSyncRecord({
    required String recordKey,
    required String entityType,
    required String payload,
    required DateTime updatedAt,
    bool deleted = false,
  }) =>
      saveSyncRecord(
        SyncRecordsCompanion.insert(
          recordKey: recordKey,
          entityType: entityType,
          payload: payload,
          updatedAt: updatedAt,
          deleted: Value(deleted),
        ),
      );
}
