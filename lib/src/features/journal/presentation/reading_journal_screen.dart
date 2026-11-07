import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/providers.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/local/app_database.dart';

class ReadingJournalScreen extends ConsumerStatefulWidget {
  const ReadingJournalScreen({super.key});

  @override
  ConsumerState<ReadingJournalScreen> createState() =>
      _ReadingJournalScreenState();
}

class _ReadingJournalScreenState extends ConsumerState<ReadingJournalScreen> {
  final _searchController = TextEditingController();
  List<Book> _books = const [];
  List<JournalEntry> _entries = const [];
  int? _bookFilter;
  bool _isLoading = true;

  AppDatabase get _database => ref.read(databaseProvider);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_loadEntries);
    _load();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_loadEntries)
      ..dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final books = await _database.getAllBooks();
    final entries = await _database.getJournalEntries(
      bookId: _bookFilter,
      query: _searchController.text,
    );
    if (!mounted) return;
    setState(() {
      _books = books;
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _loadEntries() async {
    final entries = await _database.getJournalEntries(
      bookId: _bookFilter,
      query: _searchController.text,
    );
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _openEditor([JournalEntry? entry]) async {
    final l10n = context.l10n;
    final result = await showModalBottomSheet<_JournalDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _JournalEditor(
        entry: entry,
        books: _books,
        currentBookId: entry?.bookId,
      ),
    );
    if (result == null || result.reflection.trim().isEmpty) return;

    final now = DateTime.now();
    if (entry == null) {
      await _database.addJournalEntry(
        JournalEntriesCompanion.insert(
          title: result.title.trim().isEmpty
              ? l10n.untitledJournalEntry
              : result.title.trim(),
          reflection: result.reflection,
          bookId: drift.Value(result.bookId),
          pageNumber: drift.Value(result.pageNumber),
          createdAt: drift.Value(now),
          modifiedAt: drift.Value(now),
        ),
      );
    } else {
      await _database.updateJournalEntry(
        entry.id,
        JournalEntriesCompanion(
          title: drift.Value(result.title.trim()),
          reflection: drift.Value(result.reflection),
          bookId: drift.Value(result.bookId),
          pageNumber: drift.Value(result.pageNumber),
          modifiedAt: drift.Value(now),
        ),
      );
    }
    await _load();
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteJournalEntry),
        content: Text(context.l10n.deleteJournalEntryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _database.deleteJournalEntry(entry.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readingJournal),
        actions: [
          IconButton(
            tooltip: l10n.newJournalEntry,
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text(l10n.writeReflection),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchJournal,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: Text(l10n.allBooks),
                  selected: _bookFilter == null,
                  onSelected: (_) {
                    setState(() => _bookFilter = null);
                    _loadEntries();
                  },
                ),
                const SizedBox(width: 8),
                ..._books.map(
                  (book) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: _bookFilter == book.id,
                      onSelected: (_) {
                        setState(() => _bookFilter = book.id);
                        _loadEntries();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _EmptyJournal(onCreate: () => _openEditor())
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            final book = _bookFor(entry.bookId);
                            return _JournalEntryCard(
                              entry: entry,
                              bookTitle: book?.title,
                              onTap: () => _openEditor(entry),
                              onDelete: () => _deleteEntry(entry),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Book? _bookFor(int? id) {
    if (id == null) return null;
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final String? bookTitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JournalEntryCard({
    required this.entry,
    required this.bookTitle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 10, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.title.isEmpty
                          ? context.l10n.untitledJournalEntry
                          : entry.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.delete,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              Text(
                entry.reflection,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  Text(
                    DateFormat.yMMMd().format(entry.createdAt),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (bookTitle != null)
                    Text(
                      bookTitle!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (entry.pageNumber != null)
                    Text(
                      context.l10n.pageNumberLabel(entry.pageNumber!),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

class _EmptyJournal extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyJournal({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.emptyJournal,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(context.l10n.writeReflection),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalDraft {
  final String title;
  final String reflection;
  final int? bookId;
  final int? pageNumber;

  const _JournalDraft({
    required this.title,
    required this.reflection,
    required this.bookId,
    required this.pageNumber,
  });
}

class _JournalEditor extends StatefulWidget {
  final JournalEntry? entry;
  final List<Book> books;
  final int? currentBookId;

  const _JournalEditor({
    required this.entry,
    required this.books,
    required this.currentBookId,
  });

  @override
  State<_JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<_JournalEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _reflectionController;
  late final TextEditingController _pageController;
  late int? _bookId = widget.currentBookId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _reflectionController =
        TextEditingController(text: widget.entry?.reflection ?? '');
    _pageController = TextEditingController(
      text: widget.entry?.pageNumber?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reflectionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _insertPrompt(String prompt) {
    final current = _reflectionController.text;
    _reflectionController.value = TextEditingValue(
      text: current.isEmpty ? '$prompt\n\n' : '$current\n\n$prompt\n',
      selection: TextSelection.collapsed(
        offset:
            (current.isEmpty ? '$prompt\n\n' : '$current\n\n$prompt\n').length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prompts = [
      l10n.promptLearned,
      l10n.promptIdea,
      l10n.promptPassage,
      l10n.promptFeeling,
    ];
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.entry == null
                  ? l10n.newJournalEntry
                  : l10n.editJournalEntry,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: AppTheme.displayFont,
                  ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.journalTitle,
                hintText: l10n.journalTitleHint,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int?>(
              initialValue: _bookId,
              decoration: InputDecoration(labelText: l10n.associatedBook),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.noAssociatedBook),
                ),
                ...widget.books.map(
                  (book) => DropdownMenuItem<int?>(
                    value: book.id,
                    child: Text(book.title),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _bookId = value),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.pageReferenceOptional,
                hintText: l10n.pageReferenceHint,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _reflectionController,
              minLines: 8,
              maxLines: 16,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.reflection,
                hintText: l10n.reflectionHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.journalPrompts,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prompts
                  .map(
                    (prompt) => ActionChip(
                      label: Text(prompt),
                      onPressed: () => _insertPrompt(prompt),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                final page = int.tryParse(_pageController.text.trim());
                Navigator.of(context).pop(
                  _JournalDraft(
                    title: _titleController.text,
                    reflection: _reflectionController.text,
                    bookId: _bookId,
                    pageNumber: page != null && page > 0 ? page : null,
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
