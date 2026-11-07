/// Helpers for calendar days stored as `YYYY-MM-DD` strings.
///
/// Sessions are recorded with the reader's local calendar date. To compare
/// days and walk months we use UTC-midnight values, which keeps arithmetic
/// stable across daylight-saving transitions. [fromDate] deliberately copies
/// the date components without converting the timezone.
class DateOnly {
  DateOnly._();

  /// Returns a UTC midnight representation of [date]'s calendar components.
  static DateTime fromDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  /// Stable storage/query key in `YYYY-MM-DD` format.
  static String key(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Parses a stored `YYYY-MM-DD` key without timezone conversion.
  ///
  /// Returns `null` for malformed keys and impossible dates such as
  /// `2026-02-30`.
  static DateTime? tryParse(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;

    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  static DateTime monthStart(DateTime date) =>
      DateTime.utc(date.year, date.month, 1);

  static DateTime addMonths(DateTime month, int delta) =>
      DateTime.utc(month.year, month.month + delta, 1);

  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;
}
