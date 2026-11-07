import 'package:drift/drift.dart';
import 'dart:convert';

import 'connection/connection.dart' as connection;
import 'tables/books_table.dart';
import 'tables/annotations_tables.dart';
import 'tables/reading_sessions_table.dart';
import 'tables/sync_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Books,
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
  int get schemaVersion => 9;

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
        },
      );

  // Books
  Future<List<Book>> getAllBooks() => select(books).get();
  Future<int> insertBook(BooksCompanion book) async {
    final id = await into(books).insert(book);
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
  /// The explicit session delete also works when SQLite foreign-key
  /// enforcement is disabled, which is the default for Drift databases.
  Future<int> deleteBook(int id) {
    return transaction(() async {
      await (delete(readingSessions)..where((tbl) => tbl.bookId.equals(id)))
          .go();
      await (delete(bookmarks)..where((tbl) => tbl.bookId.equals(id))).go();
      await (delete(highlights)..where((tbl) => tbl.bookId.equals(id))).go();
      await (delete(notes)..where((tbl) => tbl.bookId.equals(id))).go();
      await (delete(journalEntries)..where((tbl) => tbl.bookId.equals(id)))
          .go();
      await (delete(bookCollections)..where((tbl) => tbl.bookId.equals(id)))
          .go();
      return (delete(books)..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  Future<void> updateBookLastPage(int id, int lastPage) =>
      (update(books)..where((tbl) => tbl.id.equals(id)))
          .write(BooksCompanion(lastPage: Value(lastPage)));

  // Reading sessions
  Future<int> insertSession(ReadingSessionsCompanion session) async {
    final id = await into(readingSessions).insert(session);
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
      return into(readingSessions).insert(session);
    });
  }

  Future<bool> updateSession(
    int id,
    ReadingSessionsCompanion session,
  ) async {
    final updated =
        await (update(readingSessions)..where((tbl) => tbl.id.equals(id)))
            .write(session);
    if (updated > 0) await _queueSession(id);
    return updated > 0;
  }

  Future<int> deleteSession(int id) =>
      (delete(readingSessions)..where((tbl) => tbl.id.equals(id))).go();
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

  Future<void> updateBookStatus(int id, String status) async {
    await (update(books)..where((tbl) => tbl.id.equals(id))).write(
      BooksCompanion(
        readingStatus: Value(status),
        isCompleted: Value(status == 'completed'),
      ),
    );
  }

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

  Future<void> _queueBook(int id) async {
    final book = await (select(books)..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    if (book == null) return;
    await enqueueSyncRecord(
      recordKey: 'book:$id',
      entityType: 'book',
      payload: jsonEncode({
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'totalPages': book.totalPages,
        'lastPage': book.lastPage,
        'isCompleted': book.isCompleted,
        'readingStatus': book.readingStatus,
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
    await enqueueSyncRecord(
      recordKey: 'session:$id',
      entityType: 'reading_session',
      payload: jsonEncode({
        'id': session.id,
        'bookId': session.bookId,
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
  }) async {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    if (entityType == 'book') {
      final id = data['id'] as int;
      final existing = await (select(books)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();
      final companion = BooksCompanion(
        id: Value(id),
        title: Value(data['title'] as String),
        author: Value(data['author'] as String?),
        totalPages: Value(data['totalPages'] as int?),
        lastPage: Value(data['lastPage'] as int? ?? 0),
        isCompleted: Value(data['isCompleted'] as bool? ?? false),
        readingStatus:
            Value(data['readingStatus'] as String? ?? 'want_to_read'),
        createdAt: Value(DateTime.parse(data['createdAt'] as String)),
        filePath:
            existing == null ? const Value.absent() : Value(existing.filePath),
        fileName:
            existing == null ? const Value.absent() : Value(existing.fileName),
        fileSize:
            existing == null ? const Value.absent() : Value(existing.fileSize),
      );
      if (existing == null) {
        await into(books).insert(companion);
      } else {
        await (update(books)..where((table) => table.id.equals(id)))
            .write(companion);
      }
    } else if (entityType == 'reading_session') {
      final id = data['id'] as int;
      await into(readingSessions).insertOnConflictUpdate(
        ReadingSessionsCompanion(
          id: Value(id),
          bookId: Value(data['bookId'] as int),
          date: Value(
            data['date'] as String? ??
                (data['startTime'] == null
                    ? ''
                    : DateTime.parse(data['startTime'] as String)
                        .toIso8601String()
                        .substring(0, 10)),
          ),
          durationSeconds: Value(data['durationSeconds'] as int),
          pagesRead: Value(data['pagesRead'] as int? ?? 0),
          startingPage: Value(data['startingPage'] as int?),
          endingPage: Value(data['endingPage'] as int?),
          readingMode: Value(data['readingMode'] as String? ?? 'digital'),
          note: Value(data['note'] as String?),
          startTime: Value(data['startTime'] == null
              ? null
              : DateTime.parse(data['startTime'] as String)),
          endTime: Value(data['endTime'] == null
              ? null
              : DateTime.parse(data['endTime'] as String)),
        ),
      );
    }
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
