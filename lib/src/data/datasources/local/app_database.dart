import 'package:drift/drift.dart';

import 'connection/connection.dart' as connection;
import 'tables/books_table.dart';
import 'tables/annotations_tables.dart';
import 'tables/reading_sessions_table.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

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
        },
      );

  // Books
  Future<List<Book>> getAllBooks() => select(books).get();
  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);
  Future<bool> updateBook(BooksCompanion book) => update(books).replace(book);

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
  Future<int> insertSession(ReadingSessionsCompanion session) =>
      into(readingSessions).insert(session);
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
  ) =>
      (update(readingSessions)..where((tbl) => tbl.id.equals(id)))
          .write(session)
          .then((count) => count > 0);

  Future<int> deleteSession(int id) =>
      (delete(readingSessions)..where((tbl) => tbl.id.equals(id))).go();
  Future<List<ReadingSession>> getSessionsForDate(String date) =>
      (select(readingSessions)..where((tbl) => tbl.date.equals(date))).get();

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

  Future<List<AchievementUnlock>> getAchievementUnlocks() =>
      select(achievementUnlocks).get();

  Future<bool> saveAchievementUnlock(
    AchievementUnlocksCompanion unlock,
  ) async {
    final existing = await (select(achievementUnlocks)
          ..where((tbl) => tbl.achievementId.equals(unlock.achievementId.value)))
        .getSingleOrNull();
    if (existing != null) return false;
    final inserted = await into(achievementUnlocks).insert(
      unlock,
    );
    return inserted > 0;
  }
}
