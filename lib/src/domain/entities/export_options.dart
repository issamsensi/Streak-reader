enum ExportFormat { markdown, plainText, pdf }

enum ExportCategory { notes, highlights, bookmarks, journal, statistics }

class ReadingExportOptions {
  final ExportFormat format;
  final Set<ExportCategory> categories;
  final int? bookId;

  const ReadingExportOptions({
    required this.format,
    required this.categories,
    this.bookId,
  });
}
