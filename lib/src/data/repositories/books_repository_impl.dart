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
    final book = await (db.select(db.books)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (book == null) return;
    await db.updateBook(book.copyWith(title: title).toCompanion(true));
  }

  @override
  Future<void> updateBookFile(int id,
      {required String filePath, String? fileName, int? fileSize}) async {
    final book = await (db.select(db.books)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (book == null) return;
    await db.updateBook(
      book
          .copyWith(
              filePath: Value(filePath),
              fileName: Value(fileName),
              fileSize: Value(fileSize))
          .toCompanion(true),
    );
  }

  @override
  Future<void> updateLastPage(int id, int lastPage) async {
    final book = await (db.select(db.books)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (book == null) return;
    await db.updateBook(book.copyWith(lastPage: lastPage).toCompanion(true));
  }

  @override
  Future<void> markCompleted(int id, bool completed) async {
    final book = await (db.select(db.books)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (book == null) return;
    await db
        .updateBook(book.copyWith(isCompleted: completed).toCompanion(true));
  }

  @override
  Future<void> deleteBook(int id) => db.deleteBook(id);
}
