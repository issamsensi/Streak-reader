import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/books_repository_impl.dart';
import '../../../domain/repositories/books_repository.dart';

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BooksRepositoryImpl(db);
});

final booksListProvider = FutureProvider<List<Book>>((ref) async {
  final repo = ref.watch(booksRepositoryProvider);
  // Re-read whenever a reading session persists a new page/totals.
  ref.watch(dataRevisionProvider);
  return repo.getAllBooks();
});
