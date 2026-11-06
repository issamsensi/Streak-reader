import 'package:drift/drift.dart';

import 'connection/connection.dart' as connection;
import 'tables/books_table.dart';
import 'tables/reading_sessions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Books, ReadingSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // Books
  Future<List<Book>> getAllBooks() => select(books).get();
  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);
  Future<bool> updateBook(BooksCompanion book) => update(books).replace(book);
  Future<int> deleteBook(int id) =>
      (delete(books)..where((tbl) => tbl.id.equals(id))).go();
  Future<void> updateBookLastPage(int id, int lastPage) =>
      (update(books)..where((tbl) => tbl.id.equals(id)))
          .write(BooksCompanion(lastPage: Value(lastPage)));

  // Reading sessions
  Future<int> insertSession(ReadingSessionsCompanion session) =>
      into(readingSessions).insert(session);
  Future<List<ReadingSession>> getAllSessions() => select(readingSessions).get();
  Future<List<ReadingSession>> getSessionsForDate(String date) =>
      (select(readingSessions)..where((tbl) => tbl.date.equals(date))).get();
}
