import 'package:drift/drift.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  IntColumn get totalPages => integer().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get fileName => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get lastPage => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get readingStatus =>
      text().withDefault(const Constant('want_to_read'))();
  TextColumn get coverPath => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get completionDate => dateTime().nullable()();
  BoolColumn get addedAsPreviouslyCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
