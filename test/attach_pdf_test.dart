import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak_reader/main.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/data/repositories/books_repository_impl.dart';

void main() {
  test('updateBookFile attaches a PDF to a book that had none', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = BooksRepositoryImpl(db);

    final id = await repo.addBook(title: 'Wishlist book');
    var books = await repo.getAllBooks();
    expect(books.single.filePath, isNull);

    await repo.updateBookFile(
      id,
      filePath: '/tmp/book.pdf',
      fileName: 'book.pdf',
      fileSize: 1234,
    );

    books = await repo.getAllBooks();
    expect(books.single.filePath, '/tmp/book.pdf');
    expect(books.single.fileName, 'book.pdf');
    expect(books.single.fileSize, 1234);
    expect(books.single.title, 'Wishlist book');
  });

  test('updateBookFile stores a counted total and keeps it when uncounted',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = BooksRepositoryImpl(db);

    final id = await repo.addBook(title: 'Book', totalPages: 10);

    // Replacing the PDF with a counted one replaces the total.
    await repo.updateBookFile(
      id,
      filePath: '/tmp/new.pdf',
      fileName: 'new.pdf',
      totalPages: 42,
    );
    var book = (await repo.getAllBooks()).single;
    expect(book.totalPages, 42);

    // A failed count passes no total, so the stored one survives.
    await repo.updateBookFile(id, filePath: '/tmp/other.pdf');
    book = (await repo.getAllBooks()).single;
    expect(book.filePath, '/tmp/other.pdf');
    expect(book.totalPages, 42);
  });

  test('fillTotalPagesIfMissing only fills a missing total', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = BooksRepositoryImpl(db);

    final missing = await repo.addBook(title: 'Legacy');
    await repo.fillTotalPagesIfMissing(missing, 120);
    expect((await repo.getAllBooks()).single.totalPages, 120);

    // A manual total is never overwritten by the reader backfill.
    final manual = await repo.addBook(title: 'Manual', totalPages: 300);
    await repo.fillTotalPagesIfMissing(manual, 280);
    final books = await repo.getAllBooks();
    expect(books.firstWhere((b) => b.id == manual).totalPages, 300);

    // Invalid counts and unknown books are no-ops.
    await repo.fillTotalPagesIfMissing(missing, 0);
    await repo.fillTotalPagesIfMissing(9999, 50);
    expect((await repo.getAllBooks()).first.totalPages, 120);
  });

  testWidgets('wishlist book tap opens details and menu offers adding a PDF',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.insertBook(BooksCompanion.insert(title: 'Wishlist book'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Wishlist book'), findsOneWidget);

    // Tapping a book without a PDF opens its Book Details page.
    await tester.ensureVisible(find.text('Wishlist book'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wishlist book'));
    await tester.pumpAndSettle();
    expect(find.text('Book details'), findsOneWidget);
    expect(find.text('Edit Details'), findsWidgets);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    // The overflow menu offers it too.
    await tester.ensureVisible(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('إضافة ملف PDF'), findsOneWidget);
  });
}
