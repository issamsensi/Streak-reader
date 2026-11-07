import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/data/repositories/books_repository_impl.dart';

void main() {
  late AppDatabase db;
  late BooksRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BooksRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('markCompleted toggles the completed flag', () async {
    final id = await repo.addBook(title: 'Book');

    await repo.markCompleted(id, true);
    expect((await repo.getAllBooks()).single.isCompleted, isTrue);

    await repo.markCompleted(id, false);
    expect((await repo.getAllBooks()).single.isCompleted, isFalse);
  });

  test('deleteBook removes the book and all of its reading sessions', () async {
    final id = await repo.addBook(title: 'Book to delete');
    final otherId = await repo.addBook(title: 'Book to keep');
    await db.insertSession(
      ReadingSessionsCompanion.insert(
        bookId: id,
        date: '2026-11-07',
        durationSeconds: 900,
      ),
    );
    await db.insertSession(
      ReadingSessionsCompanion.insert(
        bookId: otherId,
        date: '2026-11-07',
        durationSeconds: 600,
      ),
    );

    await repo.deleteBook(id);

    final books = await repo.getAllBooks();
    expect(books.map((b) => b.id), [otherId]);

    final sessions = await db.getAllSessions();
    expect(sessions, hasLength(1));
    expect(sessions.single.bookId, otherId);
    expect(sessions.single.durationSeconds, 600);
  });

  test('updateTitle does not affect other book fields', () async {
    final id = await repo.addBook(
      title: 'Old title',
      filePath: '/tmp/book.pdf',
      fileName: 'book.pdf',
      fileSize: 42,
    );
    await repo.markCompleted(id, true);
    await repo.updateLastPage(id, 12);

    await repo.updateTitle(id, 'New title');

    final book = (await repo.getAllBooks()).single;
    expect(book.title, 'New title');
    expect(book.filePath, '/tmp/book.pdf');
    expect(book.fileName, 'book.pdf');
    expect(book.fileSize, 42);
    expect(book.lastPage, 12);
    expect(book.isCompleted, isTrue);
  });

  test('updateBookFile can replace an existing PDF', () async {
    final id = await repo.addBook(
      title: 'Book',
      filePath: '/tmp/old.pdf',
      fileName: 'old.pdf',
    );

    await repo.updateBookFile(
      id,
      filePath: '/tmp/new.pdf',
      fileName: 'new.pdf',
      fileSize: 99,
    );

    final book = (await repo.getAllBooks()).single;
    expect(book.filePath, '/tmp/new.pdf');
    expect(book.fileName, 'new.pdf');
    expect(book.fileSize, 99);
  });
}
