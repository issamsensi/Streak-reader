import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak_reader/main.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    Future<void> Function(AppDatabase db)? seed,
  }) async {
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

  testWidgets('a book can be marked completed and later deleted',
      (tester) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await db.insertBook(BooksCompanion.insert(title: 'كتاب للاختبار'));
      },
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('وضع علامة كمكتمل'));
    await tester.pumpAndSettle();

    expect((await db.getAllBooks()).single.isCompleted, isTrue);
    expect(find.text('مكتمل'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف الكتاب'));
    await tester.pumpAndSettle();

    expect(find.text('حذف الكتاب؟'), findsOneWidget);
    expect(find.textContaining('كتاب للاختبار'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'حذف'));
    await tester.pumpAndSettle();

    expect(await db.getAllBooks(), isEmpty);
    expect(find.textContaining('لا توجد كتب بعد'), findsOneWidget);
  });

  testWidgets('deleting from the menu preserves other books', (tester) async {
    late int keepId;
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await db.insertBook(BooksCompanion.insert(title: 'كتاب أول'));
        keepId = await db.insertBook(
          BooksCompanion.insert(title: 'كتاب ثانٍ'),
        );
      },
    );

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف الكتاب'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'حذف'));
    await tester.pumpAndSettle();

    final books = await db.getAllBooks();
    expect(books.map((b) => b.id), [keepId]);
    expect(find.text('كتاب ثانٍ'), findsOneWidget);
    expect(find.text('كتاب أول'), findsNothing);
  });

  testWidgets('add book validates the title and saves a valid one',
      (tester) async {
    final db = await pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('يرجى إدخال عنوان الكتاب.'), findsOneWidget);
    expect(await db.getAllBooks(), isEmpty);

    await tester.enterText(find.byType(TextField), 'كتاب جديد');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    final books = await db.getAllBooks();
    expect(books, hasLength(1));
    expect(books.single.title, 'كتاب جديد');
    expect(find.text('كتاب جديد'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
