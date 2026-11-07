import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  test('annotations remain isolated by book and are removed with a book',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final firstBook =
        await db.insertBook(BooksCompanion.insert(title: 'First'));
    final secondBook =
        await db.insertBook(BooksCompanion.insert(title: 'Second'));

    await db.addBookmark(
      BookmarksCompanion.insert(bookId: firstBook, pageNumber: 4),
    );
    await db.addBookmark(
      BookmarksCompanion.insert(bookId: secondBook, pageNumber: 4),
    );
    await db.addHighlight(
      HighlightsCompanion.insert(
        bookId: firstBook,
        pageNumber: 4,
        selectedText: 'A saved passage',
        startIndex: 2,
        endIndex: 16,
        left: 10,
        top: 20,
        right: 100,
        bottom: 30,
        colorValue: 0x66FFEB3B,
      ),
    );

    expect((await db.getBookmarks(firstBook)).single.bookId, firstBook);
    expect((await db.getBookmarks(secondBook)).single.bookId, secondBook);
    expect((await db.getHighlights(firstBook)).single.selectedText,
        'A saved passage');
    expect(await db.getHighlights(secondBook), isEmpty);

    await db.deleteBook(firstBook);

    expect(await db.getBookmarks(firstBook), isEmpty);
    expect(await db.getHighlights(firstBook), isEmpty);
    expect((await db.getAllBooks()).single.id, secondBook);
  });

  test('bookmark can be replaced and highlight color can be edited', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    final bookmarkId = await db.addBookmark(
      BookmarksCompanion.insert(
        bookId: bookId,
        pageNumber: 2,
        title: const Value('Chapter two'),
      ),
    );
    final highlightId = await db.addHighlight(
      HighlightsCompanion.insert(
        bookId: bookId,
        pageNumber: 2,
        selectedText: 'Text',
        startIndex: 0,
        endIndex: 4,
        left: 1,
        top: 2,
        right: 3,
        bottom: 4,
        colorValue: 1,
      ),
    );

    expect((await db.getBookmarkForPage(bookId, 2))!.id, bookmarkId);
    await db.updateHighlight(
      highlightId,
      const HighlightsCompanion(colorValue: Value(2)),
    );
    expect((await db.getHighlights(bookId)).single.colorValue, 2);
  });
}
