import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';

/// Every table the current app expects, including the columns Drift generates
/// for them. The migration test creates a database as an older app version
/// would have left it, then opens it with the current [AppDatabase] and checks
/// that the upgrade produces exactly this schema.
const _allColumns = <String, Set<String>>{
  'books': {
    'id',
    'sync_id',
    'title',
    'author',
    'total_pages',
    'file_path',
    'file_name',
    'file_size',
    'last_page',
    'is_completed',
    'reading_status',
    'cover_path',
    'description',
    'completion_date',
    'added_as_previously_completed',
    'created_at',
  },
  'reading_sessions': {
    'id',
    'sync_id',
    'book_id',
    'date',
    'duration_seconds',
    'pages_read',
    'start_time',
    'end_time',
    'starting_page',
    'ending_page',
    'active_segment_started_at',
    'reading_mode',
    'note',
  },
  'bookmarks': {'id', 'book_id', 'page_number', 'title', 'created_at'},
  'highlights': {
    'id',
    'book_id',
    'page_number',
    'selected_text',
    'start_index',
    'end_index',
    'left',
    'top',
    'right',
    'bottom',
    'color_value',
    'created_at',
  },
  'notes': {'id', 'book_id', 'page_number', 'content', 'created_at', 'modified_at'},
  'journal_entries': {
    'id',
    'book_id',
    'page_number',
    'title',
    'reflection',
    'created_at',
    'modified_at',
  },
  'collections': {'id', 'name', 'description', 'created_at'},
  'book_collections': {'book_id', 'collection_id'},
  'achievement_unlocks': {'achievement_id', 'unlocked_at'},
  'sync_records': {
    'id',
    'record_key',
    'entity_type',
    'payload',
    'updated_at',
    'deleted',
    'pending',
  },
  'book_completions': {'id', 'book_id', 'completed_at', 'historical'},
};

/// Table name -> schema version that introduced it.
const _introducedAt = <String, int>{
  'bookmarks': 3,
  'highlights': 3,
  'notes': 4,
  'journal_entries': 5,
  'collections': 6,
  'book_collections': 6,
  'achievement_unlocks': 7,
  'sync_records': 8,
  'book_completions': 10,
};

/// Schema that `books` had at [version]. Columns introduced later are omitted
/// so `ALTER TABLE ... ADD COLUMN` has to add them during the upgrade.
String _booksDdl(int version) {
  final columns = <String>[
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT',
    if (version >= 12) '"sync_id" TEXT',
    '"title" TEXT NOT NULL',
    if (version >= 6) '"author" TEXT',
    if (version >= 6) '"total_pages" INTEGER',
    '"file_path" TEXT',
    '"file_name" TEXT',
    '"file_size" INTEGER',
    '"last_page" INTEGER NOT NULL DEFAULT 0',
    '"is_completed" INTEGER NOT NULL DEFAULT 0',
    if (version >= 6) '"reading_status" TEXT NOT NULL DEFAULT \'want_to_read\'',
    if (version >= 10) '"cover_path" TEXT',
    if (version >= 10) '"description" TEXT',
    if (version >= 10) '"completion_date" INTEGER',
    if (version >= 10)
      '"added_as_previously_completed" INTEGER NOT NULL DEFAULT 0',
    '"created_at" INTEGER NOT NULL DEFAULT 0',
  ];
  return 'CREATE TABLE "books" (${columns.join(', ')})';
}

/// Schema that `reading_sessions` had at [version].
String _sessionsDdl(int version) {
  final columns = <String>[
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT',
    if (version >= 12) '"sync_id" TEXT',
    '"book_id" INTEGER NOT NULL REFERENCES "books" ("id") ON DELETE CASCADE',
    '"date" TEXT NOT NULL',
    '"duration_seconds" INTEGER NOT NULL',
    '"pages_read" INTEGER NOT NULL DEFAULT 0',
    if (version >= 2) '"start_time" INTEGER',
    if (version >= 2) '"end_time" INTEGER',
    if (version >= 2) '"starting_page" INTEGER',
    if (version >= 2) '"ending_page" INTEGER',
    if (version >= 2) '"active_segment_started_at" INTEGER',
    if (version >= 9) '"reading_mode" TEXT NOT NULL DEFAULT \'digital\'',
    if (version >= 9) '"note" TEXT',
  ];
  return 'CREATE TABLE "reading_sessions" (${columns.join(', ')})';
}

