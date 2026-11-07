import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_exists.dart';
import '../../../core/widgets/book_cover_image.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/streak_banner.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../domain/entities/reading_status.dart';
import '../../calendar/presentation/reading_calendar_screen.dart';
import '../../daily_goal/presentation/daily_goal_card.dart';
import '../../reader/presentation/pdf_reader_screen.dart';
import '../../reader/presentation/physical_reader_screen.dart';
import 'book_details_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../settings/providers/settings_provider.dart';
import '../../stats/presentation/stats_screen.dart';
import '../../stats/providers/stats_provider.dart';
import '../../journal/presentation/reading_journal_screen.dart';
import '../../export/presentation/reading_export_screen.dart';
import '../providers/books_providers.dart';
import 'widgets/add_book_sheet.dart';

String _statusLabel(AppLocalizations l10n, ReadingStatus status) {
  switch (status) {
    case ReadingStatus.currentlyReading:
      return l10n.currentlyReading;
    case ReadingStatus.wantToRead:
      return l10n.wantToRead;
    case ReadingStatus.completed:
      return l10n.completed;
    case ReadingStatus.paused:
      return l10n.paused;
    case ReadingStatus.abandoned:
      return l10n.abandoned;
  }
}

class BooksListScreen extends ConsumerStatefulWidget {
  const BooksListScreen({super.key, this.initialBookId});

  final int? initialBookId;

