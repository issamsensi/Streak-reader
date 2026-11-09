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
  /// Optional reload for callers that can provide fresh snapshots after edits.
  /// Keeps API compatible with existing call sites.
  final Future<({List<Bookmark> bookmarks, List<Highlight> highlights, List<Note> notes})>
      Function()? onReload;

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
    this.onReload,
  });

  @override
  State<AnnotationsSheet> createState() => _AnnotationsSheetState();
}

class _AnnotationsSheetState extends State<AnnotationsSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<Bookmark> _bookmarks;
  late List<Highlight> _highlights;
  late List<Note> _notes;

  @override
  void initState() {
    super.initState();
    _bookmarks = List<Bookmark>.of(widget.bookmarks);
    _highlights = List<Highlight>.of(widget.highlights);
    _notes = List<Note>.of(widget.notes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final reload = widget.onReload;
    if (reload != null) {
      final data = await reload();
      if (!mounted) return;
      setState(() {
        _bookmarks = List<Bookmark>.of(data.bookmarks);
        _highlights = List<Highlight>.of(data.highlights);
        _notes = List<Note>.of(data.notes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final filteredNotes = query.isEmpty
        ? _notes
        : _notes
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
            if (_bookmarks.isEmpty)
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text(context.l10n.noBookmarks),
              )
            else
              ..._bookmarks.map(
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
                    onPressed: () async {
                      await widget.onDeleteBookmark(bookmark.id);
                      if (!mounted) return;
                      setState(() {
                        _bookmarks = _bookmarks
                            .where((item) => item.id != bookmark.id)
                            .toList();
                      });
                      await _reload();
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(context.l10n.highlights, style: theme.textTheme.titleMedium),
            if (_highlights.isEmpty)
              ListTile(
                leading: const Icon(Icons.highlight_outlined),
                title: Text(context.l10n.noHighlights),
              )
            else
              ..._highlights.map(
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
                        onPressed: () async {
                          await widget.onEditHighlight(highlight);
                          await _reload();
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: context.l10n.delete,
                        onPressed: () async {
                          await widget.onDeleteHighlight(highlight.id);
                          if (!mounted) return;
                          setState(() {
                            _highlights = _highlights
                                .where((item) => item.id != highlight.id)
                                .toList();
                          });
                          await _reload();
                        },
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
                        onPressed: () async {
                          await widget.onEditNote(note);
                          await _reload();
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: context.l10n.delete,
                        onPressed: () async {
                          await widget.onDeleteNote(note.id);
                          if (!mounted) return;
                          setState(() {
                            _notes = _notes
                                .where((item) => item.id != note.id)
                                .toList();
                          });
                          await _reload();
                        },
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
