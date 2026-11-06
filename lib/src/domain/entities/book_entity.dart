class BookEntity {
  final int id;
  final String title;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final int lastPage;
  final bool isCompleted;
  final DateTime createdAt;

  const BookEntity({
    required this.id,
    required this.title,
    this.filePath,
    this.fileName,
    this.fileSize,
    required this.lastPage,
    required this.isCompleted,
    required this.createdAt,
  });
}
