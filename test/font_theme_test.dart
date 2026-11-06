import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak_reader/main.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  testWidgets('app themes use Readex Pro body and Alexandria display fonts',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.textTheme.bodyMedium?.fontFamily, 'ReadexPro');
    expect(app.darkTheme?.textTheme.bodyMedium?.fontFamily, 'ReadexPro');
    expect(app.theme?.textTheme.titleLarge?.fontFamily, 'Alexandria');
    expect(app.darkTheme?.textTheme.titleLarge?.fontFamily, 'Alexandria');

    // The rendered library title inherits the display font.
    final context = tester.element(find.text('مكتبة الكتب'));
    expect(
      Theme.of(context).textTheme.titleLarge?.fontFamily,
      'Alexandria',
    );
  });
}
