import '../../data/datasources/local/app_database.dart';

abstract class BooksRepository {
  Future<List<Book>> getAllBooks();
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
      bool historical = false});
  Future<void> updateTitle(int id, String title);
  Future<void> updateBookFile(int id,
      {required String filePath, String? fileName, int? fileSize});
  Future<void> updateLastPage(int id, int lastPage);
  Future<void> markCompleted(int id, bool completed);
  Future<void> updateStatus(int id, String status);
  Future<void> deleteBook(int id);
}
