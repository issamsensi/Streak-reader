import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/focus_mode_preferences.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_exists.dart';
import '../../../data/datasources/local/app_database.dart';
import '../providers/reading_session_provider.dart';
import 'session_controls.dart';
import 'annotations_sheet.dart';
import 'note_draft.dart';
import '../../assistant/presentation/book_assistant_screen.dart';

class PdfReaderScreen extends ConsumerStatefulWidget {
  final int bookId;
  final String bookTitle;
  final String filePath;
  final int initialPage;

  const PdfReaderScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.filePath,
    required this.initialPage,
  });

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen>
    with WidgetsBindingObserver {
  final PdfViewerController _controller = PdfViewerController();
  Timer? _displayTimer;
  // Cached in initState so dispose() never touches `ref` after unmount.
  ReadingSessionController? _sessionController;
  bool _sessionReady = false;
  List<Bookmark> _bookmarks = const [];
  List<Highlight> _highlights = const [];
  List<Note> _notes = const [];
  PdfTextRanges? _selection;

  int _currentPage = 1;
  int _pageCount = 0;

  // Focus Mode chrome. Pure visibility state: toggling it never touches
  // the reading session controller.
  ReaderChrome _chrome = ReaderChrome.initial(const FocusModePreferences());
  Timer? _autoHideTimer;
  Offset? _tapDownPosition;
  DateTime? _tapDownTime;
  bool _tapDownHadSelection = false;

  // Books store lastPage as a 1-based page (0 = not started yet).
  int get _initialPage => widget.initialPage > 0 ? widget.initialPage : 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPage = _initialPage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sessionController = ref.read(readingSessionControllerProvider.notifier);
      _sessionController!.setBookContext(widget.bookId, _initialPage);
      unawaited(_restoreSession());
      unawaited(_loadAnnotations());
      unawaited(_applyFocusDefault());
      _startDisplayTimer();
    });
  }

  /// Applies the persisted "open in Focus Mode" preference once, after the
  /// settings store has loaded.
  Future<void> _applyFocusDefault() async {
    await ref.read(settingsProvider.notifier).initialized;
    if (!mounted) return;
    setState(() {
      _chrome = ReaderChrome.initial(ref.read(settingsProvider).focusMode);
    });
    _applySystemUi();
  }

  void _applySystemUi() {
    if (_chrome.isFocus) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  void _setFocus(bool focus) {
    _autoHideTimer?.cancel();
    setState(() => focus ? _chrome.enterFocus() : _chrome.exitFocus());
    _applySystemUi();
  }

  void _onTapGesture(FocusTapBehavior behavior) {
    final scheduleAutoHide = _chrome.onTap(behavior);
    setState(() {});
    _autoHideTimer?.cancel();
    if (scheduleAutoHide) {
      _autoHideTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _chrome.onAutoHide());
        _applySystemUi();
      });
    }
    _applySystemUi();
  }

  void _handlePointerDown(PointerDownEvent event) {
    _onInteraction();
    _tapDownPosition = event.position;
    _tapDownTime = DateTime.now();
    _tapDownHadSelection = _selection != null;
  }

  void _handlePointerUp(PointerUpEvent event) {
    _onInteraction();
    final downPosition = _tapDownPosition;
    final downTime = _tapDownTime;
    _tapDownPosition = null;
    _tapDownTime = null;
    if (downPosition == null || downTime == null || _tapDownHadSelection) {
      return;
    }
    // A real tap, not a scroll (moves) or a selection long-press (holds).
    final moved = (event.position - downPosition).distance;
    final held = DateTime.now().difference(downTime);
    if (moved < 12 && held < const Duration(milliseconds: 350)) {
      _onTapGesture(ref.read(settingsProvider).focusMode.tapBehavior);
    }
  }

  AppDatabase get _database => ref.read(databaseProvider);

  Future<void> _loadAnnotations() async {
    final results = await Future.wait([
      _database.getBookmarks(widget.bookId),
      _database.getHighlights(widget.bookId),
      _database.getNotes(widget.bookId),
    ]);
    if (!mounted) return;
    setState(() {
      _bookmarks = results[0] as List<Bookmark>;
      _highlights = results[1] as List<Highlight>;
      _notes = results[2] as List<Note>;
    });
  }

  Future<void> _toggleBookmark() async {
    final l10n = context.l10n;
    final existing =
        await _database.getBookmarkForPage(widget.bookId, _currentPage);
    if (existing != null) {
      await _database.deleteBookmark(existing.id);
    } else {
      final title = await _askForText(
        l10n.bookmarkTitle,
        l10n.bookmarkTitleHint,
      );
      if (title == null) return;
      await _database.addBookmark(
        BookmarksCompanion.insert(
          bookId: widget.bookId,
          pageNumber: _currentPage,
          title: drift.Value(title.trim().isEmpty ? null : title.trim()),
        ),
      );
    }
    await _loadAnnotations();
  }

  Future<String?> _askForText(String title, String hint) {
    final textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (_) => Navigator.of(context).pop(textController.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(textController.text),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    ).whenComplete(textController.dispose);
  }

  Future<void> _saveSelectionHighlight() async {
    final selection = _selection;
    if (selection == null || selection.isEmpty) return;
    final color = await _chooseHighlightColor();
    if (color == null) return;
    final bounds = selection.bounds;
    await _database.addHighlight(
      HighlightsCompanion.insert(
        bookId: widget.bookId,
        pageNumber: selection.pageNumber,
        selectedText: selection.text,
        startIndex: selection.ranges.first.start,
        endIndex: selection.ranges.last.end,
        left: bounds.left,
        top: bounds.top,
        right: bounds.right,
        bottom: bounds.bottom,
        colorValue: color,
      ),
    );
    if (!mounted) return;
    setState(() => _selection = null);
    await _loadAnnotations();
  }

  Future<int?> _chooseHighlightColor() {
    const colors = [0x66FFEB3B, 0x6655D66A, 0x6654B6FF, 0x66FF8A65];
    return showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colors
                .map(
                  (color) => IconButton(
                    tooltip: context.l10n.highlight,
                    onPressed: () => Navigator.of(context).pop(color),
                    icon: CircleAvatar(
                      backgroundColor: Color(color),
                      child: const Icon(Icons.check, color: Colors.black54),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _editNote(Note? note, {int? defaultPage}) async {
    final controller = TextEditingController(text: note?.content ?? '');
    var linkedToPage = note?.pageNumber != null || defaultPage != null;
    final draft = await showDialog<NoteDraft>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title:
              Text(note == null ? context.l10n.newNote : context.l10n.editNote),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 5,
                  maxLines: 12,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: context.l10n.noteHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: linkedToPage,
                  onChanged: (value) => setDialogState(
                    () => linkedToPage = value ?? false,
                  ),
                  title: Text(context.l10n.linkNoteToPage),
                  subtitle: Text(
                    context.l10n.pageNumberLabel(defaultPage ?? _currentPage),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                NoteDraft(
                  controller.text,
                  linkedToPage ? (note?.pageNumber ?? defaultPage) : null,
                ),
              ),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (draft == null || draft.content.trim().isEmpty) return;
    final now = DateTime.now();
    if (note == null) {
      await _database.addNote(
        NotesCompanion.insert(
          bookId: widget.bookId,
          pageNumber: drift.Value(draft.pageNumber),
          content: draft.content,
          createdAt: drift.Value(now),
          modifiedAt: drift.Value(now),
        ),
      );
    } else {
      await _database.updateNote(
        note.id,
        NotesCompanion(
          content: drift.Value(draft.content),
          pageNumber: drift.Value(draft.pageNumber),
          modifiedAt: drift.Value(now),
        ),
      );
    }
    await _loadAnnotations();
  }

  Future<void> _showAnnotations() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AnnotationsSheet(
        bookmarks: _bookmarks,
        highlights: _highlights,
        notes: _notes,
        onBookmarkTap: (page) {
          Navigator.of(context).pop();
          unawaited(_goToPage(page));
        },
        onHighlightTap: (page) {
          Navigator.of(context).pop();
          unawaited(_goToPage(page));
        },
        onNoteTap: (page) {
          Navigator.of(context).pop();
          unawaited(_goToPage(page));
        },
        onDeleteBookmark: (id) async {
          await _database.deleteBookmark(id);
          await _loadAnnotations();
        },
        onEditHighlight: (highlight) async {
          final color = await _chooseHighlightColor();
          if (color == null) return;
          await _database.updateHighlight(
            highlight.id,
            HighlightsCompanion(colorValue: drift.Value(color)),
          );
          await _loadAnnotations();
        },
        onDeleteHighlight: (id) async {
          await _database.deleteHighlight(id);
          await _loadAnnotations();
        },
        onEditNote: (note) => _editNote(note),
        onDeleteNote: (id) async {
          await _database.deleteNote(id);
          await _loadAnnotations();
        },
      ),
    );
  }

  Future<void> _goToPage(int page) async {
    if (!_controller.isReady) return;
    await _controller.goToPage(pageNumber: page, duration: Duration.zero);
  }

  Future<void> _restoreSession() async {
    final controller = _sessionController;
    if (controller == null) return;
    await controller.restore(widget.bookId, _initialPage);
    if (mounted) {
      setState(() => _sessionReady = true);
    }
  }

  void _startDisplayTimer() {
    _displayTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _onInteraction() {
    final controller = _sessionController;
    if (controller == null || !mounted) return;
    controller.recordInteraction();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush the last page when the app is backgrounded or about to be
    // killed; dispose() is not guaranteed to run in that case.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      final controller = _sessionController;
      if (controller != null) {
        unawaited(controller.pause());
        unawaited(controller.persistCurrentPage());
      }
    } else if (state == AppLifecycleState.resumed) {
      // Restore immersive/normal system bars after rotation, unlocking, or
      // returning from another app; mode and controls state are kept.
      _applySystemUi();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _displayTimer?.cancel();
    _autoHideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // Fire-and-forget on the cached controller only: no `ref` use here,
    // and the provider outlives this widget so the write completes.
    final controller = _sessionController;
    if (controller != null) unawaited(controller.finish());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!fileExists(widget.filePath)) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.errorTitle)),
        body: Center(
          child: Text(
            context.l10n.readerFileMissing,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    // Watch so changing the tap-behavior preference applies immediately.
    ref.watch(settingsProvider);
    final chromeVisible = _chrome.controlsVisible;

    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerDown: _handlePointerDown,
            onPointerMove: (_) => _onInteraction(),
            onPointerUp: _handlePointerUp,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _onInteraction();
                return false;
              },
              child: PdfViewer.file(
                widget.filePath,
                controller: _controller,
                initialPageNumber: _initialPage,
                params: PdfViewerParams(
                  enableTextSelection: true,
                  onTextSelectionChange: (selection) {
                    if (!mounted) return;
                    final selected =
                        selection.where((range) => range.isNotEmpty);
                    setState(() {
                      _selection = selected.isEmpty ? null : selected.first;
                    });
                  },
                  pageOverlaysBuilder: (context, pageRect, page) {
                    return _highlights
                        .where((highlight) =>
                            highlight.pageNumber == page.pageNumber)
                        .map(
                          (highlight) => Positioned.fromRect(
                            rect: PdfRect(
                              highlight.left,
                              highlight.top,
                              highlight.right,
                              highlight.bottom,
                            ).toRect(
                              page: page,
                              scaledPageSize: pageRect.size,
                            ),
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(highlight.colorValue),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList();
                  },
                  backgroundColor: theme.colorScheme.surface,
                  loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              value: totalBytes != null && totalBytes > 0
                                  ? bytesDownloaded / totalBytes
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.loadingPdf,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                  errorBannerBuilder:
                      (context, error, stackTrace, documentRef) {
                    final errorTheme = Theme.of(context);
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: errorTheme.colorScheme.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.readerLoadError,
                              textAlign: TextAlign.center,
                              style: errorTheme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              error.toString(),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: errorTheme.textTheme.bodySmall?.copyWith(
                                color: errorTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onViewerReady: (document, controller) {
                    if (!mounted) return;
                    final pageCount = document.pages.length;
                    setState(() => _pageCount = pageCount);
                    // The stored page can be stale if the PDF was replaced by
                    // a shorter document. Clamp it so reading can continue.
                    if (pageCount > 0 && _currentPage > pageCount) {
                      _sessionController?.updatePage(pageCount);
                      setState(() => _currentPage = pageCount);
                      unawaited(
                        controller.goToPage(
                          pageNumber: pageCount,
                          duration: Duration.zero,
                        ),
                      );
                    }
                  },
                  onPageChanged: (page) {
                    _onInteraction();
                    if (page == null || !mounted) return;
                    _sessionController?.updatePage(page);
                    setState(() {
                      _currentPage = page;
                      if (_controller.isReady) {
                        _pageCount = _controller.pageCount;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          if (_pageCount > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: _FadingChrome(
                visible: chromeVisible,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_currentPage / $_pageCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: AppTheme.displayFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 76,
            right: 16,
            child: _FadingChrome(
              visible: chromeVisible && !_chrome.isFocus,
              child: Material(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Book assistant',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookAssistantScreen(
                            bookTitle: widget.bookTitle,
                            notes: _notes.isEmpty
                                ? null
                                : _notes.map((note) => note.content).join('\n'),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white),
                    ),
                    IconButton(
                      tooltip: context.l10n.bookmark,
                      onPressed: _toggleBookmark,
                      icon: Icon(
                        _bookmarks.any((b) => b.pageNumber == _currentPage)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.annotations,
                      onPressed: _showAnnotations,
                      icon: const Icon(Icons.menu_book, color: Colors.white),
                    ),
                    IconButton(
                      tooltip: context.l10n.newNote,
                      onPressed: () =>
                          _editNote(null, defaultPage: _currentPage),
                      icon: const Icon(Icons.note_add_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selection != null)
            Positioned(
              left: 16,
              right: 16,
              top: 76,
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveSelectionHighlight,
                      icon: const Icon(Icons.highlight),
                      label: Text(context.l10n.saveHighlight),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Ask assistant about selection',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookAssistantScreen(
                          bookTitle: widget.bookTitle,
                          selectedText: _selection?.text,
                          notes: _notes.isEmpty
                              ? null
                              : _notes.map((note) => note.content).join('\n'),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded),
                  ),
                ],
              ),
            ),
          if (_sessionController != null && _sessionReady)
            Positioned(
              left: 16,
              right: 16,
              bottom: _pageCount > 0 ? 64 : 18,
              child: _FadingChrome(
                visible: chromeVisible && !_chrome.isFocus,
                child: SessionControls(
                  controller: _sessionController!,
                  bookId: widget.bookId,
                  initialPage: _currentPage,
                  onChanged: () {
                    if (mounted) setState(() {});
                  },
                ),
              ),
            ),
          // Top bar: full in Normal Mode; in Focus Mode this same bar is
          // the minimal revealed control, with a clear Exit Focus action.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _FadingChrome(
              visible: chromeVisible,
              child: Material(
                color: Colors.black.withValues(alpha: 0.72),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          widget.bookTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      if (_chrome.isFocus)
                        TextButton.icon(
                          onPressed: () => _setFocus(false),
                          icon: const Icon(Icons.fullscreen_exit_rounded,
                              color: Colors.white),
                          label: const Text(
                            'Exit Focus',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      else
                        IconButton(
                          tooltip: 'Focus Mode',
                          onPressed: () => _setFocus(true),
                          icon: const Icon(Icons.fullscreen_rounded,
                              color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle fade for reader chrome; hidden chrome ignores pointers.
class _FadingChrome extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _FadingChrome({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !visible,
          child: ExcludeSemantics(excluding: !visible, child: child),
        ),
      );
}
