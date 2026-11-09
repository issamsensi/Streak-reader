import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../data/datasources/local/app_database.dart';
import '../../providers/books_providers.dart';

class AddBookSheet extends ConsumerStatefulWidget {
  /// When non-null the sheet edits this book instead of creating one.
  final Book? book;

  const AddBookSheet({super.key, this.book});

  @override
  ConsumerState<AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends ConsumerState<AddBookSheet> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _filePath;
  String? _coverPath;
  String? _fileName;
  int? _fileSize;
  String? _errorText;
  bool _loading = false;
  bool _showMetadata = false;
  String _status = 'want_to_read';
  DateTime? _completionDate;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    if (book != null) {
      _titleController.text = book.title;
      _authorController.text = book.author ?? '';
      _pagesController.text = book.totalPages?.toString() ?? '';
      _descriptionController.text = book.description ?? '';
      _coverPath = book.coverPath;
      _filePath = book.filePath;
      _fileName = book.fileName;
      _fileSize = book.fileSize;
      _status = book.readingStatus;
      _completionDate = book.completionDate;
      _showMetadata = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final l10n = context.l10n;
    PlatformFile? picked;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        // Bytes are only needed on web, where there is no local path to
        // count pages from; loading them on mobile would waste memory.
        withData: kIsWeb,
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

    // Auto-fill total pages from the PDF; the field stays editable, and
    // a failed count simply leaves it for manual entry.
    final pageCount = await ref.read(pdfPageCounterProvider)(
      filePath: picked.path,
      bytes: picked.bytes,
      sourceName: picked.name,
    );
    if (!mounted || pageCount == null) return;
    setState(() {
      _pagesController.text = pageCount.toString();
      _showMetadata = true;
    });
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || !mounted) return;
    setState(() => _coverPath = result.files.single.path);
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
      if (_isEditing) {
        // Editing only rewrites the books row; sessions, notes, bookmarks
        // and other records keyed by book id stay untouched.
        await ref.read(booksRepositoryProvider).updateBookDetails(
              widget.book!.id,
              title: title,
              author: _authorController.text.trim().isEmpty
                  ? null
                  : _authorController.text.trim(),
              totalPages: int.tryParse(_pagesController.text.trim()),
              coverPath: _coverPath,
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              status: _status,
              completionDate: _status == 'completed' ? _completionDate : null,
            );
      } else {
        await ref.read(booksRepositoryProvider).addBook(
              title: title,
              author: _authorController.text.trim().isEmpty
                  ? null
                  : _authorController.text.trim(),
              totalPages: int.tryParse(_pagesController.text.trim()),
              filePath: _filePath,
              fileName: _fileName,
              fileSize: _fileSize,
              coverPath: _coverPath,
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              status: _status,
              completionDate: _completionDate,
              historical: _status == 'completed' && _filePath == null,
            );
      }
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
                    Text(
                      _isEditing ? 'Edit Details' : l10n.addBook,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEditing
                          ? 'Update book information'
                          : l10n.addBookSubtitle,
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
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Reading status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'want_to_read',
                  child: Text('Want to Read'),
                ),
                DropdownMenuItem(
                  value: 'currently_reading',
                  child: Text('Currently Reading'),
                ),
                DropdownMenuItem(
                  value: 'completed',
                  child: Text('Completed'),
                ),
                DropdownMenuItem(value: 'paused', child: Text('Paused')),
                DropdownMenuItem(
                  value: 'abandoned',
                  child: Text('Abandoned'),
                ),
              ],
              onChanged: (value) => setState(() => _status = value!),
            ),
            if (_status == 'completed') ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  _completionDate == null
                      ? 'Completion date (optional)'
                      : 'Completed ${_completionDate!.year}-'
                          '${_completionDate!.month.toString().padLeft(2, '0')}-'
                          '${_completionDate!.day.toString().padLeft(2, '0')}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    initialDate: _completionDate ?? DateTime.now(),
                  );
                  if (picked != null) setState(() => _completionDate = picked);
                },
              ),
            ],
          ],
          if (!_isEditing) ...[
            const SizedBox(height: 12),
            _PdfPickerTile(fileName: _fileName, onTap: _pickPdf),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickCover,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              _coverPath == null
                  ? 'Add cover image (optional)'
                  : 'Cover selected',
            ),
          ),
          if (_filePath == null && !_isEditing)
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
