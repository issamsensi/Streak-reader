import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/duration_units.dart';
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

  /// Completed active time before [activeSegmentStartedAt], in milliseconds.
  final int elapsedMilliseconds;
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
    required this.elapsedMilliseconds,
    this.readingMode = 'digital',
  });

  factory ReadingSessionState.initial(int bookId) => ReadingSessionState(
        isActive: false,
        isPaused: false,
        pagesAtStart: 0,
        currentPage: 0,
        bookId: bookId,
        elapsedMilliseconds: 0,
        readingMode: 'digital',
      );

  bool get hasSession => sessionId != null;

  int get elapsedSeconds =>
      DurationUnits.millisecondsToSeconds(elapsedMilliseconds);

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
    int? elapsedMilliseconds,
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
      elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
      readingMode: readingMode ?? this.readingMode,
    );
  }
}

class ReadingSessionController extends StateNotifier<ReadingSessionState> {
  final AppDatabase db;
  final void Function()? onSessionSaved;

  /// Injectable clock so elapsed-time behaviour can be tested without waiting.
  final DateTime Function() _now;

  Future<void> _sessionReady = Future<void>.value();
  Future<void> _pendingPageWrite = Future<void>.value();
  Future<void> _pendingSessionWrite = Future<void>.value();
  Timer? _autosaveTimer;
  bool _isFinishing = false;
  int _lastPersistedPage = 0;

  ReadingSessionController(
    this.db, {
    this.onSessionSaved,
    DateTime Function()? now,
  })  : _now = now ?? DateTime.now,
        super(ReadingSessionState.initial(0));

  bool get isActive => state.isActive;
  bool get isPaused => state.isPaused;
  bool get hasSession => state.hasSession;
  int get currentPage => state.currentPage;

  void setBookContext(int bookId, int page) {
    if (state.hasSession || state.bookId == bookId) return;
    state = state.copyWith(bookId: bookId, currentPage: page);
    _lastPersistedPage = page;
  }

  int get elapsedMilliseconds => _elapsedMillisecondsAt(_now());

  int get elapsedSeconds =>
      DurationUnits.millisecondsToSeconds(elapsedMilliseconds);

  /// Timestamp-derived elapsed time. The accumulated value is only advanced
  /// when a checkpoint is written; reading the getter never mutates anything.
  int _elapsedMillisecondsAt(DateTime now) {
    final segmentStart = state.activeSegmentStartedAt;
    if (!state.isActive || segmentStart == null) {
      return state.elapsedMilliseconds;
    }
    final segment = now.difference(segmentStart).inMilliseconds;
    return state.elapsedMilliseconds + (segment > 0 ? segment : 0);
  }

