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
import 'package:streak_reader/src/features/reader/presentation/pdf_reader_screen.dart';

/// Regression test: cancelling a reader dialog used to dispose its
/// TextEditingController while the dialog was still animating out, which
/// threw "used after being disposed" / "_dependents.isEmpty is not true"
/// and knocked the PDF viewer back to page 1.
void main() {
  Future<({AppDatabase db, int bookId})> openReader(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final file = File('${Directory.systemTemp.path}/note_dialog_test.pdf');
    file.writeAsBytesSync('%PDF-1.4\n%%EOF'.codeUnits);
    addTearDown(() => file.deleteSync());
    final bookId = await db.insertBook(BooksCompanion.insert(
      title: 'Dialog Book',
      readingStatus: const drift.Value('currently_reading'),
      filePath: drift.Value(file.path),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Dialog Book'));
    await tester.tap(find.text('Dialog Book'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PdfReaderScreen), findsOneWidget);
    return (db: db, bookId: bookId);
  }

  Future<void> cancelOpenDialog(WidgetTester tester) async {
    expect(find.byType(AlertDialog), findsOneWidget);
    final cancel = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    );
    expect(cancel, findsOneWidget);
    await tester.tap(cancel);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
    // The reader survived the dismissal.
    expect(find.byType(PdfReaderScreen), findsOneWidget);
  }

  testWidgets('cancelling a new note saves nothing and throws nothing',
      (tester) async {
    final (:db, :bookId) = await openReader(tester);

    await tester.tap(find.byIcon(Icons.note_add_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await cancelOpenDialog(tester);

    expect(await db.getNotes(bookId), isEmpty);
  });

  testWidgets('saving a new note still stores it', (tester) async {
    final (:db, :bookId) = await openReader(tester);

    await tester.tap(find.byIcon(Icons.note_add_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'A kept note',
    );
    final save = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(FilledButton),
    );
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);

    final notes = await db.getNotes(bookId);
    expect(notes, hasLength(1));
    expect(notes.single.content, 'A kept note');
  });

  testWidgets('cancelling the bookmark title dialog throws nothing',
      (tester) async {
    final (:db, :bookId) = await openReader(tester);

    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await cancelOpenDialog(tester);

    expect(await db.getBookmarks(bookId), isEmpty);
  });
}
