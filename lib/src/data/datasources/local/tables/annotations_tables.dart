import 'package:drift/drift.dart';

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()();
  IntColumn get pageNumber => integer()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Highlights extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()();
  IntColumn get pageNumber => integer()();
  TextColumn get selectedText => text()();
  IntColumn get startIndex => integer()();
  IntColumn get endIndex => integer()();
  RealColumn get left => real()();
  RealColumn get top => real()();
  RealColumn get right => real()();
  RealColumn get bottom => real()();
  IntColumn get colorValue => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()();
  IntColumn get pageNumber => integer().nullable()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modifiedAt => dateTime().withDefault(currentDateAndTime)();
}

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().nullable()();
  IntColumn get pageNumber => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get reflection => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modifiedAt => dateTime().withDefault(currentDateAndTime)();
}

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class BookCollections extends Table {
  IntColumn get bookId => integer()();
  IntColumn get collectionId => integer()();

  @override
  Set<Column> get primaryKey => {bookId, collectionId};
}
