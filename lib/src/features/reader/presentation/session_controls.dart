import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/reading_session_provider.dart';

class SessionControls extends StatelessWidget {
  final ReadingSessionController controller;
  final int bookId;
  final int initialPage;
  final VoidCallback onChanged;

  const SessionControls({
    super.key,
    required this.controller,
    required this.bookId,
    required this.initialPage,
    required this.onChanged,
  });

  Future<void> _toggle() async {
    if (controller.isActive) {
      await controller.pause();
    } else if (controller.hasSession) {
      await controller.resume();
    } else {
      controller.start(
        bookId,
        controller.currentPage > 0 ? controller.currentPage : initialPage,
      );
    }
    onChanged();
  }

  Future<void> _finish() async {
    await controller.finish();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final running = controller.isActive;
    final hasSession = controller.hasSession;
    return Material(
      color: Colors.transparent,
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.black.withValues(alpha: 0.82),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Icon(
                running ? Icons.timer_rounded : Icons.pause_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(controller.elapsedSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppTheme.displayFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: _toggle,
                icon: Icon(running ? Icons.pause : Icons.play_arrow),
                label: Text(
                  running
                      ? l10n.pauseReading
                      : hasSession
                          ? l10n.resumeReading
                          : l10n.startReading,
                ),
                style: FilledButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ),
              if (hasSession) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: l10n.finishReading,
                  onPressed: _finish,
                  color: Colors.white,
                  icon: const Icon(Icons.stop_circle_outlined),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }
}
