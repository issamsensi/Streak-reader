import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/features/reader/providers/reading_session_provider.dart';

void main() {
  test('stopAndSave persists the page reached before state resets', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    final controller = ReadingSessionController(db);

    controller.start(bookId, 5);
    controller.updatePage(12);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await controller.stopAndSave();

    final books = await db.getAllBooks();
    expect(books.single.lastPage, 12);
    expect(controller.state.isActive, isFalse);
    expect(controller.state.currentPage, 12);

    final sessions = await db.getAllSessions();
    expect(sessions, hasLength(1));
    expect(sessions.single.pagesRead, 7);

    // A second call (e.g. idle-save racing dispose) must not duplicate.
    await controller.stopAndSave();
    expect(await db.getAllSessions(), hasLength(1));
  });
}
