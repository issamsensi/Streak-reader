import 'package:flutter_test/flutter_test.dart';
import 'package:streak_reader/src/domain/entities/reading_reminder.dart';

void main() {
  test('reading reminder settings round-trip and sanitize invalid values', () {
    const settings = ReadingReminderSettings(
      enabled: true,
      hour: 21,
      minute: 30,
      days: {1, 3, 7},
      message: 'Your book is waiting for you.',
    );

    final restored = ReadingReminderSettings.fromMap(settings.toMap());
    expect(restored.enabled, isTrue);
    expect(restored.hour, 21);
    expect(restored.minute, 30);
    expect(restored.days, {1, 3, 7});
    expect(restored.message, 'Your book is waiting for you.');

    final sanitized = ReadingReminderSettings.fromMap({
      'enabled': true,
      'hour': 99,
      'minute': -1,
      'days': [0, 2, 8, 4],
      'message': ' ',
    });
    expect(sanitized.hour, 23);
    expect(sanitized.minute, 0);
    expect(sanitized.days, {2, 4});
    expect(sanitized.message, isNotEmpty);
  });
}
