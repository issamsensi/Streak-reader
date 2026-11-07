import 'package:drift/drift.dart';

import 'books_table.dart';

class BookCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt => dateTime()();
  BoolColumn get historical =>
      boolean().withDefault(const Constant(false))();
}