  @override
  ConsumerState<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends ConsumerState<BooksListScreen> {
  final _searchController = TextEditingController();
  ReadingStatus? _statusFilter;
  String _sort = 'recent';
  List<Collection> _collections = const [];
  final Set<String> _collapsedSections = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadCollections();
    if (widget.initialBookId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openInitialBook());
    }
  }

  Future<void> _openInitialBook() async {
    final bookId = widget.initialBookId;
    if (!mounted || bookId == null) return;
    final books = await ref.read(booksListProvider.future);
    if (!mounted) return;
    final book = books.where((item) => item.id == bookId).firstOrNull;
    if (book != null) _openBook(context, ref, book);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    final collections = await ref.read(databaseProvider).getCollections();
    if (mounted) setState(() => _collections = collections);
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchController.text);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.searchBooks),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: context.l10n.searchBooks),
          onSubmitted: (_) => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
            },
            child: Text(context.l10n.clear),
          ),
          FilledButton(
            onPressed: () {
              _searchController.text = controller.text;
              Navigator.pop(context);
            },
            child: Text(context.l10n.search),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const AddBookSheet(),
    );
  }

  Future<void> _attachPdf(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final l10n = context.l10n;
    PlatformFile file;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null) return;
      file = result.files.single;
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorMessage(error.toString()))),
      );
      return;
    }

    if (file.path == null) {
      // Web pickers return bytes instead of a local path.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.attachPdfWebUnsupported)),
        );
      }
      return;
    }

    try {
      await ref.read(booksRepositoryProvider).updateBookFile(
            book.id,
            filePath: file.path!,
            fileName: file.name,
            fileSize: file.size,
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
      return;
    }

    if (context.mounted) ref.invalidate(booksListProvider);
  }

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    Book book,
    String status,
  ) async {
    try {
      await ref.read(booksRepositoryProvider).updateStatus(book.id, status);
      if (status == ReadingStatus.completed.value) {
        await ref
            .read(settingsProvider.notifier)
            .recordBookCompletion(book.id, DateTime.now());
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saveFailed)),
      );
      return;
    }
    if (context.mounted) ref.invalidate(booksListProvider);
  }

  Future<void> _deleteBook(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(l10n.deleteBookTitle),
          content: Text(l10n.deleteBookBody(book.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(booksRepositoryProvider).deleteBook(book.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteFailed)),
      );
      return;
    }

    if (!context.mounted) return;
    ref.invalidate(booksListProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.bookDeleted)),
    );
  }

  void _showEditDialog(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AddBookSheet(book: book),
    ).then((_) => ref.invalidate(booksListProvider));
  }

  void _openDetails(BuildContext context, Book book,
      {bool focusHistory = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BookDetailsScreen(bookId: book.id, focusHistory: focusHistory),
      ),
    );
  }

  void _openBook(BuildContext context, WidgetRef ref, Book book) {
    final l10n = context.l10n;
    final hasFile = book.filePath != null && book.filePath!.isNotEmpty;
    final exists = hasFile ? fileExists(book.filePath!) : false;

    if (hasFile && !exists) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.fileNotFoundTitle),
          content: Text(l10n.fileNotFoundBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.ok),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _attachPdf(context, ref, book);
              },
              child: Text(l10n.changePdf),
            ),
          ],
        ),
      );
      return;
    }

    if (!hasFile) {
      // Books without a PDF (physical / manually added) open their details.
      _openDetails(context, book);
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PdfReaderScreen(
              bookId: book.id,
              bookTitle: book.title,
              filePath: book.filePath!,
              initialPage: book.lastPage,
            ),
          ),
        )
        // Refresh lastPage/session stats on return; the reader itself must
        // not invalidate after dispose.
        .then((_) => ref.invalidate(booksListProvider));
  }

  Future<void> _createCollection() async {
    final draft = await _askCollectionName();
    if (draft == null || draft.$1.trim().isEmpty) return;
    await ref.read(databaseProvider).addCollection(
          CollectionsCompanion.insert(
            name: draft.$1.trim(),
            description: drift.Value(draft.$2.trim()),
          ),
        );
    await _loadCollections();
  }

  Future<void> _editBookCollections(Book book) async {
    if (_collections.isEmpty) {
      await _createCollection();
      if (_collections.isEmpty || !mounted) return;
      // Fall through so the new collection can be assigned to this book.
    }
    final selected = (await ref.read(databaseProvider).getBookCollectionIds(
              book.id,
            ))
        .toSet();
    if (!mounted) return;
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.collections),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _collections
                  .map(
                    (collection) => CheckboxListTile(
                      value: selected.contains(collection.id),
                      title: Text(collection.name),
                      subtitle: Text(
                        collection.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onChanged: (value) => setDialogState(
                        () => value == true
                            ? selected.add(collection.id)
                            : selected.remove(collection.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selected),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      await ref.read(databaseProvider).setBookCollections(book.id, result);
    }
  }

  Future<(String, String)?> _askCollectionName() async {
    final controller = TextEditingController();
    final descriptionController = TextEditingController();
    final value = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.newCollection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration:
                  InputDecoration(hintText: context.l10n.collectionName),
            ),
            TextField(
              controller: descriptionController,
              decoration:
                  InputDecoration(hintText: context.l10n.collectionDescription),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              (controller.text, descriptionController.text),
            ),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    descriptionController.dispose();
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final booksAsync = ref.watch(booksListProvider);
    final stats = ref.watch(statsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.booksLibrary),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: l10n.statistics,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            tooltip: 'More',
            onSelected: (value) {
              if (value == 'export') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReadingExportScreen(),
                  ),
                );
              } else if (value == 'collection') {
                _createCollection();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReadingJournalScreen(),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.ios_share_rounded),
                  title: Text('Export'),
                ),
              ),
              PopupMenuItem(
                value: 'collection',
                child: ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined),
                  title: Text(l10n.newCollection),
                ),
              ),
              PopupMenuItem(
                value: 'journal',
                child: ListTile(
                  leading: const Icon(Icons.auto_stories_rounded),
                  title: Text(l10n.readingJournal),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: const ValueKey('open-reading-calendar'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ReadingCalendarScreen()),
              );
            },
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: l10n.readingCalendar,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: IconButton.filledTonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
              tooltip: l10n.settings,
            ),
          ),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          final query = _searchController.text.trim().toLowerCase();
          final filtered = books.where((book) {
            final matchesQuery = query.isEmpty ||
                book.title.toLowerCase().contains(query) ||
                (book.author?.toLowerCase().contains(query) ?? false);
            final matchesStatus = _statusFilter == null ||
                book.readingStatus == _statusFilter!.value;
            return matchesQuery && matchesStatus;
          }).toList();
          // Recently active = last session date (from stats), then newest.
          final lastActive = <int, String>{
            for (final p in stats?.readingStatistics.bookProgress ?? const [])
              if (p.lastReadingDate != null) p.book.id: p.lastReadingDate!,
          };
          filtered.sort((a, b) {
            if (_sort == 'title') {
              return a.title.toLowerCase().compareTo(b.title.toLowerCase());
            }
            if (_sort == 'dateAdded') return b.createdAt.compareTo(a.createdAt);
            if (_sort == 'progress') return b.lastPage.compareTo(a.lastPage);
            final byActivity =
                (lastActive[b.id] ?? '').compareTo(lastActive[a.id] ?? '');
            return byActivity != 0
                ? byActivity
                : b.createdAt.compareTo(a.createdAt);
          });
          if (books.isEmpty) {
            return _EmptyLibrary(
              onAdd: () => _showAddSheet(context),
            );
          }
          // Group by status in the required order; abandoned (if any) last
          // so no book ever disappears from the library.
          const sectionOrder = [
            ReadingStatus.currentlyReading,
            ReadingStatus.wantToRead,
            ReadingStatus.paused,
            ReadingStatus.completed,
            ReadingStatus.abandoned,
          ];
          final visibleStatuses =
              _statusFilter == null ? sectionOrder : [_statusFilter!];
          Widget cardFor(Book book) => _BookCard(
                book: book,
                onTap: () => _openBook(context, ref, book),
                onPhysicalReading: () => Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => PhysicalReaderScreen(
                          bookId: book.id,
                          bookTitle: book.title,
                        ),
                      ),
                    )
                    .then((_) => ref.invalidate(booksListProvider)),
                onDetails: () => _openDetails(context, book),
                onHistory: () =>
                    _openDetails(context, book, focusHistory: true),
                onEdit: () => _showEditDialog(context, book),
                onAttachPdf: () => _attachPdf(context, ref, book),
                onSetStatus: (status) => _setStatus(context, ref, book, status),
                onManageCollections: () => _editBookCollections(book),
                onDelete: () => _deleteBook(context, ref, book),
              );
          // Eager Column (not a lazy ListView) so every section and card is
          // present in the tree; personal libraries are small.
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (stats != null) ...[
                        StreakBanner(stats: stats, compact: true),
                        const SizedBox(height: 12),
                        const DailyGoalCard(),
                        const SizedBox(height: 26),
                      ],
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.search),
                        title: Text(
                          _searchController.text.isEmpty
                              ? l10n.searchBooks
                              : _searchController.text,
                        ),
                        trailing: IconButton(
                          onPressed: _showSearchDialog,
                          icon: const Icon(Icons.tune),
                        ),
                        onTap: _showSearchDialog,
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(l10n.allBooks),
                              selected: _statusFilter == null,
                              onSelected: (_) => setState(
                                () => _statusFilter = null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            for (final status in ReadingStatus.values) ...[
                              ChoiceChip(
                                label: Text(
                                  '• ${_statusLabel(l10n, status)}',
                                ),
                                selected: _statusFilter == status,
                                onSelected: (_) => setState(
                                  () => _statusFilter = status,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.yourBooks,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.sort_rounded),
                            onSelected: (value) =>
                                setState(() => _sort = value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'recent',
                                child: Text('Recently active'),
                              ),
                              PopupMenuItem(
                                value: 'title',
                                child: Text(l10n.sortTitle),
                              ),
                              const PopupMenuItem(
                                value: 'dateAdded',
                                child: Text('Date added'),
                              ),
                              PopupMenuItem(
                                value: 'progress',
                                child: Text(l10n.sortProgress),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${filtered.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  _SectionEmptyState(
                    message: 'No books match your search.',
                    actionLabel: l10n.addBook,
                    onAction: () => _showAddSheet(context),
                  )
                else
                  for (final status in visibleStatuses) ...[
                    _LibrarySection(
                      title: _statusLabel(l10n, status),
                      count: filtered
                          .where((b) => b.readingStatus == status.value)
                          .length,
                      expanded: !_collapsedSections.contains(status.value),
                      onToggle: () => setState(() {
                        _collapsedSections.contains(status.value)
                            ? _collapsedSections.remove(status.value)
                            : _collapsedSections.add(status.value);
                      }),
                      emptyMessage: switch (status) {
                        ReadingStatus.currentlyReading =>
                          'No books currently being read.',
                        ReadingStatus.wantToRead =>
                          'Your reading list is empty.',
                        ReadingStatus.completed => 'No completed books yet.',
                        ReadingStatus.paused => 'No paused books.',
                        ReadingStatus.abandoned => 'No abandoned books.',
                      },
                      children: [
                        for (final book in filtered
                            .where((b) => b.readingStatus == status.value)) ...[
                          cardFor(book),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(
          message: l10n.errorMessage(err.toString()),
          onRetry: () => ref.invalidate(booksListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addBook),
      ),
    );
  }
}

class _SectionEmptyState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionEmptyState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionLabel),
            ),
          ],
        ),
      );
}

