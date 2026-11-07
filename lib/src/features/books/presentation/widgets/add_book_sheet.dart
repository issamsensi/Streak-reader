import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../providers/books_providers.dart';

class AddBookSheet extends ConsumerStatefulWidget {
  const AddBookSheet({super.key});

  @override
  ConsumerState<AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends ConsumerState<AddBookSheet> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  String? _filePath;
  String? _fileName;
  int? _fileSize;
  String? _errorText;
  bool _loading = false;
  bool _showMetadata = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final l10n = context.l10n;
    PlatformFile? picked;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );
      if (result == null) return;
      picked = result.files.single;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorMessage(error.toString()))),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      // On web, FilePicker provides bytes/name but no local path; the book
      // is then saved title-only (wishlist) instead of silently doing nothing.
      _filePath = picked!.path;
      _fileName = picked.name;
      _fileSize = picked.size;
      if (_titleController.text.isEmpty) {
        _titleController.text = picked.name
            .replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), '');
      }
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = l10n.titleRequired);
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await ref.read(booksRepositoryProvider).addBook(
            title: title,
            author: _authorController.text.trim().isEmpty
                ? null
                : _authorController.text.trim(),
            totalPages: int.tryParse(_pagesController.text.trim()),
            filePath: _filePath,
            fileName: _fileName,
            fileSize: _fileSize,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
      return;
    }

    if (!mounted) return;
    ref.invalidate(booksListProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.library_add_rounded,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.addBook, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      l10n.addBookSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            decoration: InputDecoration(
              labelText: l10n.bookTitle,
              prefixIcon: const Icon(Icons.menu_book_outlined),
              errorText: _errorText,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() => _showMetadata = !_showMetadata),
            icon: Icon(
              _showMetadata ? Icons.expand_less : Icons.expand_more,
            ),
            label: Text(l10n.bookDetailsOptional),
          ),
          if (_showMetadata) ...[
            TextField(
              controller: _authorController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.authorOptional,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.totalPagesOptional,
                prefixIcon: const Icon(Icons.format_list_numbered),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _PdfPickerTile(fileName: _fileName, onTap: _pickPdf),
          if (_filePath == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.titleOnlyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loading ? null : _save,
            icon: _loading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _PdfPickerTile extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;

  const _PdfPickerTile({required this.fileName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasFile = fileName != null;

    return Material(
      color: hasFile
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFile
                  ? scheme.primary.withValues(alpha: 0.35)
                  : scheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      hasFile ? scheme.primary : scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 20,
                  color: hasFile ? scheme.onPrimary : scheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fileName ?? l10n.choosePdfFile,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (hasFile) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.changePdf,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                color: hasFile ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
