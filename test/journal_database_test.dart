import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  test('journal entries support association, search, chronology, and editing',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final firstBook =
        await db.insertBook(BooksCompanion.insert(title: 'First book'));
    final secondBook =
        await db.insertBook(BooksCompanion.insert(title: 'Second book'));
    final older = DateTime(2026, 11, 6);
    final newer = DateTime(2026, 11, 7);

    final olderId = await db.addJournalEntry(
      JournalEntriesCompanion.insert(
        title: 'A quiet thought',
        reflection: 'The opening idea stayed with me.',
        bookId: drift.Value(firstBook),
        createdAt: drift.Value(older),
        modifiedAt: drift.Value(older),
      ),
    );
    await db.addJournalEntry(
      JournalEntriesCompanion.insert(
        title: 'A new connection',
        reflection: 'This reminded me of another book.',
        bookId: drift.Value(secondBook),
        pageNumber: const drift.Value(12),
        createdAt: drift.Value(newer),
        modifiedAt: drift.Value(newer),
      ),
    );

    final entries = await db.getJournalEntries();
    expect(entries.map((entry) => entry.createdAt), [newer, older]);
    expect(
        (await db.getJournalEntries(bookId: secondBook)).single.pageNumber, 12);
    expect(
      (await db.getJournalEntries(query: 'opening')).single.id,
      olderId,
    );

    final edited = DateTime(2026, 11, 8);
    await db.updateJournalEntry(
      olderId,
      JournalEntriesCompanion(
        title: const drift.Value('Edited thought'),
        reflection: const drift.Value('A revised reflection.'),
        modifiedAt: drift.Value(edited),
      ),
    );
    final updated = (await db.getJournalEntries()).last;
    expect(updated.title, 'Edited thought');
    expect(updated.createdAt, older);
    expect(updated.modifiedAt, edited);

    await db.deleteJournalEntry(olderId);
    expect((await db.getJournalEntries()).single.id, isNot(olderId));
  });

  test('deleting a book removes associated journal entries', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final bookId =
        await db.insertBook(BooksCompanion.insert(title: 'Journal book'));
    await db.addJournalEntry(
      JournalEntriesCompanion.insert(
        title: 'Reflection',
        reflection: 'Content',
        bookId: drift.Value(bookId),
      ),
    );

    await db.deleteBook(bookId);

    expect(await db.getJournalEntries(), isEmpty);
  });
}