class _LibrarySection extends StatelessWidget {
  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;
  final String emptyMessage;
  final List<Widget> children;

  const _LibrarySection({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.emptyMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Icon(expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded),
              ],
            ),
          ),
        ),
        if (expanded)
          if (count == 0)
            // Text-only empty state; the Add Book FAB is always visible, so
            // repeating an Add button in every section would just clutter.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Text(
                emptyMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...children,
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onPhysicalReading;
  final VoidCallback onDetails;
  final VoidCallback onHistory;
  final VoidCallback onEdit;
  final VoidCallback onAttachPdf;
  final ValueChanged<String> onSetStatus;
  final VoidCallback onManageCollections;
  final VoidCallback onDelete;

  const _BookCard({
    required this.book,
    required this.onTap,
    required this.onPhysicalReading,
    required this.onDetails,
    required this.onHistory,
    required this.onEdit,
    required this.onAttachPdf,
    required this.onSetStatus,
    required this.onManageCollections,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = context.palette;
    final hasFile = book.filePath != null && book.filePath!.isNotEmpty;

    final readingStatus = ReadingStatus.fromValue(book.readingStatus);
    final statusColor = readingStatus == ReadingStatus.completed
        ? palette.success
        : theme.colorScheme.primary;
    final statusIcon = switch (readingStatus) {
      ReadingStatus.currentlyReading => Icons.menu_book_rounded,
      ReadingStatus.wantToRead => Icons.bookmark_border_rounded,
      ReadingStatus.completed => Icons.check_circle_outline_rounded,
      ReadingStatus.paused => Icons.pause_circle_outline_rounded,
      ReadingStatus.abandoned => Icons.remove_circle_outline_rounded,
    };
    final statusText = switch (readingStatus) {
      ReadingStatus.currentlyReading => l10n.currentlyReading,
      ReadingStatus.wantToRead => l10n.wantToRead,
      ReadingStatus.completed => l10n.completed,
      ReadingStatus.paused => l10n.paused,
      ReadingStatus.abandoned => l10n.abandoned,
    };

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookCover(
                  title: book.title,
                  hasFile: hasFile,
                  coverPath: book.coverPath),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (book.author != null && book.author!.isNotEmpty)
                      Text(
                        book.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            statusText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (book.lastPage > 0 || book.totalPages != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (book.lastPage > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                book.totalPages == null
                                    ? l10n.pageNumberLabel(book.lastPage)
                                    : '${book.lastPage} / ${book.totalPages} '
                                        '${l10n.pagesRead.toLowerCase()}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          if (book.totalPages != null && book.totalPages! > 0)
                            Text(
                              '${((book.lastPage / book.totalPages!).clamp(0, 1) * 100).round()}%',
                              style: theme.textTheme.labelSmall,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'details') {
                    onDetails();
                  } else if (value == 'history') {
                    onHistory();
                  } else if (value == 'physical_reading') {
                    onPhysicalReading();
                  } else if (value == 'attach_pdf') {
                    onAttachPdf();
                  } else if (value.startsWith('status:')) {
                    onSetStatus(value.substring(7));
                  } else if (value == 'collections') {
                    onManageCollections();
                  } else if (value == 'toggle_completed') {
                    onSetStatus(
                      book.isCompleted
                          ? ReadingStatus.wantToRead.value
                          : ReadingStatus.completed.value,
                    );
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18),
                        SizedBox(width: 10),
                        Flexible(child: Text('Book Details')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded, size: 18),
                        SizedBox(width: 10),
                        Flexible(child: Text('Reading History')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'physical_reading',
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        const Flexible(child: Text('Physical Reading')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        const Flexible(
                          child: Text(
                            'Edit Details',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'attach_pdf',
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            hasFile ? 'Replace PDF' : l10n.addPdf,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final status in ReadingStatus.values)
                    PopupMenuItem(
                      value: 'status:${status.value}',
                      child: Text(
                        status == readingStatus
                            ? '✓ ${_statusLabel(l10n, status)}'
                            : _statusLabel(l10n, status),
                      ),
                    ),
                  PopupMenuItem(
                    value: 'toggle_completed',
                    child: Text(
                      book.isCompleted
                          ? l10n.markAsUnread
                          : l10n.markAsCompleted,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'collections',
                    child: Text(l10n.collections),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            l10n.deleteBook,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final String title;
  final bool hasFile;
  final String? coverPath;

  const _BookCover(
      {required this.title, required this.hasFile, this.coverPath});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.coverGradientFor(title);
    final trimmed = title.trim();
    final initial =
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

    if (coverPath != null && coverPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: bookCoverImage(
          path: coverPath!,
          width: 56,
          height: 76,
          fallback: _gradient(context, colors, initial),
        ),
      );
    }
    return _gradient(context, colors, initial);
  }

  Widget _gradient(BuildContext context, List<Color> colors, String initial) {
    return Container(
      width: 56,
      height: 76,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 7,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1.5,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Center(
            child: Text(
              initial,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontFamily: AppTheme.displayFont,
                    height: 1,
                  ),
            ),
          ),
          if (hasFile)
            PositionedDirectional(
              end: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyLibrary({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const verticalPadding = 24.0 + 120.0;
        final minHeight = constraints.maxHeight > verticalPadding
            ? constraints.maxHeight - verticalPadding
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _EmptyIllustration(),
                  const SizedBox(height: 30),
                  Text(
                    l10n.noBooksYet,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addBook),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: 160,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.18,
            child: Container(
              width: 94,
              height: 124,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.18,
            child: Container(
              width: 94,
              height: 124,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Container(
            width: 104,
            height: 136,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.palette.border),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.auto_stories_rounded,
                size: 46,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
