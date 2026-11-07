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
      String? author,
      int? totalPages,
      String? filePath,
      String? fileName,
      int? fileSize,
      String? coverPath,
      String? description,
      String status = 'want_to_read',
      DateTime? completionDate,
      bool historical = false}) async {
    final id = await db.insertBook(
      BooksCompanion.insert(
        title: title,
        author: Value(author),
        totalPages: Value(totalPages),
        filePath: Value(filePath),
        fileName: Value(fileName),
        fileSize: Value(fileSize),
        coverPath: Value(coverPath),
        description: Value(description),
        readingStatus: Value(status),
        isCompleted: Value(status == 'completed'),
        completionDate: Value(completionDate),
        addedAsPreviouslyCompleted: Value(historical),
      ),
    );
    if (status == 'completed') {
      await db.addBookCompletion(
        bookId: id,
        completedAt: completionDate ?? DateTime.now(),
        historical: historical,
      );
    }
    return id;
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
    await db.updateBookStatus(
      id,
      completed ? 'completed' : 'want_to_read',
    );
  }

  @override
  Future<void> updateStatus(int id, String status) =>
      db.updateBookStatus(id, status);

  @override
  Future<void> deleteBook(int id) => db.deleteBook(id);
}
