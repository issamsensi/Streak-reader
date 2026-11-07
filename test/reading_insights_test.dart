import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/entities/reading_statistics.dart';
import 'package:streak_reader/src/domain/usecases/generate_reading_insights.dart';

void main() {
  test('does not invent insights without reading records', () {
    final result = const GenerateReadingInsights()(
      statistics: const ReadingStatistics(),
      now: DateTime(2026, 1, 1),
    );

    expect(result.items.single.title, 'Start a reading session');
    expect(result.pagesPerHour, isNull);
  });

  test('calculates weekly comparison and reading speed deterministically', () {
    final book = Book(
      id: 1,
      title: 'Book',
      author: null,
      totalPages: 200,
      filePath: null,
      fileName: null,
      fileSize: null,
      lastPage: 10,
      isCompleted: false,
      readingStatus: 'currently_reading',
      createdAt: DateTime(2026, 1, 1),
    );
    const session = ReadingSession(
      readingMode: 'digital',
      id: 1,
      bookId: 1,
      date: '2026-01-01',
      durationSeconds: 1800,
      pagesRead: 15,
      startTime: null,
      endTime: null,
      startingPage: 1,
      endingPage: 16,
      activeSegmentStartedAt: null,
    );
    final statistics = ReadingStatistics.fromRecords(
      sessions: [session],
      books: [book],
      now: DateTime(2026, 1, 1),
    );
    final result = const GenerateReadingInsights()(
      statistics: statistics,
      now: DateTime(2026, 1, 1),
    );

    expect(result.weekSeconds, 1800);
    expect(result.pagesPerHour, 30);
    expect(result.items.any((item) => item.title == 'This week'), isTrue);
  });
}
