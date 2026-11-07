import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/datasources/local/app_database.dart';
import '../../domain/entities/export_options.dart';
import '../../domain/usecases/calculate_streak.dart';

class ReadingExportService {
  const ReadingExportService();

  Future<Uint8List> build({
    required AppDatabase database,
    required ReadingExportOptions options,
    required StreakResult statistics,
  }) async {
    final books = await database.getAllBooks();
    final selectedBooks = options.bookId == null
        ? books
        : books.where((book) => book.id == options.bookId).toList();
    final buffer = StringBuffer()
      ..writeln('# Streak Reader export')
      ..writeln()
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln();

    for (final book in selectedBooks) {
      final notes = options.categories.contains(ExportCategory.notes)
          ? await database.getNotes(book.id)
          : const <Note>[];
      final highlights = options.categories.contains(ExportCategory.highlights)
          ? await database.getHighlights(book.id)
          : const <Highlight>[];
      final bookmarks = options.categories.contains(ExportCategory.bookmarks)
          ? await database.getBookmarks(book.id)
          : const <Bookmark>[];
      final journal = options.categories.contains(ExportCategory.journal)
          ? await database.getJournalEntries(bookId: book.id)
          : const <JournalEntry>[];
      if (notes.isEmpty &&
          highlights.isEmpty &&
          bookmarks.isEmpty &&
          journal.isEmpty) {
        continue;
      }
      buffer.writeln('## ${book.title}');
      if (book.author != null && book.author!.isNotEmpty) {
        buffer.writeln('Author: ${book.author}');
      }
      buffer.writeln();
      _writeNotes(buffer, notes);
      _writeHighlights(buffer, highlights);
      _writeBookmarks(buffer, bookmarks);
      _writeJournal(buffer, journal);
    }

    if (options.categories.contains(ExportCategory.statistics)) {
      buffer
        ..writeln('## Reading statistics')
        ..writeln()
        ..writeln('- Total reading time: ${statistics.totalMinutes} minutes')
        ..writeln('- Current streak: ${statistics.currentStreak} days')
        ..writeln('- Longest streak: ${statistics.longestStreak} days')
        ..writeln('- Pages read: ${statistics.totalPagesRead}')
        ..writeln('- Completed books: ${statistics.completedBooks}')
        ..writeln();
    }
    final text = buffer.toString();
    if (options.format == ExportFormat.pdf) {
      return _buildPdf(text);
    }
    return Uint8List.fromList(utf8.encode(text));
  }

  Future<void> share({
    required Uint8List bytes,
    required String fileName,
    required ExportFormat format,
  }) async {
    final extension = format == ExportFormat.pdf
        ? 'pdf'
        : format == ExportFormat.markdown
            ? 'md'
            : 'txt';
    await Share.shareXFiles([
      XFile.fromData(
        bytes,
        name: '$fileName.$extension',
        mimeType: format == ExportFormat.pdf ? 'application/pdf' : 'text/plain',
      ),
    ]);
  }

  Future<Uint8List> _buildPdf(String markdown) async {
    final document = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/ReadexPro-400.ttf');
    final font = pw.Font.ttf(fontData);
    final lines = markdown.split('\n');
    document.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font),
        build: (_) => [
          for (final line in lines)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Text(
                line.startsWith('# ') || line.startsWith('## ')
                    ? line.replaceFirst(RegExp(r'^#+ '), '')
                    : line,
                style: pw.TextStyle(
                  font: font,
                  fontSize: line.startsWith('#') ? 16 : 10,
                  fontWeight: line.startsWith('#')
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
    return document.save();
  }

  static void _writeNotes(StringBuffer out, List<Note> notes) {
    if (notes.isEmpty) return;
    out.writeln('### Notes');
    for (final note in notes) {
      out
        ..writeln('- ${_page(note.pageNumber)}${note.content}')
        ..writeln('  Modified: ${note.modifiedAt.toIso8601String()}');
    }
    out.writeln();
  }

  static void _writeHighlights(StringBuffer out, List<Highlight> highlights) {
    if (highlights.isEmpty) return;
    out.writeln('### Highlights');
    for (final highlight in highlights) {
      out.writeln(
          '- ${_page(highlight.pageNumber)}“${highlight.selectedText}”');
      out.writeln('  Saved: ${highlight.createdAt.toIso8601String()}');
    }
    out.writeln();
  }

  static void _writeBookmarks(StringBuffer out, List<Bookmark> bookmarks) {
    if (bookmarks.isEmpty) return;
    out.writeln('### Bookmarks');
    for (final bookmark in bookmarks) {
      out.writeln(
        '- Page ${bookmark.pageNumber}: '
        '${bookmark.title?.isNotEmpty == true ? bookmark.title : 'Untitled bookmark'}',
      );
    }
    out.writeln();
  }

  static void _writeJournal(StringBuffer out, List<JournalEntry> entries) {
    if (entries.isEmpty) return;
    out.writeln('### Journal');
    for (final entry in entries) {
      out
        ..writeln('#### ${entry.title} ${_page(entry.pageNumber)}')
        ..writeln(entry.reflection)
        ..writeln('  Created: ${entry.createdAt.toIso8601String()}');
    }
    out.writeln();
  }

  static String _page(int? page) => page == null ? '' : 'Page $page: ';
}
