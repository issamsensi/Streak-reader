class ReadingInsight {
  final String title;
  final String detail;
  final InsightTone tone;

  const ReadingInsight({
    required this.title,
    required this.detail,
    this.tone = InsightTone.neutral,
  });
}

enum InsightTone { positive, actionable, neutral }
