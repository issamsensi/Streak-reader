import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/export/reading_export_service.dart';
import '../../../domain/entities/export_options.dart';
import '../../books/providers/books_providers.dart';
import '../../stats/providers/stats_provider.dart';

class ReadingExportScreen extends ConsumerStatefulWidget {
  const ReadingExportScreen({super.key});

  @override
  ConsumerState<ReadingExportScreen> createState() =>
      _ReadingExportScreenState();
}

class _ReadingExportScreenState extends ConsumerState<ReadingExportScreen> {
  final _categories = ExportCategory.values.toSet();
  ExportFormat _format = ExportFormat.markdown;
  int? _bookId;
  bool _busy = false;

  Future<void> _export() async {
    if (_categories.isEmpty) return;
    setState(() => _busy = true);
    try {
      final stats = await ref.read(statsProvider.future);
      final bytes = await const ReadingExportService().build(
        database: ref.read(databaseProvider),
        options: ReadingExportOptions(
          format: _format,
          categories: _categories,
          bookId: _bookId,
        ),
        statistics: stats,
      );
      await const ReadingExportService().share(
        bytes: bytes,
        fileName: 'streak-reader-export',
        format: _format,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksListProvider).valueOrNull ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Export reading data')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Choose what to include'),
          for (final category in ExportCategory.values)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_label(category)),
              value: _categories.contains(category),
              onChanged: (value) => setState(() {
                if (value == true) {
                  _categories.add(category);
                } else {
                  _categories.remove(category);
                }
              }),
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _bookId,
            decoration: const InputDecoration(labelText: 'Scope'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All books')),
              for (final book in books)
                DropdownMenuItem(value: book.id, child: Text(book.title)),
            ],
            onChanged: (value) => setState(() => _bookId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExportFormat>(
            initialValue: _format,
            decoration: const InputDecoration(labelText: 'Format'),
            items: const [
              DropdownMenuItem(
                  value: ExportFormat.markdown, child: Text('Markdown (.md)')),
              DropdownMenuItem(
                  value: ExportFormat.plainText,
                  child: Text('Plain text (.txt)')),
              DropdownMenuItem(
                  value: ExportFormat.pdf, child: Text('PDF (.pdf)')),
            ],
            onChanged: (value) => setState(() => _format = value!),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy || _categories.isEmpty ? null : _export,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_rounded),
            label: const Text('Export and share'),
          ),
        ],
      ),
    );
  }

  static String _label(ExportCategory category) => switch (category) {
        ExportCategory.notes => 'Book notes',
        ExportCategory.highlights => 'Saved quotes and highlights',
        ExportCategory.bookmarks => 'Bookmarks',
        ExportCategory.journal => 'Reading journal',
        ExportCategory.statistics => 'Reading statistics',
      };
}
