// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Streak Reader';

  @override
  String get booksLibrary => 'Book Library';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get readingReminder => 'Reading reminder';

  @override
  String get reminderEnabled => 'Reminders enabled';

  @override
  String get reminderDisabled => 'Reminders disabled';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get reminderDays => 'days';

  @override
  String get reminderMessage => 'Notification message';

  @override
  String get reminderMessageHint => 'Time for your daily reading session.';

  @override
  String get reminderPermissionHint =>
      'Your device may ask permission before showing notifications.';

  @override
  String get reminderMonday => 'Mon';

  @override
  String get reminderTuesday => 'Tue';

  @override
  String get reminderWednesday => 'Wed';

  @override
  String get reminderThursday => 'Thu';

  @override
  String get reminderFriday => 'Fri';

  @override
  String get reminderSaturday => 'Sat';

  @override
  String get reminderSunday => 'Sun';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get noBooksYet => 'No books yet\nAdd a book by tapping +';

  @override
  String get addBook => 'Add Book';

  @override
  String get bookTitle => 'Book title';

  @override
  String get choosePdfFile => 'Choose a PDF file';

  @override
  String get titleOnlyHint =>
      'You can add just a title to your \"Want to read\" list';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get editTitle => 'Edit title';

  @override
  String get missingFileWarning => 'Warning: file is missing or was moved';

  @override
  String get wantToReadNoFile => 'Want to read (no file)';

  @override
  String get fileNotFoundTitle => 'File not found';

  @override
  String get fileNotFoundBody =>
      'The file was moved or deleted from the device.\nThis book cannot be opened.';

  @override
  String get noFileTitle => 'No file';

  @override
  String get noFileBody =>
      'This book has no PDF file.\nAdd a PDF file to open it in the reader.';

  @override
  String get errorTitle => 'Error';

  @override
  String get readerFileMissing =>
      'The file does not exist.\nIt was moved or deleted from the device.';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get longestStreak => 'Longest streak';

  @override
  String get totalReading => 'Total reading';

  @override
  String get pagesRead => 'Pages read';

  @override
  String get completedBooks => 'Completed books';

  @override
  String get day => 'day';

  @override
  String get minute => 'min';

  @override
  String get page => 'page';

  @override
  String get book => 'book';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get addPdf => 'Add PDF';

  @override
  String get changePdf => 'Change PDF';

  @override
  String get attachPdfWebUnsupported =>
      'Attaching a PDF is not supported on web yet. Please use the mobile or desktop app.';

  @override
  String get yourBooks => 'Your books';

  @override
  String pageNumberLabel(int page) {
    return 'Page $page';
  }

  @override
  String streakGoalHint(int minutes) {
    return 'Read $minutes minutes today to keep your streak alive.';
  }

  @override
  String get readingOverview => 'Reading overview';

  @override
  String get appTagline => 'A little reading every day adds up.';

  @override
  String get addBookSubtitle => 'Choose a PDF or save it to your wishlist.';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get completed => 'Completed';

  @override
  String get deleteBook => 'Delete book';

  @override
  String get deleteBookTitle => 'Delete book?';

  @override
  String deleteBookBody(String title) {
    return 'This permanently deletes \"$title\" and its reading sessions.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get bookDeleted => 'Book deleted.';

  @override
  String get currentlyReading => 'Currently reading';

  @override
  String get wantToRead => 'Want to read';

  @override
  String get paused => 'Paused';

  @override
  String get abandoned => 'Abandoned';

  @override
  String get searchBooks => 'Search books';

  @override
  String get allBooks => 'All books';

  @override
  String get sortRecent => 'Recently added';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortProgress => 'Progress';

  @override
  String get newCollection => 'New collection';

  @override
  String get collectionName => 'Collection name';

  @override
  String get authorOptional => 'Author (optional)';

  @override
  String get totalPagesOptional => 'Total pages (optional)';

  @override
  String get bookDetailsOptional => 'More book details';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get collections => 'Collections';

  @override
  String get collectionDescription => 'Description (optional)';

  @override
  String get titleRequired => 'Please enter a book title.';

  @override
  String get retry => 'Retry';

  @override
  String get readerLoadError => 'Could not open this PDF.';

  @override
  String get loadingPdf => 'Preparing PDF…';

  @override
  String get saveFailed => 'Could not save changes. Please try again.';

  @override
  String get deleteFailed => 'Could not delete the book. Please try again.';

  @override
  String get readingCalendar => 'Reading calendar';

  @override
  String get today => 'Today';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get goalAchieved => 'Goal achieved';

  @override
  String get goalNotAchieved => 'Goal not achieved';

  @override
  String get readingActivity => 'Reading activity';

  @override
  String get noActivity => 'No activity';

  @override
  String get noReadingThisMonth => 'No reading activity this month.';

  @override
  String get monthSummary => 'Monthly summary';

  @override
  String get activeReadingDays => 'Active reading days';

  @override
  String get readingDuration => 'Reading duration';

  @override
  String get sessions => 'Sessions';

  @override
  String minutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String get dailyReadingGoal => 'Daily reading goal';

  @override
  String get dailyGoalDescription =>
      'Choose how many minutes you want to read each day.';

  @override
  String get currentGoal => 'Current goal';

  @override
  String get customGoal => 'Custom';

  @override
  String get customGoalTitle => 'Custom daily goal';

  @override
  String get customGoalHint => 'Minutes per day';

  @override
  String customGoalInvalid(int min, int max) {
    return 'Enter a number between $min and $max.';
  }

  @override
  String dailyGoalProgress(int minutes, int goal) {
    return '$minutes / $goal min';
  }

  @override
  String get dailyGoalReached => 'Daily goal completed!';

  @override
  String dailyGoalRemaining(int minutes) {
    return '$minutes min left';
  }

  @override
  String get monthlyGoals => 'Monthly reading goals';

  @override
  String get monthlyGoalDescription =>
      'Track minutes, pages, or completed books each month.';

  @override
  String get configure => 'Configure';

  @override
  String get monthlyMinutes => 'Reading minutes';

  @override
  String get monthlyPages => 'Pages read';

  @override
  String get monthlyBooks => 'Completed books';

  @override
  String get monthlyGoalSuggestions =>
      'Suggested minute targets: 300, 600, 1,000, or 1,500';

  @override
  String get noMonthlyGoals => 'Set one or more goals to track this month.';

  @override
  String get monthlyGoalsAchieved => 'Monthly goals achieved!';

  @override
  String monthlyGoalRemaining(int remaining, String unit) {
    return '$remaining $unit remaining';
  }

  @override
  String get startReading => 'Start reading';

  @override
  String get pauseReading => 'Pause';

  @override
  String get resumeReading => 'Resume';

  @override
  String get finishReading => 'Finish session';

  @override
  String get averageDailyReading => 'Average daily reading';

  @override
  String get averageSession => 'Average session';

  @override
  String get totalSessions => 'Reading sessions';

  @override
  String get mostActiveDay => 'Most active day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get readingConsistency => 'Reading consistency (last 14 days)';

  @override
  String get dailyHistory => 'Daily reading history';

  @override
  String get bookProgress => 'Reading progress per book';

  @override
  String get noReadingData => 'No reading data for this period.';

  @override
  String get startReadingForStats =>
      'Start reading to see your personal insights.';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get bookmarkTitle => 'Bookmark title';

  @override
  String get bookmarkTitleHint => 'Optional title';

  @override
  String get annotations => 'Annotations';

  @override
  String get highlight => 'Highlight';

  @override
  String get highlights => 'Highlights';

  @override
  String get saveHighlight => 'Save highlight';

  @override
  String get noBookmarks => 'No bookmarks saved.';

  @override
  String get noHighlights => 'No highlights saved.';

  @override
  String get edit => 'Edit';

  @override
  String get notes => 'Notes';

  @override
  String get newNote => 'New note';

  @override
  String get editNote => 'Edit note';

  @override
  String get noteHint => 'Write your thoughts...';

  @override
  String get linkNoteToPage => 'Link note to this page';

  @override
  String get generalNote => 'General note';

  @override
  String get searchNotes => 'Search notes';

  @override
  String get noNotes => 'No notes yet.';

  @override
  String get noMatchingNotes => 'No notes match your search.';

  @override
  String noteUpdatedAt(String date) {
    return 'Updated $date';
  }

  @override
  String get readingJournal => 'Reading journal';

  @override
  String get newJournalEntry => 'New journal entry';

  @override
  String get editJournalEntry => 'Edit journal entry';

  @override
  String get writeReflection => 'Write reflection';

  @override
  String get searchJournal => 'Search journal';

  @override
  String get emptyJournal => 'Your reading reflections will appear here.';

  @override
  String get journalTitle => 'Title';

  @override
  String get journalTitleHint => 'Give this reflection a title';

  @override
  String get associatedBook => 'Associated book';

  @override
  String get noAssociatedBook => 'No associated book';

  @override
  String get pageReferenceOptional => 'Page reference (optional)';

  @override
  String get pageReferenceHint => 'Page number';

  @override
  String get reflection => 'Reflection';

  @override
  String get reflectionHint =>
      'Take a quiet moment to write about your reading...';

  @override
  String get journalPrompts => 'Optional prompts';

  @override
  String get promptLearned => 'What did you learn today?';

  @override
  String get promptIdea => 'What idea interested you most?';

  @override
  String get promptPassage => 'What passage would you like to remember?';

  @override
  String get promptFeeling => 'How did this reading make you feel?';

  @override
  String get untitledJournalEntry => 'Untitled reflection';

  @override
  String get deleteJournalEntry => 'Delete journal entry?';

  @override
  String get deleteJournalEntryBody =>
      'This reflection will be permanently deleted.';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementStreaks => 'Reading streak';

  @override
  String get achievementTime => 'Reading time';

  @override
  String get achievementProgress => 'Reading progress';

  @override
  String achievementsProgress(Object total, Object unlocked) {
    return '$unlocked of $total achievements unlocked';
  }

  @override
  String achievementUnlocked(Object title) {
    return 'Achievement unlocked: $title';
  }

  @override
  String achievementUnlockedDate(Object date) {
    return 'Unlocked $date';
  }

  @override
  String achievementStreakDescription(Object days) {
    return 'Reach a $days-day reading streak.';
  }

  @override
  String achievementMinutesDescription(Object hours) {
    return 'Read for $hours hours in total.';
  }

  @override
  String achievementPagesDescription(Object pages) {
    return 'Read $pages pages in total.';
  }

  @override
  String achievementBooksDescription(Object books) {
    return 'Complete $books books.';
  }

  @override
  String get achievementFirstDay => 'First day';

  @override
  String get achievementThreeDayStreak => '3-day streak';

  @override
  String get achievementSevenDayStreak => '7-day streak';

  @override
  String get achievementFourteenDayStreak => '14-day streak';

  @override
  String get achievementThirtyDayStreak => '30-day streak';

  @override
  String get achievementHundredDayStreak => '100-day streak';

  @override
  String get achievementFirstHour => 'First hour';

  @override
  String get achievementTenHours => '10 hours';

  @override
  String get achievementFiftyHours => '50 hours';

  @override
  String get achievementHundredHours => '100 hours';

  @override
  String get achievementFirstHundredPages => 'First 100 pages';

  @override
  String get achievementFiveHundredPages => '500 pages';

  @override
  String get achievementThousandPages => '1,000 pages';

  @override
  String get achievementFirstCompletedBook => 'First completed book';

  @override
  String get achievementFiveCompletedBooks => '5 completed books';

  @override
  String get achievementTenCompletedBooks => '10 completed books';
}
