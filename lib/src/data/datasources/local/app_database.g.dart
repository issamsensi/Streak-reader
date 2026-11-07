// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPageMeta =
      const VerificationMeta('lastPage');
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
      'last_page', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        filePath,
        fileName,
        fileSize,
        lastPage,
        isCompleted,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('last_page')) {
      context.handle(_lastPageMeta,
          lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      lastPage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_page'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final int lastPage;
  final bool isCompleted;
  final DateTime createdAt;
  const Book(
      {required this.id,
      required this.title,
      this.filePath,
      this.fileName,
      this.fileSize,
      required this.lastPage,
      required this.isCompleted,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['last_page'] = Variable<int>(lastPage);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      lastPage: Value(lastPage),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      lastPage: serializer.fromJson<int>(json['lastPage']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String?>(filePath),
      'fileName': serializer.toJson<String?>(fileName),
      'fileSize': serializer.toJson<int?>(fileSize),
      'lastPage': serializer.toJson<int>(lastPage),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Book copyWith(
          {int? id,
          String? title,
          Value<String?> filePath = const Value.absent(),
          Value<String?> fileName = const Value.absent(),
          Value<int?> fileSize = const Value.absent(),
          int? lastPage,
          bool? isCompleted,
          DateTime? createdAt}) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        filePath: filePath.present ? filePath.value : this.filePath,
        fileName: fileName.present ? fileName.value : this.fileName,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        lastPage: lastPage ?? this.lastPage,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
      );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('lastPage: $lastPage, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, filePath, fileName, fileSize,
      lastPage, isCompleted, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.lastPage == this.lastPage &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> filePath;
  final Value<String?> fileName;
  final Value<int?> fileSize;
  final Value<int> lastPage;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.filePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<int>? lastPage,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (lastPage != null) 'last_page': lastPage,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BooksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? filePath,
      Value<String?>? fileName,
      Value<int?>? fileSize,
      Value<int>? lastPage,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      lastPage: lastPage ?? this.lastPage,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('lastPage: $lastPage, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pagesReadMeta =
      const VerificationMeta('pagesRead');
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
      'pages_read', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _startingPageMeta =
      const VerificationMeta('startingPage');
  @override
  late final GeneratedColumn<int> startingPage = GeneratedColumn<int>(
      'starting_page', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endingPageMeta =
      const VerificationMeta('endingPage');
  @override
  late final GeneratedColumn<int> endingPage = GeneratedColumn<int>(
      'ending_page', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _activeSegmentStartedAtMeta =
      const VerificationMeta('activeSegmentStartedAt');
  @override
  late final GeneratedColumn<DateTime> activeSegmentStartedAt =
      GeneratedColumn<DateTime>('active_segment_started_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        date,
        durationSeconds,
        pagesRead,
        startTime,
        endTime,
        startingPage,
        endingPage,
        activeSegmentStartedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('pages_read')) {
      context.handle(_pagesReadMeta,
          pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('starting_page')) {
      context.handle(
          _startingPageMeta,
          startingPage.isAcceptableOrUnknown(
              data['starting_page']!, _startingPageMeta));
    }
    if (data.containsKey('ending_page')) {
      context.handle(
          _endingPageMeta,
          endingPage.isAcceptableOrUnknown(
              data['ending_page']!, _endingPageMeta));
    }
    if (data.containsKey('active_segment_started_at')) {
      context.handle(
          _activeSegmentStartedAtMeta,
          activeSegmentStartedAt.isAcceptableOrUnknown(
              data['active_segment_started_at']!, _activeSegmentStartedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      pagesRead: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pages_read'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      startingPage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}starting_page']),
      endingPage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ending_page']),
      activeSegmentStartedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}active_segment_started_at']),
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final int id;
  final int bookId;
  final String date;
  final int durationSeconds;
  final int pagesRead;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? startingPage;
  final int? endingPage;
  final DateTime? activeSegmentStartedAt;
  const ReadingSession(
      {required this.id,
      required this.bookId,
      required this.date,
      required this.durationSeconds,
      required this.pagesRead,
      this.startTime,
      this.endTime,
      this.startingPage,
      this.endingPage,
      this.activeSegmentStartedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['date'] = Variable<String>(date);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['pages_read'] = Variable<int>(pagesRead);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || startingPage != null) {
      map['starting_page'] = Variable<int>(startingPage);
    }
    if (!nullToAbsent || endingPage != null) {
      map['ending_page'] = Variable<int>(endingPage);
    }
    if (!nullToAbsent || activeSegmentStartedAt != null) {
      map['active_segment_started_at'] =
          Variable<DateTime>(activeSegmentStartedAt);
    }
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      date: Value(date),
      durationSeconds: Value(durationSeconds),
      pagesRead: Value(pagesRead),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      startingPage: startingPage == null && nullToAbsent
          ? const Value.absent()
          : Value(startingPage),
      endingPage: endingPage == null && nullToAbsent
          ? const Value.absent()
          : Value(endingPage),
      activeSegmentStartedAt: activeSegmentStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(activeSegmentStartedAt),
    );
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      date: serializer.fromJson<String>(json['date']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      startingPage: serializer.fromJson<int?>(json['startingPage']),
      endingPage: serializer.fromJson<int?>(json['endingPage']),
      activeSegmentStartedAt:
          serializer.fromJson<DateTime?>(json['activeSegmentStartedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'date': serializer.toJson<String>(date),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'startingPage': serializer.toJson<int?>(startingPage),
      'endingPage': serializer.toJson<int?>(endingPage),
      'activeSegmentStartedAt':
          serializer.toJson<DateTime?>(activeSegmentStartedAt),
    };
  }

  ReadingSession copyWith(
          {int? id,
          int? bookId,
          String? date,
          int? durationSeconds,
          int? pagesRead,
          Value<DateTime?> startTime = const Value.absent(),
          Value<DateTime?> endTime = const Value.absent(),
          Value<int?> startingPage = const Value.absent(),
          Value<int?> endingPage = const Value.absent(),
          Value<DateTime?> activeSegmentStartedAt = const Value.absent()}) =>
      ReadingSession(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        date: date ?? this.date,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        pagesRead: pagesRead ?? this.pagesRead,
        startTime: startTime.present ? startTime.value : this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        startingPage:
            startingPage.present ? startingPage.value : this.startingPage,
        endingPage: endingPage.present ? endingPage.value : this.endingPage,
        activeSegmentStartedAt: activeSegmentStartedAt.present
            ? activeSegmentStartedAt.value
            : this.activeSegmentStartedAt,
      );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      date: data.date.present ? data.date.value : this.date,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      startingPage: data.startingPage.present
          ? data.startingPage.value
          : this.startingPage,
      endingPage:
          data.endingPage.present ? data.endingPage.value : this.endingPage,
      activeSegmentStartedAt: data.activeSegmentStartedAt.present
          ? data.activeSegmentStartedAt.value
          : this.activeSegmentStartedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('startingPage: $startingPage, ')
          ..write('endingPage: $endingPage, ')
          ..write('activeSegmentStartedAt: $activeSegmentStartedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, date, durationSeconds, pagesRead,
      startTime, endTime, startingPage, endingPage, activeSegmentStartedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.date == this.date &&
          other.durationSeconds == this.durationSeconds &&
          other.pagesRead == this.pagesRead &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.startingPage == this.startingPage &&
          other.endingPage == this.endingPage &&
          other.activeSegmentStartedAt == this.activeSegmentStartedAt);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> date;
  final Value<int> durationSeconds;
  final Value<int> pagesRead;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<int?> startingPage;
  final Value<int?> endingPage;
  final Value<DateTime?> activeSegmentStartedAt;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.date = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.startingPage = const Value.absent(),
    this.endingPage = const Value.absent(),
    this.activeSegmentStartedAt = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String date,
    required int durationSeconds,
    this.pagesRead = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.startingPage = const Value.absent(),
    this.endingPage = const Value.absent(),
    this.activeSegmentStartedAt = const Value.absent(),
  })  : bookId = Value(bookId),
        date = Value(date),
        durationSeconds = Value(durationSeconds);
  static Insertable<ReadingSession> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? date,
    Expression<int>? durationSeconds,
    Expression<int>? pagesRead,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? startingPage,
    Expression<int>? endingPage,
    Expression<DateTime>? activeSegmentStartedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (date != null) 'date': date,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (startingPage != null) 'starting_page': startingPage,
      if (endingPage != null) 'ending_page': endingPage,
      if (activeSegmentStartedAt != null)
        'active_segment_started_at': activeSegmentStartedAt,
    });
  }

  ReadingSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<String>? date,
      Value<int>? durationSeconds,
      Value<int>? pagesRead,
      Value<DateTime?>? startTime,
      Value<DateTime?>? endTime,
      Value<int?>? startingPage,
      Value<int?>? endingPage,
      Value<DateTime?>? activeSegmentStartedAt}) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pagesRead: pagesRead ?? this.pagesRead,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startingPage: startingPage ?? this.startingPage,
      endingPage: endingPage ?? this.endingPage,
      activeSegmentStartedAt:
          activeSegmentStartedAt ?? this.activeSegmentStartedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (startingPage.present) {
      map['starting_page'] = Variable<int>(startingPage.value);
    }
    if (endingPage.present) {
      map['ending_page'] = Variable<int>(endingPage.value);
    }
    if (activeSegmentStartedAt.present) {
      map['active_segment_started_at'] =
          Variable<DateTime>(activeSegmentStartedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('startingPage: $startingPage, ')
          ..write('endingPage: $endingPage, ')
          ..write('activeSegmentStartedAt: $activeSegmentStartedAt')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
      'page_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, pageNumber, title, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<Bookmark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_number'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final int bookId;
  final int pageNumber;
  final String? title;
  final DateTime createdAt;
  const Bookmark(
      {required this.id,
      required this.bookId,
      required this.pageNumber,
      this.title,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['page_number'] = Variable<int>(pageNumber);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      pageNumber: Value(pageNumber),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      title: serializer.fromJson<String?>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'title': serializer.toJson<String?>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith(
          {int? id,
          int? bookId,
          int? pageNumber,
          Value<String?> title = const Value.absent(),
          DateTime? createdAt}) =>
      Bookmark(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        pageNumber: pageNumber ?? this.pageNumber,
        title: title.present ? title.value : this.title,
        createdAt: createdAt ?? this.createdAt,
      );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, pageNumber, title, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.pageNumber == this.pageNumber &&
          other.title == this.title &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> pageNumber;
  final Value<String?> title;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int pageNumber,
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : bookId = Value(bookId),
        pageNumber = Value(pageNumber);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? pageNumber,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<int>? pageNumber,
      Value<String?>? title,
      Value<DateTime>? createdAt}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageNumber: pageNumber ?? this.pageNumber,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HighlightsTable extends Highlights
    with TableInfo<$HighlightsTable, Highlight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
      'book_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
      'page_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _selectedTextMeta =
      const VerificationMeta('selectedText');
  @override
  late final GeneratedColumn<String> selectedText = GeneratedColumn<String>(
      'selected_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startIndexMeta =
      const VerificationMeta('startIndex');
  @override
  late final GeneratedColumn<int> startIndex = GeneratedColumn<int>(
      'start_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endIndexMeta =
      const VerificationMeta('endIndex');
  @override
  late final GeneratedColumn<int> endIndex = GeneratedColumn<int>(
      'end_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _leftMeta = const VerificationMeta('left');
  @override
  late final GeneratedColumn<double> left = GeneratedColumn<double>(
      'left', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _topMeta = const VerificationMeta('top');
  @override
  late final GeneratedColumn<double> top = GeneratedColumn<double>(
      'top', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rightMeta = const VerificationMeta('right');
  @override
  late final GeneratedColumn<double> right = GeneratedColumn<double>(
      'right', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bottomMeta = const VerificationMeta('bottom');
  @override
  late final GeneratedColumn<double> bottom = GeneratedColumn<double>(
      'bottom', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        pageNumber,
        selectedText,
        startIndex,
        endIndex,
        left,
        top,
        right,
        bottom,
        colorValue,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'highlights';
  @override
  VerificationContext validateIntegrity(Insertable<Highlight> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('selected_text')) {
      context.handle(
          _selectedTextMeta,
          selectedText.isAcceptableOrUnknown(
              data['selected_text']!, _selectedTextMeta));
    } else if (isInserting) {
      context.missing(_selectedTextMeta);
    }
    if (data.containsKey('start_index')) {
      context.handle(
          _startIndexMeta,
          startIndex.isAcceptableOrUnknown(
              data['start_index']!, _startIndexMeta));
    } else if (isInserting) {
      context.missing(_startIndexMeta);
    }
    if (data.containsKey('end_index')) {
      context.handle(_endIndexMeta,
          endIndex.isAcceptableOrUnknown(data['end_index']!, _endIndexMeta));
    } else if (isInserting) {
      context.missing(_endIndexMeta);
    }
    if (data.containsKey('left')) {
      context.handle(
          _leftMeta, left.isAcceptableOrUnknown(data['left']!, _leftMeta));
    } else if (isInserting) {
      context.missing(_leftMeta);
    }
    if (data.containsKey('top')) {
      context.handle(
          _topMeta, top.isAcceptableOrUnknown(data['top']!, _topMeta));
    } else if (isInserting) {
      context.missing(_topMeta);
    }
    if (data.containsKey('right')) {
      context.handle(
          _rightMeta, right.isAcceptableOrUnknown(data['right']!, _rightMeta));
    } else if (isInserting) {
      context.missing(_rightMeta);
    }
    if (data.containsKey('bottom')) {
      context.handle(_bottomMeta,
          bottom.isAcceptableOrUnknown(data['bottom']!, _bottomMeta));
    } else if (isInserting) {
      context.missing(_bottomMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Highlight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Highlight(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_id'])!,
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_number'])!,
      selectedText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selected_text'])!,
      startIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_index'])!,
      endIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_index'])!,
      left: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}left'])!,
      top: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}top'])!,
      right: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}right'])!,
      bottom: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bottom'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HighlightsTable createAlias(String alias) {
    return $HighlightsTable(attachedDatabase, alias);
  }
}

class Highlight extends DataClass implements Insertable<Highlight> {
  final int id;
  final int bookId;
  final int pageNumber;
  final String selectedText;
  final int startIndex;
  final int endIndex;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final int colorValue;
  final DateTime createdAt;
  const Highlight(
      {required this.id,
      required this.bookId,
      required this.pageNumber,
      required this.selectedText,
      required this.startIndex,
      required this.endIndex,
      required this.left,
      required this.top,
      required this.right,
      required this.bottom,
      required this.colorValue,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['page_number'] = Variable<int>(pageNumber);
    map['selected_text'] = Variable<String>(selectedText);
    map['start_index'] = Variable<int>(startIndex);
    map['end_index'] = Variable<int>(endIndex);
    map['left'] = Variable<double>(left);
    map['top'] = Variable<double>(top);
    map['right'] = Variable<double>(right);
    map['bottom'] = Variable<double>(bottom);
    map['color_value'] = Variable<int>(colorValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HighlightsCompanion toCompanion(bool nullToAbsent) {
    return HighlightsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      pageNumber: Value(pageNumber),
      selectedText: Value(selectedText),
      startIndex: Value(startIndex),
      endIndex: Value(endIndex),
      left: Value(left),
      top: Value(top),
      right: Value(right),
      bottom: Value(bottom),
      colorValue: Value(colorValue),
      createdAt: Value(createdAt),
    );
  }

  factory Highlight.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Highlight(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      selectedText: serializer.fromJson<String>(json['selectedText']),
      startIndex: serializer.fromJson<int>(json['startIndex']),
      endIndex: serializer.fromJson<int>(json['endIndex']),
      left: serializer.fromJson<double>(json['left']),
      top: serializer.fromJson<double>(json['top']),
      right: serializer.fromJson<double>(json['right']),
      bottom: serializer.fromJson<double>(json['bottom']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'selectedText': serializer.toJson<String>(selectedText),
      'startIndex': serializer.toJson<int>(startIndex),
      'endIndex': serializer.toJson<int>(endIndex),
      'left': serializer.toJson<double>(left),
      'top': serializer.toJson<double>(top),
      'right': serializer.toJson<double>(right),
      'bottom': serializer.toJson<double>(bottom),
      'colorValue': serializer.toJson<int>(colorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Highlight copyWith(
          {int? id,
          int? bookId,
          int? pageNumber,
          String? selectedText,
          int? startIndex,
          int? endIndex,
          double? left,
          double? top,
          double? right,
          double? bottom,
          int? colorValue,
          DateTime? createdAt}) =>
      Highlight(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        pageNumber: pageNumber ?? this.pageNumber,
        selectedText: selectedText ?? this.selectedText,
        startIndex: startIndex ?? this.startIndex,
        endIndex: endIndex ?? this.endIndex,
        left: left ?? this.left,
        top: top ?? this.top,
        right: right ?? this.right,
        bottom: bottom ?? this.bottom,
        colorValue: colorValue ?? this.colorValue,
        createdAt: createdAt ?? this.createdAt,
      );
  Highlight copyWithCompanion(HighlightsCompanion data) {
    return Highlight(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      selectedText: data.selectedText.present
          ? data.selectedText.value
          : this.selectedText,
      startIndex:
          data.startIndex.present ? data.startIndex.value : this.startIndex,
      endIndex: data.endIndex.present ? data.endIndex.value : this.endIndex,
      left: data.left.present ? data.left.value : this.left,
      top: data.top.present ? data.top.value : this.top,
      right: data.right.present ? data.right.value : this.right,
      bottom: data.bottom.present ? data.bottom.value : this.bottom,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Highlight(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('selectedText: $selectedText, ')
          ..write('startIndex: $startIndex, ')
          ..write('endIndex: $endIndex, ')
          ..write('left: $left, ')
          ..write('top: $top, ')
          ..write('right: $right, ')
          ..write('bottom: $bottom, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, pageNumber, selectedText,
      startIndex, endIndex, left, top, right, bottom, colorValue, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Highlight &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.pageNumber == this.pageNumber &&
          other.selectedText == this.selectedText &&
          other.startIndex == this.startIndex &&
          other.endIndex == this.endIndex &&
          other.left == this.left &&
          other.top == this.top &&
          other.right == this.right &&
          other.bottom == this.bottom &&
          other.colorValue == this.colorValue &&
          other.createdAt == this.createdAt);
}

class HighlightsCompanion extends UpdateCompanion<Highlight> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> pageNumber;
  final Value<String> selectedText;
  final Value<int> startIndex;
  final Value<int> endIndex;
  final Value<double> left;
  final Value<double> top;
  final Value<double> right;
  final Value<double> bottom;
  final Value<int> colorValue;
  final Value<DateTime> createdAt;
  const HighlightsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.selectedText = const Value.absent(),
    this.startIndex = const Value.absent(),
    this.endIndex = const Value.absent(),
    this.left = const Value.absent(),
    this.top = const Value.absent(),
    this.right = const Value.absent(),
    this.bottom = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HighlightsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int pageNumber,
    required String selectedText,
    required int startIndex,
    required int endIndex,
    required double left,
    required double top,
    required double right,
    required double bottom,
    required int colorValue,
    this.createdAt = const Value.absent(),
  })  : bookId = Value(bookId),
        pageNumber = Value(pageNumber),
        selectedText = Value(selectedText),
        startIndex = Value(startIndex),
        endIndex = Value(endIndex),
        left = Value(left),
        top = Value(top),
        right = Value(right),
        bottom = Value(bottom),
        colorValue = Value(colorValue);
  static Insertable<Highlight> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? pageNumber,
    Expression<String>? selectedText,
    Expression<int>? startIndex,
    Expression<int>? endIndex,
    Expression<double>? left,
    Expression<double>? top,
    Expression<double>? right,
    Expression<double>? bottom,
    Expression<int>? colorValue,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (selectedText != null) 'selected_text': selectedText,
      if (startIndex != null) 'start_index': startIndex,
      if (endIndex != null) 'end_index': endIndex,
      if (left != null) 'left': left,
      if (top != null) 'top': top,
      if (right != null) 'right': right,
      if (bottom != null) 'bottom': bottom,
      if (colorValue != null) 'color_value': colorValue,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HighlightsCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookId,
      Value<int>? pageNumber,
      Value<String>? selectedText,
      Value<int>? startIndex,
      Value<int>? endIndex,
      Value<double>? left,
      Value<double>? top,
      Value<double>? right,
      Value<double>? bottom,
      Value<int>? colorValue,
      Value<DateTime>? createdAt}) {
    return HighlightsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageNumber: pageNumber ?? this.pageNumber,
      selectedText: selectedText ?? this.selectedText,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (selectedText.present) {
      map['selected_text'] = Variable<String>(selectedText.value);
    }
    if (startIndex.present) {
      map['start_index'] = Variable<int>(startIndex.value);
    }
    if (endIndex.present) {
      map['end_index'] = Variable<int>(endIndex.value);
    }
    if (left.present) {
      map['left'] = Variable<double>(left.value);
    }
    if (top.present) {
      map['top'] = Variable<double>(top.value);
    }
    if (right.present) {
      map['right'] = Variable<double>(right.value);
    }
    if (bottom.present) {
      map['bottom'] = Variable<double>(bottom.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighlightsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('selectedText: $selectedText, ')
          ..write('startIndex: $startIndex, ')
          ..write('endIndex: $endIndex, ')
          ..write('left: $left, ')
          ..write('top: $top, ')
          ..write('right: $right, ')
          ..write('bottom: $bottom, ')
          ..write('colorValue: $colorValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ReadingSessionsTable readingSessions =
      $ReadingSessionsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $HighlightsTable highlights = $HighlightsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [books, readingSessions, bookmarks, highlights];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_sessions', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> filePath,
  Value<String?> fileName,
  Value<int?> fileSize,
  Value<int> lastPage,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> filePath,
  Value<String?> fileName,
  Value<int?> fileSize,
  Value<int> lastPage,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReadingSessionsTable, List<ReadingSession>>
      _readingSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingSessions,
              aliasName: 'books__id__reading_sessions__book_id');

  $$ReadingSessionsTableProcessedTableManager get readingSessionsRefs {
    final manager =
        $$ReadingSessionsTableTableManager($_db, $_db.readingSessions)
            .filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_readingSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPage => $composableBuilder(
      column: $table.lastPage, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> readingSessionsRefs(
      Expression<bool> Function($$ReadingSessionsTableFilterComposer f) f) {
    final $$ReadingSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingSessions,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingSessionsTableFilterComposer(
              $db: $db,
              $table: $db.readingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPage => $composableBuilder(
      column: $table.lastPage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> readingSessionsRefs<T extends Object>(
      Expression<T> Function($$ReadingSessionsTableAnnotationComposer a) f) {
    final $$ReadingSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingSessions,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.readingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, $$BooksTableReferences),
    Book,
    PrefetchHooks Function({bool readingSessionsRefs})> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<int> lastPage = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            title: title,
            filePath: filePath,
            fileName: fileName,
            fileSize: fileSize,
            lastPage: lastPage,
            isCompleted: isCompleted,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> filePath = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<int> lastPage = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            title: title,
            filePath: filePath,
            fileName: fileName,
            fileSize: fileSize,
            lastPage: lastPage,
            isCompleted: isCompleted,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BooksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({readingSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (readingSessionsRefs) db.readingSessions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingSessionsRefs)
                    await $_getPrefetchedData<Book, $BooksTable,
                            ReadingSession>(
                        currentTable: table,
                        referencedTable: $$BooksTableReferences
                            ._readingSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .readingSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, $$BooksTableReferences),
    Book,
    PrefetchHooks Function({bool readingSessionsRefs})>;
typedef $$ReadingSessionsTableCreateCompanionBuilder = ReadingSessionsCompanion
    Function({
  Value<int> id,
  required int bookId,
  required String date,
  required int durationSeconds,
  Value<int> pagesRead,
  Value<DateTime?> startTime,
  Value<DateTime?> endTime,
  Value<int?> startingPage,
  Value<int?> endingPage,
  Value<DateTime?> activeSegmentStartedAt,
});
typedef $$ReadingSessionsTableUpdateCompanionBuilder = ReadingSessionsCompanion
    Function({
  Value<int> id,
  Value<int> bookId,
  Value<String> date,
  Value<int> durationSeconds,
  Value<int> pagesRead,
  Value<DateTime?> startTime,
  Value<DateTime?> endTime,
  Value<int?> startingPage,
  Value<int?> endingPage,
  Value<DateTime?> activeSegmentStartedAt,
});

final class $$ReadingSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $ReadingSessionsTable, ReadingSession> {
  $$ReadingSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_sessions__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pagesRead => $composableBuilder(
      column: $table.pagesRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startingPage => $composableBuilder(
      column: $table.startingPage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endingPage => $composableBuilder(
      column: $table.endingPage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get activeSegmentStartedAt => $composableBuilder(
      column: $table.activeSegmentStartedAt,
      builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pagesRead => $composableBuilder(
      column: $table.pagesRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startingPage => $composableBuilder(
      column: $table.startingPage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endingPage => $composableBuilder(
      column: $table.endingPage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get activeSegmentStartedAt => $composableBuilder(
      column: $table.activeSegmentStartedAt,
      builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get startingPage => $composableBuilder(
      column: $table.startingPage, builder: (column) => column);

  GeneratedColumn<int> get endingPage => $composableBuilder(
      column: $table.endingPage, builder: (column) => column);

  GeneratedColumn<DateTime> get activeSegmentStartedAt => $composableBuilder(
      column: $table.activeSegmentStartedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSession,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (ReadingSession, $$ReadingSessionsTableReferences),
    ReadingSession,
    PrefetchHooks Function({bool bookId})> {
  $$ReadingSessionsTableTableManager(
      _$AppDatabase db, $ReadingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> pagesRead = const Value.absent(),
            Value<DateTime?> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int?> startingPage = const Value.absent(),
            Value<int?> endingPage = const Value.absent(),
            Value<DateTime?> activeSegmentStartedAt = const Value.absent(),
          }) =>
              ReadingSessionsCompanion(
            id: id,
            bookId: bookId,
            date: date,
            durationSeconds: durationSeconds,
            pagesRead: pagesRead,
            startTime: startTime,
            endTime: endTime,
            startingPage: startingPage,
            endingPage: endingPage,
            activeSegmentStartedAt: activeSegmentStartedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookId,
            required String date,
            required int durationSeconds,
            Value<int> pagesRead = const Value.absent(),
            Value<DateTime?> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int?> startingPage = const Value.absent(),
            Value<int?> endingPage = const Value.absent(),
            Value<DateTime?> activeSegmentStartedAt = const Value.absent(),
          }) =>
              ReadingSessionsCompanion.insert(
            id: id,
            bookId: bookId,
            date: date,
            durationSeconds: durationSeconds,
            pagesRead: pagesRead,
            startTime: startTime,
            endTime: endTime,
            startingPage: startingPage,
            endingPage: endingPage,
            activeSegmentStartedAt: activeSegmentStartedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReadingSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$ReadingSessionsTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$ReadingSessionsTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReadingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSession,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (ReadingSession, $$ReadingSessionsTableReferences),
    ReadingSession,
    PrefetchHooks Function({bool bookId})>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  required int bookId,
  required int pageNumber,
  Value<String?> title,
  Value<DateTime> createdAt,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<int> bookId,
  Value<int> pageNumber,
  Value<String?> title,
  Value<DateTime> createdAt,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()> {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<int> pageNumber = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            bookId: bookId,
            pageNumber: pageNumber,
            title: title,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookId,
            required int pageNumber,
            Value<String?> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BookmarksCompanion.insert(
            id: id,
            bookId: bookId,
            pageNumber: pageNumber,
            title: title,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()>;
typedef $$HighlightsTableCreateCompanionBuilder = HighlightsCompanion Function({
  Value<int> id,
  required int bookId,
  required int pageNumber,
  required String selectedText,
  required int startIndex,
  required int endIndex,
  required double left,
  required double top,
  required double right,
  required double bottom,
  required int colorValue,
  Value<DateTime> createdAt,
});
typedef $$HighlightsTableUpdateCompanionBuilder = HighlightsCompanion Function({
  Value<int> id,
  Value<int> bookId,
  Value<int> pageNumber,
  Value<String> selectedText,
  Value<int> startIndex,
  Value<int> endIndex,
  Value<double> left,
  Value<double> top,
  Value<double> right,
  Value<double> bottom,
  Value<int> colorValue,
  Value<DateTime> createdAt,
});

class $$HighlightsTableFilterComposer
    extends Composer<_$AppDatabase, $HighlightsTable> {
  $$HighlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedText => $composableBuilder(
      column: $table.selectedText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startIndex => $composableBuilder(
      column: $table.startIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endIndex => $composableBuilder(
      column: $table.endIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get left => $composableBuilder(
      column: $table.left, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get top => $composableBuilder(
      column: $table.top, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get right => $composableBuilder(
      column: $table.right, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bottom => $composableBuilder(
      column: $table.bottom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HighlightsTableOrderingComposer
    extends Composer<_$AppDatabase, $HighlightsTable> {
  $$HighlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedText => $composableBuilder(
      column: $table.selectedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startIndex => $composableBuilder(
      column: $table.startIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endIndex => $composableBuilder(
      column: $table.endIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get left => $composableBuilder(
      column: $table.left, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get top => $composableBuilder(
      column: $table.top, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get right => $composableBuilder(
      column: $table.right, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bottom => $composableBuilder(
      column: $table.bottom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HighlightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HighlightsTable> {
  $$HighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<String> get selectedText => $composableBuilder(
      column: $table.selectedText, builder: (column) => column);

  GeneratedColumn<int> get startIndex => $composableBuilder(
      column: $table.startIndex, builder: (column) => column);

  GeneratedColumn<int> get endIndex =>
      $composableBuilder(column: $table.endIndex, builder: (column) => column);

  GeneratedColumn<double> get left =>
      $composableBuilder(column: $table.left, builder: (column) => column);

  GeneratedColumn<double> get top =>
      $composableBuilder(column: $table.top, builder: (column) => column);

  GeneratedColumn<double> get right =>
      $composableBuilder(column: $table.right, builder: (column) => column);

  GeneratedColumn<double> get bottom =>
      $composableBuilder(column: $table.bottom, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HighlightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HighlightsTable,
    Highlight,
    $$HighlightsTableFilterComposer,
    $$HighlightsTableOrderingComposer,
    $$HighlightsTableAnnotationComposer,
    $$HighlightsTableCreateCompanionBuilder,
    $$HighlightsTableUpdateCompanionBuilder,
    (Highlight, BaseReferences<_$AppDatabase, $HighlightsTable, Highlight>),
    Highlight,
    PrefetchHooks Function()> {
  $$HighlightsTableTableManager(_$AppDatabase db, $HighlightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookId = const Value.absent(),
            Value<int> pageNumber = const Value.absent(),
            Value<String> selectedText = const Value.absent(),
            Value<int> startIndex = const Value.absent(),
            Value<int> endIndex = const Value.absent(),
            Value<double> left = const Value.absent(),
            Value<double> top = const Value.absent(),
            Value<double> right = const Value.absent(),
            Value<double> bottom = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HighlightsCompanion(
            id: id,
            bookId: bookId,
            pageNumber: pageNumber,
            selectedText: selectedText,
            startIndex: startIndex,
            endIndex: endIndex,
            left: left,
            top: top,
            right: right,
            bottom: bottom,
            colorValue: colorValue,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookId,
            required int pageNumber,
            required String selectedText,
            required int startIndex,
            required int endIndex,
            required double left,
            required double top,
            required double right,
            required double bottom,
            required int colorValue,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HighlightsCompanion.insert(
            id: id,
            bookId: bookId,
            pageNumber: pageNumber,
            selectedText: selectedText,
            startIndex: startIndex,
            endIndex: endIndex,
            left: left,
            top: top,
            right: right,
            bottom: bottom,
            colorValue: colorValue,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HighlightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HighlightsTable,
    Highlight,
    $$HighlightsTableFilterComposer,
    $$HighlightsTableOrderingComposer,
    $$HighlightsTableAnnotationComposer,
    $$HighlightsTableCreateCompanionBuilder,
    $$HighlightsTableUpdateCompanionBuilder,
    (Highlight, BaseReferences<_$AppDatabase, $HighlightsTable, Highlight>),
    Highlight,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$HighlightsTableTableManager get highlights =>
      $$HighlightsTableTableManager(_db, _db.highlights);
}
