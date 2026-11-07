import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../domain/usecases/calculate_streak.dart';
import '../../data/datasources/local/app_database.dart';

class ReadingWidgetService {
  const ReadingWidgetService._();

  static const _providerName = 'ReadingWidgetProvider';

  static Future<void> update({
    required StreakResult stats,
    Book? continueBook,
  }) async {
    final goalSeconds = stats.todayGoalMinutes * 60;
    final progress = goalSeconds == 0
        ? 0
        : ((stats.todaySeconds * 100) ~/ goalSeconds).clamp(0, 100);
    final minutes = stats.todaySeconds ~/ 60;

    await Future.wait([
      HomeWidget.saveWidgetData<int>('streak', stats.currentStreak),
      HomeWidget.saveWidgetData<int>('today_minutes', minutes),
      HomeWidget.saveWidgetData<int>('goal_minutes', stats.todayGoalMinutes),
      HomeWidget.saveWidgetData<int>('progress_percent', progress),
      HomeWidget.saveWidgetData<String>(
        'widget_date',
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
      HomeWidget.saveWidgetData<String>(
        'progress_label',
        '$minutes / ${stats.todayGoalMinutes} min',
      ),
      HomeWidget.saveWidgetData<String>(
        'continue_book_title',
        continueBook?.title ?? 'Continue reading',
      ),
      HomeWidget.saveWidgetData<int>(
        'continue_book_id',
        continueBook?.id,
      ),
    ]);
    await HomeWidget.updateWidget(name: _providerName);
  }
}
