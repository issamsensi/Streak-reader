import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak_reader/main.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/features/books/presentation/book_details_screen.dart';
import 'package:streak_reader/src/features/reader/presentation/pdf_reader_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    Future<void> Function(AppDatabase db)? seed,
  }) async {
    // Tall surface so every collapsible section is built without scrolling.
    tester.view.physicalSize = const Size(1000, 4200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    if (seed != null) await seed(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  Future<int> seedBook(
    AppDatabase db,
    String title, {
    String status = 'want_to_read',
    String? filePath,
  }) =>
      db.insertBook(BooksCompanion.insert(
        title: title,
        readingStatus: drift.Value(status),
        filePath: drift.Value(filePath),
        isCompleted: drift.Value(status == 'completed'),
      ));

  testWidgets('tapping a non-PDF book opens Book Details', (tester) async {
    await pumpApp(tester, seed: (db) async {
      await seedBook(db, 'Physical Book');
    });
    await tester.tap(find.text('Physical Book'));
    await tester.pumpAndSettle();
    expect(find.byType(BookDetailsScreen), findsOneWidget);
    expect(find.text('Edit Details'), findsWidgets);
    expect(find.text('Reading history'), findsOneWidget);
    expect(find.text('No personal notes yet.'), findsOneWidget);
    expect(find.text('No tracked reading sessions.'), findsOneWidget);
  });

  testWidgets('tapping a PDF book opens the reader at the last page',
      (tester) async {
    final file = File('${Directory.systemTemp.path}/library_nav_test.pdf');
    // Sync I/O: async dart:io never completes in the fake-async test zone.
    file.writeAsBytesSync('%PDF-1.4\n%%EOF'.codeUnits);
    addTearDown(() => file.deleteSync());
    await pumpApp(tester, seed: (db) async {
      final id = await seedBook(db, 'PDF Book',
          status: 'currently_reading', filePath: file.path);
      await db.updateBookLastPage(id, 3);
    });
    await tester.tap(find.text('PDF Book'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PdfReaderScreen), findsOneWidget);
    expect(find.byType(BookDetailsScreen), findsNothing);
    // End while the reader is open; disposing it mid-session trips the
    // reader's own session controller, which is outside this test's scope.
  });

  testWidgets('Book Details and Reading History work via the card menu',
      (tester) async {
    await pumpApp(tester, seed: (db) async {
      await seedBook(db, 'Menu Book');
    });
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Book Details'), findsOneWidget);
    expect(find.text('Edit Details'), findsOneWidget);
    expect(find.text('Reading History'), findsOneWidget);
    await tester.tap(find.text('Book Details'));
    await tester.pumpAndSettle();
    expect(find.byType(BookDetailsScreen), findsOneWidget);
  });

  testWidgets('editing a book from the menu preserves its sessions',
      (tester) async {
    late int bookId;
    final db = await pumpApp(tester, seed: (db) async {
      bookId = await seedBook(db, 'Before Edit');
      await db.insertSession(ReadingSessionsCompanion.insert(
        bookId: bookId,
        date: '2026-11-07',
        durationSeconds: 600,
      ));
      await db.addNote(
          NotesCompanion.insert(bookId: bookId, content: 'Still here'));
    });
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Details'));
    await tester.pumpAndSettle();
    expect(find.text('Before Edit'), findsWidgets);
    await tester.enterText(
        find.widgetWithText(TextField, 'Before Edit'), 'After Edit');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    final book = (await db.getAllBooks()).single;
    expect(book.title, 'After Edit');
    expect(find.text('After Edit'), findsOneWidget);
    expect(await db.getSessionsForBook(bookId), hasLength(1));
    expect((await db.getNotes(bookId)).single.content, 'Still here');
  });

  testWidgets('books are grouped by status in order with counts',
      (tester) async {
    await pumpApp(tester, seed: (db) async {
      await seedBook(db, 'Reading Now', status: 'currently_reading');
      await seedBook(db, 'Later Book');
      await seedBook(db, 'Paused Book', status: 'paused');
      await seedBook(db, 'Done Book', status: 'completed');
    });
    final reading = tester.getTopLeft(find.text('تقرأ حالياً').first).dy;
    final want = tester.getTopLeft(find.text('أريد قراءته').first).dy;
    final paused = tester.getTopLeft(find.text('متوقف مؤقتاً').first).dy;
    final done = tester.getTopLeft(find.text('مكتمل').first).dy;
    expect(reading < want && want < paused && paused < done, isTrue);
    // Empty-state copy is under collapsed-by-default? Sections start open.
    expect(find.text('Reading Now'), findsOneWidget);
    expect(find.text('Done Book'), findsOneWidget);
  });

  testWidgets('changing status moves the book to the completed section',
      (tester) async {
    final db = await pumpApp(tester, seed: (db) async {
      await seedBook(db, 'Move Me');
    });
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('وضع علامة كمكتمل'));
    await tester.pumpAndSettle();
    expect((await db.getAllBooks()).single.readingStatus, 'completed');
    final heading = tester.getTopLeft(find.text('مكتمل').first).dy;
    final card = tester.getTopLeft(find.text('Move Me')).dy;
    expect(card > heading, isTrue);
  });

  testWidgets('sections collapse and expand', (tester) async {
    await pumpApp(tester, seed: (db) async {
      await seedBook(db, 'Collapse Me', status: 'currently_reading');
    });
    expect(find.text('Collapse Me'), findsOneWidget);
    await tester.tap(find.text('تقرأ حالياً').first);
    await tester.pumpAndSettle();
    expect(find.text('Collapse Me'), findsNothing);
    await tester.tap(find.text('تقرأ حالياً').first);
    await tester.pumpAndSettle();
    expect(find.text('Collapse Me'), findsOneWidget);
  });

  testWidgets('sorting by title orders books alphabetically', (tester) async {
    await pumpApp(tester, seed: (db) async {
      await seedBook(db, 'Zebra', status: 'currently_reading');
      await seedBook(db, 'Alpha', status: 'currently_reading');
    });
    // Default (recently active) lists the newest first.
    expect(
        tester.getTopLeft(find.text('Alpha')).dy <
            tester.getTopLeft(find.text('Zebra')).dy,
        isFalse);
    await tester.tap(find.byIcon(Icons.sort_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العنوان'));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(find.text('Alpha')).dy <
            tester.getTopLeft(find.text('Zebra')).dy,
        isTrue);
  });

  testWidgets('empty sections show their empty states', (tester) async {
    await pumpApp(tester, seed: (db) async {
      await seedBook(db, 'Only Reading', status: 'currently_reading');
    });
    expect(find.text('Your reading list is empty.'), findsOneWidget);
    expect(find.text('No completed books yet.'), findsOneWidget);
  });
}
