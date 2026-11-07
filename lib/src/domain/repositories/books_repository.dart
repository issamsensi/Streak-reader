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

  /// Partial edit of book metadata. Only the books row is touched, so
  /// sessions, notes, bookmarks, highlights, journal entries and
  /// completion records (all keyed by book id) are preserved.
  Future<void> updateBookDetails(
    int id, {
    required String title,
    String? author,
    int? totalPages,
    String? coverPath,
    String? description,
    required String status,
    DateTime? completionDate,
  });
  Future<void> updateBookFile(int id,
      {required String filePath, String? fileName, int? fileSize});
  Future<void> updateLastPage(int id, int lastPage);
  Future<void> markCompleted(int id, bool completed);
  Future<void> updateStatus(int id, String status);
  Future<void> deleteBook(int id);
}