  void start(
    int bookId,
    int initialPage, {
    String readingMode = 'digital',
  }) {
    if (state.hasSession) return;
    final now = _now();
    _lastPersistedPage = initialPage;
    state = ReadingSessionState(
      isActive: true,
      isPaused: false,
      startTime: now,
      activeSegmentStartedAt: now,
      pagesAtStart: initialPage,
      currentPage: initialPage,
      bookId: bookId,
      elapsedMilliseconds: 0,
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
      if (mounted && !state.hasSession && state.bookId == bookId) {
        state = state.copyWith(sessionId: id);
      }
    });
    _startAutosave();
  }

  Future<bool> restore(int bookId, int fallbackPage) async {
    if (state.hasSession) return true;
    final saved = await db.getActiveSession(bookId);
    if (saved == null || saved.startTime == null) return false;

    final now = _now();
    final wallClockMilliseconds =
        now.difference(saved.startTime!).inMilliseconds;
    final maxMilliseconds =
        wallClockMilliseconds > 0 ? wallClockMilliseconds : 0;
    final persistedMilliseconds =
        DurationUnits.secondsToMilliseconds(saved.durationSeconds);
    // An in-progress row may have been written by the old, inflating timer.
    // It can never represent more than the wall-clock lifetime of the session.
    final accumulatedMilliseconds = persistedMilliseconds > maxMilliseconds
        ? maxMilliseconds
        : persistedMilliseconds;

    final isPhysical = saved.readingMode == 'physical';
    final hasActiveSegment = saved.activeSegmentStartedAt != null;
    final continuesPhysicalSegment = isPhysical && hasActiveSegment;
    final segmentElapsed = continuesPhysicalSegment
        ? now.difference(saved.activeSegmentStartedAt!).inMilliseconds
        : 0;
    final activeElapsed =
        accumulatedMilliseconds + (segmentElapsed > 0 ? segmentElapsed : 0);
    final elapsedMilliseconds =
        activeElapsed > maxMilliseconds ? maxMilliseconds : activeElapsed;

    final page = saved.endingPage ?? saved.startingPage ?? fallbackPage;
    state = ReadingSessionState(
      isActive: continuesPhysicalSegment,
      isPaused: !continuesPhysicalSegment,
      sessionId: saved.id,
      startTime: saved.startTime,
      activeSegmentStartedAt: continuesPhysicalSegment ? now : null,
      pagesAtStart: saved.startingPage ?? fallbackPage,
      currentPage: page,
      bookId: bookId,
      elapsedMilliseconds: elapsedMilliseconds,
      readingMode: saved.readingMode,
    );
    _lastPersistedPage = page;
    await db.updateSession(
      saved.id,
      ReadingSessionsCompanion(
        durationSeconds: drift.Value(
          DurationUnits.millisecondsToSeconds(elapsedMilliseconds),
        ),
        activeSegmentStartedAt: continuesPhysicalSegment
            ? drift.Value(now)
            : const drift.Value(null),
      ),
    );
    if (continuesPhysicalSegment) {
      _startAutosave();
    }
    return true;
  }

  Future<void> resume() async {
    if (_isFinishing) return;
    await _sessionReady;
    if (!mounted || !state.hasSession || !state.isPaused || _isFinishing) {
      return;
    }
    final now = _now();
    state = state.copyWith(
      isActive: true,
      isPaused: false,
      activeSegmentStartedAt: now,
    );
    await _enqueueSessionWrite(() async {
      if (!mounted || !state.hasSession) return;
      await db.updateSession(
        state.sessionId!,
        ReadingSessionsCompanion(
          activeSegmentStartedAt: drift.Value(now),
        ),
      );
    });
    _startAutosave();
  }

  Future<void> pause() async {
    if (_isFinishing) return;
    await _sessionReady;
    if (!mounted || !state.hasSession || !state.isActive || _isFinishing) {
      return;
    }
    final now = _now();
    final elapsed = _elapsedMillisecondsAt(now);
    state = state.copyWith(
      isActive: false,
      isPaused: true,
      elapsedMilliseconds: elapsed,
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
    _pendingPageWrite = _pendingPageWrite.then(
      (_) => db.updateBookLastPage(bookId, page),
    );
  }

  Future<void> persistCurrentPage() async {
    _queuePersistPage(state.bookId, state.currentPage);
    await _pendingPageWrite;
    await _sessionReady;
    if (state.hasSession) await _persistDraft();
  }

  void _startAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(_persistDraft());
    });
  }

  Future<void> _enqueueSessionWrite(Future<void> Function() write) {
    final next = _pendingSessionWrite.then((_) => write());
    // Keep later writes running even if one write fails.
    _pendingSessionWrite = next.catchError((Object _) {});
    return next;
  }

  Future<void> _persistDraft() {
    return _enqueueSessionWrite(_writeDraft);
  }

  Future<void> _writeDraft() async {
    await _sessionReady;
    // The reader may be disposed while a save is in flight (its dispose
    // fires finish() unawaited); touching state afterwards would throw.
    if (!mounted || !state.hasSession || state.startTime == null) return;

    final sessionId = state.sessionId!;
    final segmentAtStart = state.activeSegmentStartedAt;
    final wasActive = state.isActive;
    final now = _now();
    final elapsedMilliseconds = _elapsedMillisecondsAt(now);
    final nextSegmentStart = wasActive ? now : null;
    final pagesRead = getPagesRead();
    final currentPage = state.currentPage;
    final readingMode = state.readingMode;

    await db.updateSession(
      sessionId,
      ReadingSessionsCompanion(
        durationSeconds: drift.Value(
          DurationUnits.millisecondsToSeconds(elapsedMilliseconds),
        ),
        pagesRead: drift.Value(pagesRead),
        endingPage: drift.Value(currentPage),
        readingMode: drift.Value(readingMode),
        activeSegmentStartedAt: drift.Value(nextSegmentStart),
      ),
    );

    if (!mounted || state.sessionId != sessionId) return;
    // A pause/resume/finish may have happened while the write was in flight.
    // Never overwrite that newer state with this checkpoint.
    if (state.isActive != wasActive ||
        state.activeSegmentStartedAt != segmentAtStart) {
      return;
    }

    // Advance the checkpoint. Without this, the next read would add the whole
    // active segment again and every autosave would compound the total.
    state = state.copyWith(
      elapsedMilliseconds: elapsedMilliseconds,
      activeSegmentStartedAt: nextSegmentStart,
      clearActiveSegmentStartedAt: !wasActive,
    );
  }

  int getPagesRead() => state.currentPage <= state.pagesAtStart
      ? 0
      : state.currentPage - state.pagesAtStart;

  Future<void> stopAndSave() => finish();

  Future<void> finish({int? pagesRead, String? note}) async {
    if (_isFinishing) return;
    _isFinishing = true;
    try {
      await _sessionReady;
      if (!mounted || !state.hasSession) return;
      _autosaveTimer?.cancel();

      final sessionId = state.sessionId!;
      final bookId = state.bookId;
      final currentPage = state.currentPage;
      final readingMode = state.readingMode;
      final startTime = state.startTime;
      final finalPages = pagesRead ?? getPagesRead();

      await _pendingPageWrite;
      await _pendingSessionWrite;

      final now = _now();
      final elapsedMilliseconds = _elapsedMillisecondsAt(now);
      final elapsedSeconds =
          DurationUnits.millisecondsToSeconds(elapsedMilliseconds);

      if (elapsedSeconds <= 0) {
        await db.deleteSession(sessionId);
        if (!mounted) return;
        state = ReadingSessionState(
          isActive: false,
          isPaused: false,
          startTime: startTime,
          pagesAtStart: currentPage,
          currentPage: currentPage,
          bookId: bookId,
          elapsedMilliseconds: 0,
          readingMode: readingMode,
        );
        return;
      }

      await db.updateSession(
        sessionId,
        ReadingSessionsCompanion(
          date: drift.Value(DateFormat('yyyy-MM-dd').format(now)),
          durationSeconds: drift.Value(elapsedSeconds),
          pagesRead: drift.Value(finalPages),
          note: drift.Value(note?.trim().isEmpty == true ? null : note?.trim()),
          readingMode: drift.Value(readingMode),
          endingPage: drift.Value(currentPage),
          endTime: drift.Value(now),
          activeSegmentStartedAt: const drift.Value(null),
        ),
      );
      if (readingMode == 'digital' && bookId > 0 && currentPage > 0) {
        await db.updateBookLastPage(bookId, currentPage);
      }
      if (!mounted) return;
      state = ReadingSessionState(
        isActive: false,
        isPaused: false,
        startTime: startTime,
        pagesAtStart: currentPage,
        currentPage: currentPage,
        bookId: bookId,
        elapsedMilliseconds: elapsedMilliseconds,
        readingMode: readingMode,
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
