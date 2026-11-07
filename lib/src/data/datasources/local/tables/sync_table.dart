import 'package:drift/drift.dart';

class SyncRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordKey => text().unique()();
  TextColumn get entityType => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get pending => boolean().withDefault(const Constant(true))();
}
