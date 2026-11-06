import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_exists.dart';
import '../../../core/widgets/streak_banner.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../reader/presentation/pdf_reader_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stats/presentation/stats_screen.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/books_providers.dart';
import 'widgets/add_book_sheet.dart';
import 'widgets/edit_title_dialog.dart';

class BooksListScreen extends ConsumerWidget {
  const BooksListScreen({super.key});

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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    final file = result.files.single;
    if (file.path == null) {
      // Web pickers return bytes instead of a local path.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.attachPdfWebUnsupported)),
        );
      }
      return;
    }
    await ref.read(booksRepositoryProvider).updateBookFile(
          book.id,
          filePath: file.path!,
          fileName: file.name,
          fileSize: file.size,
        );
    ref.invalidate(booksListProvider);
  }

  void _showEditDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (_) =>
          EditTitleDialog(bookId: book.id, currentTitle: book.title),
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
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.noFileTitle),
          content: Text(l10n.noFileBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _attachPdf(context, ref, book);
              },
              child: Text(l10n.addPdf),
            ),
          ],
        ),
      );
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          if (books.isEmpty) {
            return _EmptyLibrary(
              onAdd: () => _showAddSheet(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
            itemCount: books.length + 1,
            separatorBuilder: (context, index) =>
                SizedBox(height: index == 0 ? 18 : 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stats != null) ...[
                      StreakBanner(stats: stats, compact: true),
                      const SizedBox(height: 26),
                    ],
                    Row(
                      children: [
                        Text(
                          l10n.yourBooks,
                          style: theme.textTheme.titleMedium,
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
                            '${books.length}',
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
              }

              final book = books[index - 1];
              return _BookCard(
                book: book,
                onTap: () => _openBook(context, ref, book),
                onEdit: () => _showEditDialog(context, book),
                onAttachPdf: () => _attachPdf(context, ref, book),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text(l10n.errorMessage(err.toString()))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addBook),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onAttachPdf;

  const _BookCard({
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onAttachPdf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = context.palette;
    final hasFile = book.filePath != null && book.filePath!.isNotEmpty;
    final exists = hasFile ? fileExists(book.filePath!) : false;

    final statusColor = !hasFile
        ? palette.muted
        : (!exists ? theme.colorScheme.error : palette.success);
    final statusIcon = !hasFile
        ? Icons.bookmark_border_rounded
        : (exists ? Icons.check_circle_outline_rounded : Icons.error_outline);
    final statusText = !hasFile
        ? l10n.wantToReadNoFile
        : (exists ? (book.fileName ?? '') : l10n.missingFileWarning);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _BookCover(title: book.title, hasFile: hasFile),
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
                    if (hasFile && exists && book.lastPage > 0) ...[
                      const SizedBox(height: 8),
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
                          l10n.pageNumberLabel(book.lastPage),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
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
                  } else if (value == 'attach_pdf') {
                    onAttachPdf();
                  }
                },
                itemBuilder: (context) => [
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
                        Text(l10n.editTitle),
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
                        Text(hasFile ? l10n.changePdf : l10n.addPdf),
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

  const _BookCover({required this.title, required this.hasFile});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.coverGradientFor(title);
    final trimmed = title.trim();
    final initial =
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();

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
