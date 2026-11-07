import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_exists.dart';
import '../providers/reading_session_provider.dart';

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
  Timer? _idleTimer;
  // Cached in initState so dispose() never touches `ref` after unmount.
  ReadingSessionController? _sessionController;

  int _currentPage = 1;
  int _pageCount = 0;

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
      _sessionController!.start(widget.bookId, _initialPage);
      _startTimers();
    });
  }

  void _startTimers() {
    // Keep the timer alive after an idle save so a later idle period
    // in the same sitting is also detected.
    _idleTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted) return;
      final controller = _sessionController;
      if (controller == null || !controller.isActive) return;
      if (controller.isIdle(AppConstants.idleTimeoutMinutes)) {
        await controller.stopAndSave();
      }
    });
  }

  void _onInteraction() {
    final controller = _sessionController;
    if (controller == null || !mounted) return;
    if (!controller.isActive) {
      // Restart tracking after an idle save, from the preserved page.
      final resumePage =
          controller.currentPage > 0 ? controller.currentPage : _initialPage;
      controller.start(widget.bookId, resumePage);
    } else {
      controller.recordInteraction();
    }
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
        unawaited(controller.persistCurrentPage());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    // Fire-and-forget on the cached controller only: no `ref` use here,
    // and the provider outlives this widget so the write completes.
    final controller = _sessionController;
    if (controller != null) {
      unawaited(controller.stopAndSave());
    }
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.bookTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: Stack(
        children: [
          Listener(
            onPointerDown: (_) => _onInteraction(),
            onPointerMove: (_) => _onInteraction(),
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
              child: IgnorePointer(
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
        ],
      ),
    );
  }
}
