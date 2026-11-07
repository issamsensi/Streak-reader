import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../data/datasources/local/app_database.dart';

class AnnotationsSheet extends StatefulWidget {
  final List<Bookmark> bookmarks;
  final List<Highlight> highlights;
  final List<Note> notes;
  final ValueChanged<int> onBookmarkTap;
  final ValueChanged<int> onHighlightTap;
  final ValueChanged<int> onNoteTap;
  final Future<void> Function(int) onDeleteBookmark;
  final Future<void> Function(Highlight) onEditHighlight;
  final Future<void> Function(int) onDeleteHighlight;
  final Future<void> Function(Note) onEditNote;
  final Future<void> Function(int) onDeleteNote;

  const AnnotationsSheet({
    super.key,
    required this.bookmarks,
    required this.highlights,
    required this.notes,
    required this.onBookmarkTap,
    required this.onHighlightTap,
    required this.onNoteTap,
    required this.onDeleteBookmark,
    required this.onEditHighlight,
    required this.onDeleteHighlight,
    required this.onEditNote,
    required this.onDeleteNote,
  });

  @override
  State<AnnotationsSheet> createState() => _AnnotationsSheetState();
}

class _AnnotationsSheetState extends State<AnnotationsSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final filteredNotes = query.isEmpty
        ? widget.notes
        : widget.notes
            .where((note) => note.content.toLowerCase().contains(query))
            .toList();

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .65,
        minChildSize: .35,
        maxChildSize: .9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(context.l10n.annotations, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: context.l10n.searchNotes,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.bookmarks, style: theme.textTheme.titleMedium),
            if (widget.bookmarks.isEmpty)
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text(context.l10n.noBookmarks),
              )
            else
              ...widget.bookmarks.map(
                (bookmark) => ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(
                    bookmark.title?.isNotEmpty == true
                        ? bookmark.title!
                        : context.l10n.pageNumberLabel(bookmark.pageNumber),
                  ),
                  subtitle: bookmark.title?.isNotEmpty == true
                      ? Text(context.l10n.pageNumberLabel(bookmark.pageNumber))
                      : null,
                  onTap: () => widget.onBookmarkTap(bookmark.pageNumber),
                  trailing: IconButton(
                    tooltip: context.l10n.delete,
                    onPressed: () => widget.onDeleteBookmark(bookmark.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(context.l10n.highlights, style: theme.textTheme.titleMedium),
            if (widget.highlights.isEmpty)
              ListTile(
                leading: const Icon(Icons.highlight_outlined),
                title: Text(context.l10n.noHighlights),
              )
            else
              ...widget.highlights.map(
                (highlight) => ListTile(
                  leading: Icon(
                    Icons.highlight,
                    color: Color(highlight.colorValue),
                  ),
                  title: Text(
                    highlight.selectedText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle:
                      Text(context.l10n.pageNumberLabel(highlight.pageNumber)),
                  onTap: () => widget.onHighlightTap(highlight.pageNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: context.l10n.edit,
                        onPressed: () => widget.onEditHighlight(highlight),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: context.l10n.delete,
                        onPressed: () => widget.onDeleteHighlight(highlight.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(context.l10n.notes, style: theme.textTheme.titleMedium),
            if (filteredNotes.isEmpty)
              ListTile(
                leading: const Icon(Icons.notes),
                title: Text(
                  query.isEmpty
                      ? context.l10n.noNotes
                      : context.l10n.noMatchingNotes,
                ),
              )
            else
              ...filteredNotes.map(
                (note) => ListTile(
                  leading: const Icon(Icons.notes_outlined),
                  title: Text(
                    note.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${note.pageNumber == null ? context.l10n.generalNote : context.l10n.pageNumberLabel(note.pageNumber!)} • '
                    '${context.l10n.noteUpdatedAt(DateFormat.yMMMd().add_jm().format(note.modifiedAt))}',
                  ),
                  onTap: note.pageNumber == null
                      ? null
                      : () => widget.onNoteTap(note.pageNumber!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: context.l10n.edit,
                        onPressed: () => widget.onEditNote(note),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: context.l10n.delete,
                        onPressed: () => widget.onDeleteNote(note.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
