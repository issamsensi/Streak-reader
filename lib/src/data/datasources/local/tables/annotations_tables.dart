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
