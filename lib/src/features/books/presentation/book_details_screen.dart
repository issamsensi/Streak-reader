import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/widgets/book_cover_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../domain/entities/reading_status.dart';
import '../providers/books_providers.dart';
import 'widgets/add_book_sheet.dart';

typedef _DetailsData = (
  Book?,
  List<ReadingSession>,
  List<BookCompletion>,
  List<Note>,
  List<Highlight>,
  List<Bookmark>,
  List<JournalEntry>,
);

class BookDetailsScreen extends ConsumerStatefulWidget {
  final int bookId;

  /// When true, scrolls to the Reading History section once loaded.
  final bool focusHistory;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.focusHistory = false,
  });

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  final _historyKey = GlobalKey();
  late Future<_DetailsData> _future;
  bool _scrolledToHistory = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DetailsData> _load() async {
    final db = ref.read(databaseProvider);
    final book = await (db.select(db.books)
          ..where((table) => table.id.equals(widget.bookId)))
        .getSingleOrNull();
    if (book == null) {
      return (
        null,
        <ReadingSession>[],
        <BookCompletion>[],
        <Note>[],
        <Highlight>[],
        <Bookmark>[],
        <JournalEntry>[]
      );
    }
    return (
      book,
      await db.getSessionsForBook(widget.bookId),
      await db.getBookCompletions(widget.bookId),
      await db.getNotes(widget.bookId),
      await db.getHighlights(widget.bookId),
      await db.getBookmarks(widget.bookId),
      await db.getJournalEntries(bookId: widget.bookId),
    );
  }

  Future<void> _edit(Book book) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AddBookSheet(book: book),
    );
    if (!mounted) return;
    ref.invalidate(booksListProvider);
    setState(() => _future = _load());
  }

  void _maybeScrollToHistory() {
    if (!widget.focusHistory || _scrolledToHistory) return;
    _scrolledToHistory = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _historyKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 300));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DetailsData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data;
        final book = data?.$1;
        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book details')),
            body: const Center(child: Text('Book not found')),
          );
        }
        _maybeScrollToHistory();
        final sessions = data!.$2;
        final completions = data.$3;
        final notes = data.$4;
        final highlights = data.$5;
        final bookmarks = data.$6;
        final journal = data.$7;
        final seconds =
            sessions.fold(0, (sum, item) => sum + item.durationSeconds);
        final pages = sessions.fold(0, (sum, item) => sum + item.pagesRead);
        final digital = sessions
            .where((item) => item.readingMode == 'digital')
            .fold(0, (sum, item) => sum + item.durationSeconds);
        final physical = sessions
            .where((item) => item.readingMode == 'physical')
            .fold(0, (sum, item) => sum + item.durationSeconds);
        final progress = book.totalPages != null && book.totalPages! > 0
            ? (book.lastPage / book.totalPages!).clamp(0.0, 1.0)
            : null;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Book details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Details',
                onPressed: () => _edit(book),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Cover(book: book),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(book.title,
                                    style: theme.textTheme.headlineSmall),
                                if (book.author?.isNotEmpty == true)
                                  Text(book.author!,
                                      style: theme.textTheme.bodyLarge),
                                const SizedBox(height: 8),
                                Chip(
                                    label:
                                        Text(_statusLabel(book.readingStatus))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (book.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Text(book.description!),
                      ],
                      const SizedBox(height: 16),
                      _InfoRow(
                          'Total pages', book.totalPages?.toString() ?? '—'),
                      _InfoRow('Date added', _date(book.createdAt)),
                      _InfoRow(
                        'Completion date',
                        book.completionDate != null
                            ? _date(book.completionDate!)
                            : (completions.isNotEmpty
                                ? _date(completions.first.completedAt)
                                : '—'),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _edit(book),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Details'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reading progress',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      if (progress != null) ...[
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 8),
                        Text(
                            '${(progress * 100).round()}% • Page ${book.lastPage} of ${book.totalPages}'),
                        const SizedBox(height: 12),
                      ] else if (book.lastPage > 0) ...[
                        Text('Current page: ${book.lastPage}'),
                        const SizedBox(height: 12),
                      ],
                      Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        children: [
                          _Metric('Reading time', _format(seconds)),
                          _Metric('Sessions', '${sessions.length}'),
                          _Metric('Pages read', '$pages'),
                          _Metric('Digital', _format(digital)),
                          _Metric('Physical', _format(physical)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Personal content', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _SectionEmpty(
                isEmpty: notes.isEmpty,
                emptyText: 'No personal notes yet.',
                children: notes
                    .map((n) => ListTile(
                          leading: const Icon(Icons.note_outlined),
                          title: Text(n.content,
                              maxLines: 3, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                              '${n.pageNumber != null ? 'Page ${n.pageNumber} • ' : ''}${_date(n.modifiedAt)}'),
                        ))
                    .toList(),
              ),
              const _SectionLabel('Highlights & quotes'),
              _SectionEmpty(
                isEmpty: highlights.isEmpty,
                emptyText: 'No highlights yet.',
                children: highlights
                    .map((h) => ListTile(
                          leading: const Icon(Icons.format_quote_outlined),
                          title: Text(h.selectedText,
                              maxLines: 3, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Page ${h.pageNumber}'),
                        ))
                    .toList(),
              ),
              const _SectionLabel('Bookmarks'),
              _SectionEmpty(
                isEmpty: bookmarks.isEmpty,
                emptyText: 'No bookmarks yet.',
                children: bookmarks
                    .map((b) => ListTile(
                          leading: const Icon(Icons.bookmark_outline),
                          title: Text(b.title ?? 'Page ${b.pageNumber}'),
                          subtitle: Text('Page ${b.pageNumber}'),
                        ))
                    .toList(),
              ),
              const _SectionLabel('Reading journal'),
              _SectionEmpty(
                isEmpty: journal.isEmpty,
                emptyText: 'No journal entries for this book yet.',
                children: journal
                    .map((j) => ListTile(
                          leading: const Icon(Icons.auto_stories_outlined),
                          title: Text(j.title),
                          subtitle: Text(j.reflection,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Container(
                key: _historyKey,
                child:
                    Text('Reading history', style: theme.textTheme.titleLarge),
              ),
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
              const SizedBox(height: 20),
              Text('Completion history', style: theme.textTheme.titleLarge),
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
            ],
          ),
        );
      },
    );
  }

  static String _statusLabel(String status) =>
      _labelFor(ReadingStatus.fromValue(status));

  static String _labelFor(ReadingStatus status) => switch (status) {
        ReadingStatus.currentlyReading => 'Currently Reading',
        ReadingStatus.wantToRead => 'Want to Read',
        ReadingStatus.completed => 'Completed',
        ReadingStatus.paused => 'Paused',
        ReadingStatus.abandoned => 'Abandoned',
      };

  static String _format(int seconds) =>
      '${seconds ~/ 60}m ${(seconds % 60).toString().padLeft(2, '0')}s';

  static String _date(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _SectionEmpty extends StatelessWidget {
  final bool isEmpty;
  final String emptyText;
  final List<Widget> children;

  const _SectionEmpty({
    required this.isEmpty,
    required this.emptyText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => isEmpty
      ? Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(emptyText),
        )
      : Column(children: children);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child:
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

class _Cover extends StatelessWidget {
  final Book book;
  const _Cover({required this.book});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.coverGradientFor(book.title);
    final trimmed = book.title.trim();
    final initial =
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
    final fallback = Container(
      width: 72,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(initial,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white)),
      ),
    );
    if (book.coverPath == null || book.coverPath!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: bookCoverImage(
        path: book.coverPath!,
        width: 72,
        height: 100,
        fallback: fallback,
      ),
    );
  }
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
