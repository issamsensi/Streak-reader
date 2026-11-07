import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';

class BookDetailsScreen extends ConsumerWidget {
  final int bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<(Book?, List<ReadingSession>, List<BookCompletion>)>(
      future: () async {
        final book = await (db.select(db.books)
              ..where((table) => table.id.equals(bookId)))
            .getSingleOrNull();
        if (book == null) return (null, <ReadingSession>[], <BookCompletion>[]);
        return (
          book,
          await db.getSessionsForBook(bookId),
          await db.getBookCompletions(bookId),
        );
      }(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final book = data?.$1;
        if (book == null) {
          return const Scaffold(body: Center(child: Text('Book not found')));
        }
        final sessions = data!.$2;
        final completions = data.$3;
        final seconds = sessions.fold(0, (sum, item) => sum + item.durationSeconds);
        final pages = sessions.fold(0, (sum, item) => sum + item.pagesRead);
        final digital = sessions
            .where((item) => item.readingMode == 'digital')
            .fold(0, (sum, item) => sum + item.durationSeconds);
        final physical = sessions
            .where((item) => item.readingMode == 'physical')
            .fold(0, (sum, item) => sum + item.durationSeconds);
        return Scaffold(
          appBar: AppBar(title: const Text('Book details')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      if (book.author?.isNotEmpty == true)
                        Text(book.author!,
                            style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Chip(label: Text(_statusLabel(book.readingStatus))),
                      if (book.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Text(book.description!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    children: [
                      _Metric('Reading time', _format(seconds)),
                      _Metric('Sessions', '${sessions.length}'),
                      _Metric('Pages read', '$pages'),
                      _Metric('Digital', _format(digital)),
                      _Metric('Physical', _format(physical)),
                      if (book.totalPages != null)
                        _Metric('Progress',
                            '${book.lastPage}/${book.totalPages}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Completion history',
                  style: Theme.of(context).textTheme.titleLarge),
              if (completions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('No completion records yet.'),
                )
              else
                ...completions.map(
                  (completion) => ListTile(
                    leading: Icon(completion.historical
                        ? Icons.history
                        : Icons.check_circle_outline),
                    title: Text(_date(completion.completedAt)),
                    subtitle: Text(completion.historical
                        ? 'Added as previously completed'
                        : 'Completed through reading'),
                  ),
                ),
              const SizedBox(height: 20),
              Text('Reading history',
                  style: Theme.of(context).textTheme.titleLarge),
              if (sessions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('No tracked reading sessions.'),
                )
              else
                ...sessions.map(
                  (session) => ListTile(
                    leading: Icon(session.readingMode == 'physical'
                        ? Icons.menu_book_outlined
                        : Icons.picture_as_pdf_outlined),
                    title: Text(
                      '${session.readingMode == 'physical' ? 'Physical' : 'Digital'} '
                      'Reading • ${_format(session.durationSeconds)}',
                    ),
                    subtitle: Text(
                      '${session.date} • ${session.pagesRead} pages'
                      '${session.note?.isNotEmpty == true ? ' • ${session.note}' : ''}',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _statusLabel(String status) => switch (status) {
        'currently_reading' => 'Currently Reading',
        'completed' => 'Completed',
        'paused' => 'Paused',
        _ => 'Want to Read',
      };

  static String _format(int seconds) =>
      '${seconds ~/ 60}m ${(seconds % 60).toString().padLeft(2, '0')}s';

  static String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}
