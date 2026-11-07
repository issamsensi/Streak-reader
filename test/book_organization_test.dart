import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  test('book status and collection assignments persist independently',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final bookId = await db.insertBook(
      BooksCompanion.insert(
        title: 'Organized book',
        author: const drift.Value('Author'),
        totalPages: const drift.Value(200),
      ),
    );
    final firstCollection = await db.addCollection(
      CollectionsCompanion.insert(
        name: 'Favorites',
        description: const drift.Value('Books to revisit'),
      ),
    );
    final secondCollection =
        await db.addCollection(CollectionsCompanion.insert(name: 'Classics'));

    await db.updateBookStatus(bookId, 'paused');
    await db.setBookCollections(bookId, [firstCollection, secondCollection]);

    final book = (await db.getAllBooks()).single;
    expect(book.readingStatus, 'paused');
    expect(book.isCompleted, isFalse);
    expect(book.author, 'Author');
    expect(book.totalPages, 200);
    expect(
      await db.getBookCollectionIds(bookId),
      containsAll([firstCollection, secondCollection]),
    );
    expect(await db.countBooksInCollection(firstCollection), 1);
  });

  test('completed status is explicit and can be changed without page changes',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final bookId = await db.insertBook(
      BooksCompanion.insert(title: 'Progress', lastPage: const drift.Value(80)),
    );

    await db.updateBookStatus(bookId, 'completed');
    expect((await db.getAllBooks()).single.isCompleted, isTrue);
    expect((await db.getAllBooks()).single.lastPage, 80);

    await db.updateBookStatus(bookId, 'currently_reading');
    final updated = (await db.getAllBooks()).single;
    expect(updated.isCompleted, isFalse);
    expect(updated.readingStatus, 'currently_reading');
    expect(updated.lastPage, 80);
  });
}
