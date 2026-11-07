import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

void main() {
  test('notes support page links, general notes, search, and editing',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final bookId = await db.insertBook(BooksCompanion.insert(title: 'Book'));
    final createdAt = DateTime(2026, 11, 7, 10);
    final modifiedAt = DateTime(2026, 11, 7, 11);

    final pageNoteId = await db.addNote(
      NotesCompanion.insert(
        bookId: bookId,
        pageNumber: const drift.Value(8),
        content: 'Important argument',
        createdAt: drift.Value(createdAt),
        modifiedAt: drift.Value(createdAt),
      ),
    );
    await db.addNote(
      NotesCompanion.insert(
        bookId: bookId,
        content: 'A general thought',
        createdAt: drift.Value(createdAt),
        modifiedAt: drift.Value(createdAt),
      ),
    );

    expect((await db.getNotes(bookId)).length, 2);
    expect(
        (await db.getNotes(bookId, query: 'argument')).single.id, pageNoteId);
    expect((await db.getNotes(bookId, query: 'missing')), isEmpty);

    await db.updateNote(
      pageNoteId,
      NotesCompanion(
        content: const drift.Value('Revised argument'),
        modifiedAt: drift.Value(modifiedAt),
      ),
    );
    final updated = (await db.getNotes(bookId, query: 'revised')).single;
    expect(updated.content, 'Revised argument');
    expect(updated.pageNumber, 8);
    expect(updated.createdAt, createdAt);
    expect(updated.modifiedAt, modifiedAt);

    await db.deleteNote(pageNoteId);
    expect((await db.getNotes(bookId)).single.pageNumber, isNull);
  });
}
