import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';

final readingSessionControllerProvider =
    StateNotifierProvider<ReadingSessionController, ReadingSessionState>((ref) {
  final db = ref.watch(databaseProvider);
  return ReadingSessionController(db);
});

class ReadingSessionState {
  final bool isActive;
  final DateTime? startTime;
  final int pagesAtStart;
  final int currentPage;
  final int bookId;
  final int elapsedSeconds;

  const ReadingSessionState({
    required this.isActive,
    this.startTime,
    required this.pagesAtStart,
    required this.currentPage,
    required this.bookId,
    required this.elapsedSeconds,
  });

  factory ReadingSessionState.initial(int bookId) => ReadingSessionState(
        isActive: false,
        startTime: null,
        pagesAtStart: 0,
        currentPage: 0,
        bookId: bookId,
        elapsedSeconds: 0,
      );

  ReadingSessionState copyWith({
    bool? isActive,
    DateTime? startTime,
    int? pagesAtStart,
    int? currentPage,
    int? bookId,
    int? elapsedSeconds,
  }) {
    return ReadingSessionState(
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      pagesAtStart: pagesAtStart ?? this.pagesAtStart,
      currentPage: currentPage ?? this.currentPage,
      bookId: bookId ?? this.bookId,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class ReadingSessionController extends StateNotifier<ReadingSessionState> {
  final AppDatabase db;
  DateTime _lastInteraction = DateTime.now();
  bool _isSaving = false;

  ReadingSessionController(this.db) : super(ReadingSessionState.initial(0));

  void start(int bookId, int initialPage) {
    _lastInteraction = DateTime.now();
    state = ReadingSessionState(
      isActive: true,
      startTime: DateTime.now(),
      pagesAtStart: initialPage,
      currentPage: initialPage,
      bookId: bookId,
      elapsedSeconds: 0,
    );
  }

  bool get isActive => state.isActive;
  int get currentPage => state.currentPage;

  void recordInteraction() {
    _lastInteraction = DateTime.now();
  }

  void updatePage(int page) {
    recordInteraction();
    state = state.copyWith(currentPage: page);
  }

  bool isIdle(int idleMinutes) {
    if (!state.isActive) return true;
    return DateTime.now().difference(_lastInteraction).inMinutes >= idleMinutes;
  }

  int getPagesRead() {
    if (state.currentPage <= state.pagesAtStart) return 0;
    return state.currentPage - state.pagesAtStart;
  }

  Future<void> stopAndSave() async {
    if (_isSaving || !state.isActive || state.startTime == null) return;
    _isSaving = true;
    // Capture before any reset/await: reading state after the save
    // previously always yielded page 0.
    final bookId = state.bookId;
    final currentPage = state.currentPage;
    final startTime = state.startTime!;
    final pagesRead = getPagesRead();
    // Mark inactive up-front so idle-save and dispose cannot race a
    // duplicate insert, while preserving the page for a later restart.
    state = ReadingSessionState(
      isActive: false,
      pagesAtStart: currentPage,
      currentPage: currentPage,
      bookId: bookId,
      elapsedSeconds: 0,
    );
    try {
      if (bookId > 0 && currentPage > 0) {
        await db.updateBookLastPage(bookId, currentPage);
      }
      final now = DateTime.now();
      final duration = now.difference(startTime).inSeconds;
      if (duration <= 0) return;
      final date = DateFormat('yyyy-MM-dd').format(now);
      await db.insertSession(
        ReadingSessionsCompanion(
          bookId: drift.Value(bookId),
          date: drift.Value(date),
          durationSeconds: drift.Value(duration),
          pagesRead: drift.Value(pagesRead),
        ),
      );
    } finally {
      _isSaving = false;
    }
  }
}
