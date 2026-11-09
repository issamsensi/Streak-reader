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
  /// Attaches or replaces the PDF. When [totalPages] is given (counted
  /// from the new file) it becomes the book's total; when null the
  /// existing total is left untouched.
  Future<void> updateBookFile(int id,
      {required String filePath,
      String? fileName,
      int? fileSize,
      int? totalPages});

  /// Sets the total only when the book has none yet, so opening a PDF
  /// backfills legacy books without overwriting a manual page count.
  Future<void> fillTotalPagesIfMissing(int id, int totalPages);
  Future<void> updateLastPage(int id, int lastPage);
  Future<void> markCompleted(int id, bool completed);
  Future<void> updateStatus(int id, String status);
  Future<void> deleteBook(int id);
}
