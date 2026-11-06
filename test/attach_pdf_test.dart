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

  testWidgets('wishlist book menu and tap dialog offer adding a PDF',
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

    // Tapping the book offers to add a PDF instead of only dismissing.
    await tester.tap(find.text('Wishlist book'));
    await tester.pumpAndSettle();
    expect(find.text('لا يوجد ملف'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'إضافة ملف PDF'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    // The overflow menu offers it too.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('إضافة ملف PDF'), findsOneWidget);
  });
}
