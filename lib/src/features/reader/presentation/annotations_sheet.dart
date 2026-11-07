import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../data/datasources/local/app_database.dart';

class AnnotationsSheet extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final List<Highlight> highlights;
  final ValueChanged<int> onBookmarkTap;
  final ValueChanged<int> onHighlightTap;
  final Future<void> Function(int) onDeleteBookmark;
  final Future<void> Function(Highlight) onEditHighlight;
  final Future<void> Function(int) onDeleteHighlight;

  const AnnotationsSheet({
    super.key,
    required this.bookmarks,
    required this.highlights,
    required this.onBookmarkTap,
    required this.onHighlightTap,
    required this.onDeleteBookmark,
    required this.onEditHighlight,
    required this.onDeleteHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            const SizedBox(height: 16),
            Text(context.l10n.bookmarks, style: theme.textTheme.titleMedium),
            if (bookmarks.isEmpty)
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text(context.l10n.noBookmarks),
              )
            else
              ...bookmarks.map(
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
                  onTap: () => onBookmarkTap(bookmark.pageNumber),
                  trailing: IconButton(
                    tooltip: context.l10n.delete,
                    onPressed: () => onDeleteBookmark(bookmark.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(context.l10n.highlights, style: theme.textTheme.titleMedium),
            if (highlights.isEmpty)
              ListTile(
                leading: const Icon(Icons.highlight_outlined),
                title: Text(context.l10n.noHighlights),
              )
            else
              ...highlights.map(
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
                  onTap: () => onHighlightTap(highlight.pageNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: context.l10n.edit,
                        onPressed: () => onEditHighlight(highlight),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: context.l10n.delete,
                        onPressed: () => onDeleteHighlight(highlight.id),
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
