enum ReadingStatus {
  currentlyReading('currently_reading'),
  wantToRead('want_to_read'),
  completed('completed'),
  paused('paused'),
  abandoned('abandoned');

  final String value;
  const ReadingStatus(this.value);

  static ReadingStatus fromValue(String? value) {
    return ReadingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReadingStatus.wantToRead,
    );
  }
}
