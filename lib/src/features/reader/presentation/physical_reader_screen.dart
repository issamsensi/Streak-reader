import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/local/app_database.dart';
import '../providers/reading_session_provider.dart';

class PhysicalReaderScreen extends ConsumerStatefulWidget {
  final int bookId;
  final String bookTitle;

  const PhysicalReaderScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  ConsumerState<PhysicalReaderScreen> createState() =>
      _PhysicalReaderScreenState();
}

class _PhysicalReaderScreenState extends ConsumerState<PhysicalReaderScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  ReadingSessionController? _controller;
  List<ReadingSession> _history = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _controller = ref.read(readingSessionControllerProvider.notifier);
      _controller!.setBookContext(widget.bookId, 0);
      await _controller!.restore(widget.bookId, 0);
      await _loadHistory();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadHistory() async {
    final history =
        await ref.read(databaseProvider).getSessionsForBook(widget.bookId);
    if (mounted) setState(() => _history = history);
  }

  Future<void> _toggle() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.isActive) {
      await controller.pause();
    } else if (controller.hasSession) {
      await controller.resume();
    } else {
      controller.start(widget.bookId, 0, readingMode: 'physical');
    }
    if (mounted) setState(() {});
  }

  Future<void> _finish() async {
    final controller = _controller;
    if (controller == null || !controller.hasSession) return;
    final result = await showDialog<_PhysicalSummary>(
      context: context,
      builder: (context) => const _PhysicalSummaryDialog(),
    );
    if (result == null) return;
    controller.setPhysicalPages(result.pagesRead);
    await controller.finish(pagesRead: result.pagesRead, note: result.note);
    await _loadHistory();
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Physical reading intentionally keeps the active segment running while
    // the user checks another app or locks the device.
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.menu_book_rounded, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    'Physical Reading',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppTheme.displayFont,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _formatDuration(controller?.elapsedSeconds ?? 0),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontFamily: AppTheme.displayFont,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: controller == null ? null : _toggle,
                    icon: Icon(
                      controller?.isActive == true
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      controller?.hasSession == true
                          ? controller?.isActive == true
                              ? 'Pause'
                              : 'Resume'
                          : 'Start physical reading',
                    ),
                  ),
                  if (controller?.hasSession == true) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _finish,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('Finish session'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Session history', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_history.isEmpty)
            const Text('Completed physical sessions will appear here.')
          else
            ..._history.map(
              (session) => Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(
                    '${_formatDuration(session.durationSeconds)} • '
                    '${session.date}',
                  ),
                  subtitle: Text(
                    [
                      session.readingMode == 'physical'
                          ? 'Physical Reading'
                          : 'Digital Reading',
                      if (session.pagesRead > 0)
                        '${session.pagesRead} pages',
                      if (session.note != null && session.note!.isNotEmpty)
                        session.note!,
                    ].join(' • '),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }
}

class _PhysicalSummary {
  final int pagesRead;
  final String? note;

  const _PhysicalSummary(this.pagesRead, this.note);
}

class _PhysicalSummaryDialog extends StatefulWidget {
  const _PhysicalSummaryDialog();

  @override
  State<_PhysicalSummaryDialog> createState() => _PhysicalSummaryDialogState();
}

class _PhysicalSummaryDialogState extends State<_PhysicalSummaryDialog> {
  final _pagesController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _pagesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final pages = int.tryParse(_pagesController.text.trim()) ?? 0;
    if (pages < 0) return;
    Navigator.of(context).pop(
      _PhysicalSummary(
        pages,
        _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Session summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pages read (optional)',
              ),
            ),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Personal note (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: _submit, child: const Text('Save session')),
        ],
      );
}
