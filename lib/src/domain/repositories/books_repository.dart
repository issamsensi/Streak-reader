import '../../data/datasources/local/app_database.dart';

abstract class BooksRepository {
  Future<List<Book>> getAllBooks();
  Future<int> addBook(
      {required String title,
      String? filePath,
      String? fileName,
      int? fileSize});
  Future<void> updateTitle(int id, String title);
  Future<void> updateBookFile(int id,
      {required String filePath, String? fileName, int? fileSize});
  Future<void> updateLastPage(int id, int lastPage);
  Future<void> markCompleted(int id, bool completed);
  Future<void> deleteBook(int id);
}
