import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak_reader/main.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

/// Regression test: submitting the book search used to dispose the
/// dialog's TextEditingController while the dialog was still animating
/// out, throwing "used after being disposed" / "_dependents.isEmpty".
void main() {
  Future<void> pumpLibrary(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.insertBook(BooksCompanion.insert(title: 'Dune'));
    await db.insertBook(BooksCompanion.insert(title: 'Foundation'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);
  }

  Future<void> openSearch(WidgetTester tester) async {
    await tester.ensureVisible(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  Future<void> dismissSearch(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  }

  testWidgets('searching filters the library without an error',
      (tester) async {
    await pumpLibrary(tester);
    await openSearch(tester);

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'dune',
    );
    final searchButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(FilledButton),
    );
    await tester.tap(searchButton);
    await dismissSearch(tester);

    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Foundation'), findsNothing);
  });

  testWidgets('clearing the search restores the library without an error',
      (tester) async {
    await pumpLibrary(tester);
    await openSearch(tester);

    final clearButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    );
    await tester.tap(clearButton);
    await dismissSearch(tester);

    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);
  });
}
