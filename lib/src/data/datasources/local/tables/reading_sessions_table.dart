import 'package:drift/drift.dart';

import '../../../../core/utils/sync_id.dart';
import 'books_table.dart';

class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Stable cross-device identity for cloud sync. Local UI/FKs still use [id].
  TextColumn get syncId => text().clientDefault(SyncId.generate).nullable()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text()(); // YYYY-MM-DD
  IntColumn get durationSeconds => integer()();
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get startingPage => integer().nullable()();
  IntColumn get endingPage => integer().nullable()();
  DateTimeColumn get activeSegmentStartedAt => dateTime().nullable()();
  TextColumn get readingMode =>
      text().withDefault(const Constant('digital'))();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {syncId},
      ];
}
