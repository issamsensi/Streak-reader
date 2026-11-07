import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/features/books/providers/books_providers.dart';
import 'package:streak_reader/src/features/stats/providers/stats_provider.dart';

void main() {
  test('bumping the data revision refreshes library and stats data', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(await container.read(booksListProvider.future), isEmpty);
    expect((await container.read(statsProvider.future)).totalMinutes, 0);

    final bookId = await db.insertBook(
      BooksCompanion.insert(title: 'New book'),
    );
    await db.insertSession(
      ReadingSessionsCompanion.insert(
        bookId: bookId,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        durationSeconds: 600,
        pagesRead: const Value(4),
      ),
    );

    // The reader notifies through this revision after saving a session.
    container.read(dataRevisionProvider.notifier).state++;

    final books = await container.read(booksListProvider.future);
    expect(books.single.title, 'New book');

    final stats = await container.read(statsProvider.future);
    expect(stats.totalMinutes, 10);
    expect(stats.totalPagesRead, 4);
    expect(stats.currentStreak, 1);
  });
}
