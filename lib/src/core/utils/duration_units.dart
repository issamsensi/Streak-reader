/// Canonical duration conversions.
///
/// Reading sessions are persisted in whole **seconds** (`durationSeconds`).
/// The live timer keeps **milliseconds** internally so repeated checkpoints do
/// not accumulate truncation errors. Nothing outside this boundary should mix
/// the two units.
class DurationUnits {
  const DurationUnits._();

  static const int millisecondsPerSecond = 1000;
  static const int secondsPerMinute = 60;
  static const int millisecondsPerMinute =
      millisecondsPerSecond * secondsPerMinute;

  /// Converts live milliseconds to the persisted seconds representation.
  static int millisecondsToSeconds(int milliseconds) =>
      milliseconds <= 0 ? 0 : milliseconds ~/ millisecondsPerSecond;

  /// Restores a persisted duration into the live millisecond representation.
  static int secondsToMilliseconds(int seconds) =>
      seconds <= 0 ? 0 : seconds * millisecondsPerSecond;

  static int secondsToMinutes(int seconds) =>
      seconds <= 0 ? 0 : seconds ~/ secondsPerMinute;

  static int minutesToSeconds(int minutes) =>
      minutes <= 0 ? 0 : minutes * secondsPerMinute;
}
