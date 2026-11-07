import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';

final readingSessionControllerProvider =
    StateNotifierProvider<ReadingSessionController, ReadingSessionState>((ref) {
  final db = ref.watch(databaseProvider);
  return ReadingSessionController(
    db,
    onSessionSaved: () => ref.read(dataRevisionProvider.notifier).state++,
  );
});

class ReadingSessionState {
  final bool isActive;
  final bool isPaused;
  final int? sessionId;
  final DateTime? startTime;
  final DateTime? activeSegmentStartedAt;
  final int pagesAtStart;
  final int currentPage;
  final int bookId;
  final int elapsedSeconds;
  final String readingMode;

  const ReadingSessionState({
    required this.isActive,
    required this.isPaused,
    this.sessionId,
    this.startTime,
    this.activeSegmentStartedAt,
    required this.pagesAtStart,
    required this.currentPage,
    required this.bookId,
    required this.elapsedSeconds,
    this.readingMode = 'digital',
  });

  factory ReadingSessionState.initial(int bookId) => ReadingSessionState(
        isActive: false,
        isPaused: false,
        pagesAtStart: 0,
        currentPage: 0,
        bookId: bookId,
        elapsedSeconds: 0,
        readingMode: 'digital',
      );

  bool get hasSession => sessionId != null;

  ReadingSessionState copyWith({
    bool? isActive,
    bool? isPaused,
    int? sessionId,
    DateTime? startTime,
    DateTime? activeSegmentStartedAt,
    bool clearActiveSegmentStartedAt = false,
    int? pagesAtStart,
    int? currentPage,
    int? bookId,
    int? elapsedSeconds,
    String? readingMode,
  }) {
    return ReadingSessionState(
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      activeSegmentStartedAt: clearActiveSegmentStartedAt
          ? null
          : activeSegmentStartedAt ?? this.activeSegmentStartedAt,
      pagesAtStart: pagesAtStart ?? this.pagesAtStart,
      currentPage: currentPage ?? this.currentPage,
      bookId: bookId ?? this.bookId,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      readingMode: readingMode ?? this.readingMode,
    );
  }
}

class ReadingSessionController extends StateNotifier<ReadingSessionState> {
  final AppDatabase db;
  final void Function()? onSessionSaved;
  Future<void> _sessionReady = Future<void>.value();
  Future<void> _pendingPersist = Future<void>.value();
  Timer? _autosaveTimer;
  bool _isFinishing = false;
  int _lastPersistedPage = 0;

  ReadingSessionController(this.db, {this.onSessionSaved})
      : super(ReadingSessionState.initial(0));

  bool get isActive => state.isActive;
  bool get isPaused => state.isPaused;
  bool get hasSession => state.hasSession;
  int get currentPage => state.currentPage;

  void setBookContext(int bookId, int page) {
    if (state.hasSession || state.bookId == bookId) return;
    state = state.copyWith(bookId: bookId, currentPage: page);
    _lastPersistedPage = page;
  }

  int get elapsedSeconds {
    final segmentStart = state.activeSegmentStartedAt;
    if (!state.isActive || segmentStart == null) return state.elapsedSeconds;
    return state.elapsedSeconds +
        DateTime.now().difference(segmentStart).inSeconds;
  }

  void start(
    int bookId,
    int initialPage, {
    String readingMode = 'digital',
  }) {
    if (state.hasSession) return;
    final now = DateTime.now();
    _lastPersistedPage = initialPage;
    state = ReadingSessionState(
      isActive: true,
      isPaused: false,
      startTime: now,
      activeSegmentStartedAt: now,
      pagesAtStart: initialPage,
      currentPage: initialPage,
      bookId: bookId,
      elapsedSeconds: 0,
      readingMode: readingMode,
    );
    _sessionReady = db
        .insertActiveSession(
      ReadingSessionsCompanion(
        bookId: drift.Value(bookId),
        date: drift.Value(DateFormat('yyyy-MM-dd').format(now)),
        durationSeconds: const drift.Value(0),
        pagesRead: const drift.Value(0),
        startTime: drift.Value(now),
        startingPage: drift.Value(initialPage),
        endingPage: drift.Value(initialPage),
        activeSegmentStartedAt: drift.Value(now),
        readingMode: drift.Value(readingMode),
      ),
    )
        .then((id) {
      if (!state.hasSession && state.bookId == bookId) {
        state = state.copyWith(sessionId: id);
      }
    });
    _startAutosave();
  }

  Future<bool> restore(int bookId, int fallbackPage) async {
    if (state.hasSession) return true;
    final saved = await db.getActiveSession(bookId);
    if (saved == null || saved.startTime == null) return false;

    final isPhysical = saved.readingMode == 'physical';
    final elapsed = (saved.durationSeconds +
            (isPhysical && saved.activeSegmentStartedAt != null
                ? DateTime.now()
                    .difference(saved.activeSegmentStartedAt!)
                    .inSeconds
                : 0))
        .clamp(0, 1 << 31);
    final page = saved.endingPage ?? saved.startingPage ?? fallbackPage;
    state = ReadingSessionState(
      isActive: isPhysical && saved.activeSegmentStartedAt != null,
      isPaused: !isPhysical || saved.activeSegmentStartedAt == null,
      sessionId: saved.id,
      startTime: saved.startTime,
      activeSegmentStartedAt: isPhysical && saved.activeSegmentStartedAt != null
          ? DateTime.now()
          : null,
      pagesAtStart: saved.startingPage ?? fallbackPage,
      currentPage: page,
      bookId: bookId,
      elapsedSeconds: elapsed,
      readingMode: saved.readingMode,
    );
    _lastPersistedPage = page;
    await db.updateSession(
      saved.id,
      isPhysical && saved.activeSegmentStartedAt != null
          ? ReadingSessionsCompanion(
              durationSeconds: drift.Value(elapsed),
              activeSegmentStartedAt: drift.Value(DateTime.now()),
            )
          : const ReadingSessionsCompanion(
              activeSegmentStartedAt: drift.Value(null),
            ),
    );
    if (isPhysical && saved.activeSegmentStartedAt != null) {
      _startAutosave();
    }
    return true;
  }

