import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/features/reader/providers/reading_session_provider.dart';

void main() {
  test('stopAndSave persists the page reached before state resets', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    var savedNotifications = 0;
    final controller = ReadingSessionController(
      db,
      onSessionSaved: () => savedNotifications++,
    );

    controller.start(bookId, 5);
    controller.updatePage(12);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await controller.stopAndSave();

    final books = await db.getAllBooks();
    expect(books.single.lastPage, 12);
    expect(controller.state.isActive, isFalse);
    expect(controller.state.currentPage, 12);
    expect(savedNotifications, 1);

    final sessions = await db.getAllSessions();
    expect(sessions, hasLength(1));
    expect(sessions.single.pagesRead, 7);

    // A second call (e.g. idle-save racing dispose) must not duplicate.
    await controller.stopAndSave();
    expect(await db.getAllSessions(), hasLength(1));
    expect(savedNotifications, 1);
  });

  test('page is persisted on page change, before the session ends', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    final controller = ReadingSessionController(db);

    controller.start(bookId, 1);
    controller.updatePage(7);
    // No stopAndSave(): simulates the app being killed while reading.
    await controller.persistCurrentPage();

    final books = await db.getAllBooks();
    expect(books.single.lastPage, 7);
    expect(controller.state.isActive, isTrue);
  });

  test('pause excludes paused time and finish stores session metadata',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    final controller = ReadingSessionController(db);
    controller.start(bookId, 3);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await controller.pause();
    final pausedSeconds = controller.state.elapsedSeconds;

    expect(pausedSeconds, greaterThanOrEqualTo(1));
    expect(await db.getAllSessions(), isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(controller.state.elapsedSeconds, pausedSeconds);

    await controller.resume();
    controller.updatePage(9);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await controller.finish();

    final sessions = await db.getAllSessions();
    expect(sessions, hasLength(1));
    final session = sessions.single;
    expect(session.startTime, isNotNull);
    expect(session.endTime, isNotNull);
    expect(session.startingPage, 3);
    expect(session.endingPage, 9);
    expect(session.pagesRead, 6);
    expect(session.durationSeconds, greaterThanOrEqualTo(pausedSeconds + 1));
  });

  test('restores a persisted active session as paused', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    final first = ReadingSessionController(db);
    first.start(bookId, 1);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await first.persistCurrentPage();

    final restored = ReadingSessionController(db);
    expect(await restored.restore(bookId, 1), isTrue);
    expect(restored.isActive, isFalse);
    expect(restored.isPaused, isTrue);
    expect(restored.hasSession, isTrue);
    await restored.finish();

    expect(await db.getAllSessions(), hasLength(1));
  });

  test('physical sessions persist mode, optional pages, and notes', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Printed'));
    final controller = ReadingSessionController(db);
    controller.start(bookId, 0, readingMode: 'physical');
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await controller.finish(pagesRead: 12, note: 'Great chapter');

    final session = (await db.getSessionsForBook(bookId)).single;
    expect(session.readingMode, 'physical');
    expect(session.pagesRead, 12);
    expect(session.note, 'Great chapter');
    final book = (await db.getAllBooks()).single;
    expect(book.lastPage, 0);
  });

  test('physical active segments continue across controller restore', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Printed'));
    final first = ReadingSessionController(db);
    first.start(bookId, 0, readingMode: 'physical');
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await first.persistCurrentPage();

    final restored = ReadingSessionController(db);
    expect(await restored.restore(bookId, 0), isTrue);
    expect(restored.isActive, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await restored.finish();

    final session = (await db.getSessionsForBook(bookId)).single;
    expect(session.readingMode, 'physical');
    expect(session.durationSeconds, greaterThanOrEqualTo(2));
  });
}