/// Tables whose definition never changed after they were introduced.
const _stableTablesDdl = <String, String>{
  'bookmarks': 'CREATE TABLE "bookmarks" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"book_id" INTEGER NOT NULL, "page_number" INTEGER NOT NULL, '
      '"title" TEXT, "created_at" INTEGER NOT NULL DEFAULT 0)',
  'highlights': 'CREATE TABLE "highlights" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"book_id" INTEGER NOT NULL, "page_number" INTEGER NOT NULL, '
      '"selected_text" TEXT NOT NULL, "start_index" INTEGER NOT NULL, '
      '"end_index" INTEGER NOT NULL, "left" REAL NOT NULL, '
      '"top" REAL NOT NULL, "right" REAL NOT NULL, "bottom" REAL NOT NULL, '
      '"color_value" INTEGER NOT NULL, '
      '"created_at" INTEGER NOT NULL DEFAULT 0)',
  'notes': 'CREATE TABLE "notes" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"book_id" INTEGER NOT NULL, "page_number" INTEGER, '
      '"content" TEXT NOT NULL, "created_at" INTEGER NOT NULL DEFAULT 0, '
      '"modified_at" INTEGER NOT NULL DEFAULT 0)',
  'journal_entries': 'CREATE TABLE "journal_entries" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"book_id" INTEGER, "page_number" INTEGER, "title" TEXT NOT NULL, '
      '"reflection" TEXT NOT NULL, "created_at" INTEGER NOT NULL DEFAULT 0, '
      '"modified_at" INTEGER NOT NULL DEFAULT 0)',
  'collections': 'CREATE TABLE "collections" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"name" TEXT NOT NULL, "description" TEXT NOT NULL DEFAULT \'\', '
      '"created_at" INTEGER NOT NULL DEFAULT 0)',
  'book_collections': 'CREATE TABLE "book_collections" ('
      '"book_id" INTEGER NOT NULL, "collection_id" INTEGER NOT NULL, '
      'PRIMARY KEY ("book_id", "collection_id"))',
  'achievement_unlocks': 'CREATE TABLE "achievement_unlocks" ('
      '"achievement_id" TEXT NOT NULL PRIMARY KEY, '
      '"unlocked_at" INTEGER NOT NULL)',
  'sync_records': 'CREATE TABLE "sync_records" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"record_key" TEXT NOT NULL UNIQUE, "entity_type" TEXT NOT NULL, '
      '"payload" TEXT NOT NULL, "updated_at" INTEGER NOT NULL, '
      '"deleted" INTEGER NOT NULL DEFAULT 0, '
      '"pending" INTEGER NOT NULL DEFAULT 1)',
  'book_completions': 'CREATE TABLE "book_completions" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"book_id" INTEGER NOT NULL REFERENCES "books" ("id") ON DELETE CASCADE, '
      '"completed_at" INTEGER NOT NULL, '
      '"historical" INTEGER NOT NULL DEFAULT 0)',
};

AppDatabase _databaseAtVersion(
  int version, {
  void Function(dynamic raw)? seed,
}) {
  final executor = NativeDatabase.memory(
    setup: (raw) {
      raw.execute(_booksDdl(version));
      raw.execute(_sessionsDdl(version));
      for (final entry in _introducedAt.entries) {
        if (version >= entry.value) {
          raw.execute(_stableTablesDdl[entry.key]!);
        }
      }
      seed?.call(raw);
      raw.userVersion = version;
    },
  );
  return AppDatabase.forTesting(executor);
}

Future<Set<String>> _columnsOf(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info("$table")').get();
  return rows.map((row) => row.data['name'] as String).toSet();
}

void main() {
  for (var version = 1; version <= 11; version++) {
    test('upgrades a v$version database to the complete v12 schema', () async {
      final db = _databaseAtVersion(version);
      addTearDown(db.close);

      // The first query opens the database and runs the migration.
      await db.getAllBooks();

      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      expect(
        tables.map((row) => row.data['name'] as String).toSet(),
        _allColumns.keys.toSet(),
        reason: 'v$version -> v12 must create every table',
      );

      for (final entry in _allColumns.entries) {
        expect(
          await _columnsOf(db, entry.key),
          entry.value,
          reason: 'v$version -> v12 left "${entry.key}" incomplete',
        );
      }
    });
  }

  test('v10 -> v12 repairs impossible durations and migrates sync IDs', () async {
    const startSeconds = 1700000000;
    const endSeconds = startSeconds + 20 * 60; // 20 real minutes

    final db = _databaseAtVersion(
      10,
      seed: (raw) {
        raw.execute(
          'INSERT INTO "books" ("id", "title", "created_at") '
          "VALUES (1, 'Inflated', $startSeconds)",
        );
        raw.execute(
          'INSERT INTO "reading_sessions" '
          '("id", "book_id", "date", "duration_seconds", "pages_read", '
          '"start_time", "end_time", "reading_mode") '
          "VALUES (1, 1, '2023-11-14', 45600, 12, "
          '$startSeconds, $endSeconds, \'digital\')',
        );
        // A legitimate session must not be changed by the repair.
        raw.execute(
          'INSERT INTO "reading_sessions" '
          '("id", "book_id", "date", "duration_seconds", "pages_read", '
          '"start_time", "end_time", "reading_mode") '
          "VALUES (2, 1, '2023-11-14', 600, 4, "
          '$startSeconds, ${startSeconds + 1200}, \'digital\')',
        );
        // A legacy row without timestamps must be preserved untouched.
        raw.execute(
          'INSERT INTO "reading_sessions" '
          '("id", "book_id", "date", "duration_seconds", "pages_read") '
          "VALUES (3, 1, '2023-11-14', 999, 0)",
        );
      },
    );
    addTearDown(db.close);

    final sessions = await db.getAllSessions();
    final byId = {for (final session in sessions) session.id: session};

    expect(byId[1]!.durationSeconds, 20 * 60);
    expect(byId[2]!.durationSeconds, 600);
    expect(byId[3]!.durationSeconds, 999);
    expect(byId[1]!.syncId, isNotEmpty);
    expect(byId[2]!.syncId, isNotEmpty);
    expect(byId[3]!.syncId, isNotEmpty);

    final books = await db.getAllBooks();
    expect(books.single.syncId, isNotEmpty);

    // The repair must be queued for cloud sync too, with a stable UUID key.
    final pending = await db.getPendingSyncRecords();
    expect(
      pending.any(
        (record) =>
            record.entityType == 'reading_session' &&
            record.recordKey.startsWith('session:') &&
            !record.recordKey.startsWith('session:legacy:') &&
            record.recordKey != 'session:1',
      ),
      isTrue,
    );
  });
}