  Future<void> resume() async {
    if (!state.hasSession || !state.isPaused || _isFinishing) return;
    final now = DateTime.now();
    state = state.copyWith(
      isActive: true,
      isPaused: false,
      activeSegmentStartedAt: now,
    );
    await _sessionReady;
    await db.updateSession(
      state.sessionId!,
      ReadingSessionsCompanion(
        activeSegmentStartedAt: drift.Value(now),
      ),
    );
    _startAutosave();
  }

  Future<void> pause() async {
    if (!state.hasSession || !state.isActive || _isFinishing) return;
    final elapsed = elapsedSeconds;
    state = state.copyWith(
      isActive: false,
      isPaused: true,
      elapsedSeconds: elapsed,
      clearActiveSegmentStartedAt: true,
    );
    await _persistDraft();
    _autosaveTimer?.cancel();
  }

  void recordInteraction() {}

  void updatePage(int page) {
    state = state.copyWith(currentPage: page);
    _queuePersistPage(state.bookId, page);
  }

  void setPhysicalPages(int pages) {
    if (state.readingMode != 'physical') return;
    state = state.copyWith(currentPage: pages < 0 ? 0 : pages);
  }

  void _queuePersistPage(int bookId, int page) {
    if (bookId <= 0 || page <= 0 || page == _lastPersistedPage) return;
    _lastPersistedPage = page;
    _pendingPersist = _pendingPersist.then(
      (_) => db.updateBookLastPage(bookId, page),
    );
  }

  Future<void> persistCurrentPage() async {
    _queuePersistPage(state.bookId, state.currentPage);
    await _pendingPersist;
    if (state.hasSession) await _persistDraft();
  }

  void _startAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(_persistDraft());
    });
  }

  Future<void> _persistDraft() async {
    await _sessionReady;
    // The reader may be disposed while a save is in flight (its dispose
    // fires finish() unawaited); touching state afterwards would throw.
    if (!mounted || !state.hasSession || state.startTime == null) return;
    final elapsed = elapsedSeconds;
    await db.updateSession(
      state.sessionId!,
      ReadingSessionsCompanion(
        durationSeconds: drift.Value(elapsed),
        pagesRead: drift.Value(getPagesRead()),
        endingPage: drift.Value(state.currentPage),
        readingMode: drift.Value(state.readingMode),
        activeSegmentStartedAt: drift.Value(
          state.isActive ? state.activeSegmentStartedAt : null,
        ),
      ),
    );
    if (!mounted) return;
    state = state.copyWith(elapsedSeconds: elapsed);
  }

  int getPagesRead() => state.currentPage <= state.pagesAtStart
      ? 0
      : state.currentPage - state.pagesAtStart;

  Future<void> stopAndSave() => finish();

  Future<void> finish({int? pagesRead, String? note}) async {
    if (_isFinishing) return;
    await _sessionReady;
    if (!mounted || !state.hasSession) return;
    _isFinishing = true;
    _autosaveTimer?.cancel();
    final sessionId = state.sessionId!;
    final bookId = state.bookId;
    final currentPage = state.currentPage;
    final readingMode = state.readingMode;
    final startTime = state.startTime;
    final elapsedAtStart = elapsedSeconds;
    try {
      await _persistDraft();
      await _pendingPersist;
      if (readingMode == 'digital' && bookId > 0 && currentPage > 0) {
        await db.updateBookLastPage(bookId, currentPage);
      }
      final now = DateTime.now();
      final elapsed = mounted ? elapsedSeconds : elapsedAtStart;
      if (elapsed <= 0) {
        await db.deleteSession(sessionId);
        if (!mounted) return;
        state = ReadingSessionState(
          isActive: false,
          isPaused: false,
          startTime: startTime,
          pagesAtStart: currentPage,
          currentPage: currentPage,
          bookId: bookId,
          elapsedSeconds: 0,
        );
        return;
      }
      await db.updateSession(
        sessionId,
        ReadingSessionsCompanion(
          date: drift.Value(DateFormat('yyyy-MM-dd').format(now)),
          durationSeconds: drift.Value(elapsed),
          pagesRead: drift.Value(pagesRead ?? getPagesRead()),
          note: drift.Value(note?.trim().isEmpty == true ? null : note?.trim()),
          readingMode: drift.Value(readingMode),
          endingPage: drift.Value(currentPage),
          endTime: drift.Value(now),
          activeSegmentStartedAt: const drift.Value(null),
        ),
      );
      if (!mounted) return;
      state = ReadingSessionState(
        isActive: false,
        isPaused: false,
        startTime: startTime,
        pagesAtStart: currentPage,
        currentPage: currentPage,
        bookId: bookId,
        elapsedSeconds: elapsed,
      );
      onSessionSaved?.call();
    } finally {
      _isFinishing = false;
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }
}
