import 'package:drift/drift.dart';

import '../../domain/repositories/books_repository.dart';
import '../datasources/local/app_database.dart';

class BooksRepositoryImpl implements BooksRepository {
  final AppDatabase db;

  BooksRepositoryImpl(this.db);

  @override
  Future<List<Book>> getAllBooks() => db.getAllBooks();

  @override
  Future<int> addBook(
      {required String title,
      String? filePath,
      String? fileName,
      int? fileSize}) {
    return db.insertBook(
      BooksCompanion.insert(
        title: title,
        filePath: Value(filePath),
        fileName: Value(fileName),
        fileSize: Value(fileSize),
      ),
    );
  }

  @override
  Future<void> updateTitle(int id, String title) async {
    await (db.update(db.books)..where((tbl) => tbl.id.equals(id)))
        .write(BooksCompanion(title: Value(title)));
  }

  @override
  Future<void> updateBookFile(int id,
      {required String filePath, String? fileName, int? fileSize}) async {
    await (db.update(db.books)..where((tbl) => tbl.id.equals(id))).write(
      BooksCompanion(
        filePath: Value(filePath),
        fileName: Value(fileName),
        fileSize: Value(fileSize),
      ),
    );
  }

  @override
  Future<void> updateLastPage(int id, int lastPage) async {
    await db.updateBookLastPage(id, lastPage);
  }

  @override
  Future<void> markCompleted(int id, bool completed) async {
    await (db.update(db.books)..where((tbl) => tbl.id.equals(id)))
        .write(BooksCompanion(isCompleted: Value(completed)));
  }

  @override
  Future<void> deleteBook(int id) => db.deleteBook(id);
}
