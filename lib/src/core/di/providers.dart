import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart';
import '../utils/pdf_page_count.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Bumped whenever a reading session is persisted.
///
/// The library and statistics providers watch this value so derived data
/// (last page, totals, streak) refreshes even when a session is saved after
/// the reader route has already been popped (for example on idle/dispose).
final dataRevisionProvider = StateProvider<int>((ref) => 0);

/// Reads a PDF's page count; overridable in tests with a fake counter.
final pdfPageCounterProvider =
    Provider<PdfPageCounter>((ref) => countPdfPages);
