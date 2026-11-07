import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Reader'**
  String get appTitle;

  /// No description provided for @booksLibrary.
  ///
  /// In en, this message translates to:
  /// **'Book Library'**
  String get booksLibrary;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @readingReminder.
  ///
  /// In en, this message translates to:
  /// **'Reading reminder'**
  String get readingReminder;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders enabled'**
  String get reminderEnabled;

  /// No description provided for @reminderDisabled.
  ///
  /// In en, this message translates to:
  /// **'Reminders disabled'**
  String get reminderDisabled;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @reminderDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get reminderDays;

  /// No description provided for @reminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification message'**
  String get reminderMessage;

  /// No description provided for @reminderMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Time for your daily reading session.'**
  String get reminderMessageHint;

  /// No description provided for @reminderPermissionHint.
  ///
  /// In en, this message translates to:
  /// **'Your device may ask permission before showing notifications.'**
  String get reminderPermissionHint;

  /// No description provided for @reminderMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get reminderMonday;

  /// No description provided for @reminderTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get reminderTuesday;

  /// No description provided for @reminderWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get reminderWednesday;

  /// No description provided for @reminderThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get reminderThursday;

  /// No description provided for @reminderFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get reminderFriday;

  /// No description provided for @reminderSaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get reminderSaturday;

  /// No description provided for @reminderSunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get reminderSunday;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @noBooksYet.
  ///
  /// In en, this message translates to:
  /// **'No books yet\nAdd a book by tapping +'**
  String get noBooksYet;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get addBook;

  /// No description provided for @bookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book title'**
  String get bookTitle;

  /// No description provided for @choosePdfFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF file'**
  String get choosePdfFile;

  /// No description provided for @titleOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'You can add just a title to your \"Want to read\" list'**
  String get titleOnlyHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get editTitle;

  /// No description provided for @missingFileWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: file is missing or was moved'**
  String get missingFileWarning;

  /// No description provided for @wantToReadNoFile.
  ///
  /// In en, this message translates to:
  /// **'Want to read (no file)'**
  String get wantToReadNoFile;

  /// No description provided for @fileNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFoundTitle;

  /// No description provided for @fileNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The file was moved or deleted from the device.\nThis book cannot be opened.'**
  String get fileNotFoundBody;

  /// No description provided for @noFileTitle.
  ///
  /// In en, this message translates to:
  /// **'No file'**
  String get noFileTitle;

  /// No description provided for @noFileBody.
  ///
  /// In en, this message translates to:
  /// **'This book has no PDF file.\nAdd a PDF file to open it in the reader.'**
  String get noFileBody;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @readerFileMissing.
  ///
  /// In en, this message translates to:
  /// **'The file does not exist.\nIt was moved or deleted from the device.'**
  String get readerFileMissing;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get longestStreak;

  /// No description provided for @totalReading.
  ///
  /// In en, this message translates to:
  /// **'Total reading'**
  String get totalReading;

  /// No description provided for @pagesRead.
  ///
  /// In en, this message translates to:
  /// **'Pages read'**
  String get pagesRead;

  /// No description provided for @completedBooks.
  ///
  /// In en, this message translates to:
  /// **'Completed books'**
  String get completedBooks;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minute;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'page'**
  String get page;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'book'**
  String get book;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// No description provided for @addPdf.
  ///
  /// In en, this message translates to:
  /// **'Add PDF'**
  String get addPdf;

  /// No description provided for @changePdf.
  ///
  /// In en, this message translates to:
  /// **'Change PDF'**
  String get changePdf;

  /// No description provided for @attachPdfWebUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Attaching a PDF is not supported on web yet. Please use the mobile or desktop app.'**
  String get attachPdfWebUnsupported;

  /// No description provided for @yourBooks.
  ///
  /// In en, this message translates to:
  /// **'Your books'**
  String get yourBooks;

  /// No description provided for @pageNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String pageNumberLabel(int page);

  /// No description provided for @streakGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Read {minutes} minutes today to keep your streak alive.'**
  String streakGoalHint(int minutes);

  /// No description provided for @readingOverview.
  ///
  /// In en, this message translates to:
  /// **'Reading overview'**
  String get readingOverview;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'A little reading every day adds up.'**
  String get appTagline;

  /// No description provided for @addBookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF or save it to your wishlist.'**
  String get addBookSubtitle;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markAsCompleted;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @deleteBook.
  ///
  /// In en, this message translates to:
  /// **'Delete book'**
  String get deleteBook;

  /// No description provided for @deleteBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete book?'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes \"{title}\" and its reading sessions.'**
  String deleteBookBody(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @bookDeleted.
  ///
  /// In en, this message translates to:
  /// **'Book deleted.'**
  String get bookDeleted;

  /// No description provided for @currentlyReading.
  ///
  /// In en, this message translates to:
  /// **'Currently reading'**
  String get currentlyReading;

  /// No description provided for @wantToRead.
  ///
  /// In en, this message translates to:
  /// **'Want to read'**
  String get wantToRead;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @abandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get abandoned;

  /// No description provided for @searchBooks.
  ///
  /// In en, this message translates to:
  /// **'Search books'**
  String get searchBooks;

  /// No description provided for @allBooks.
  ///
  /// In en, this message translates to:
  /// **'All books'**
  String get allBooks;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortRecent;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @sortProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get sortProgress;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get newCollection;

  /// No description provided for @collectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get collectionName;

  /// No description provided for @authorOptional.
  ///
  /// In en, this message translates to:
  /// **'Author (optional)'**
  String get authorOptional;

  /// No description provided for @totalPagesOptional.
  ///
  /// In en, this message translates to:
  /// **'Total pages (optional)'**
  String get totalPagesOptional;

  /// No description provided for @bookDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'More book details'**
  String get bookDetailsOptional;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @collectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get collectionDescription;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a book title.'**
  String get titleRequired;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @readerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not open this PDF.'**
  String get readerLoadError;

  /// No description provided for @loadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF…'**
  String get loadingPdf;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. Please try again.'**
  String get saveFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the book. Please try again.'**
  String get deleteFailed;

  /// No description provided for @readingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Reading calendar'**
  String get readingCalendar;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved'**
  String get goalAchieved;

  /// No description provided for @goalNotAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal not achieved'**
  String get goalNotAchieved;

  /// No description provided for @readingActivity.
  ///
  /// In en, this message translates to:
  /// **'Reading activity'**
  String get readingActivity;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get noActivity;

  /// No description provided for @noReadingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No reading activity this month.'**
  String get noReadingThisMonth;

  /// No description provided for @monthSummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly summary'**
  String get monthSummary;

  /// No description provided for @activeReadingDays.
  ///
  /// In en, this message translates to:
  /// **'Active reading days'**
  String get activeReadingDays;

  /// No description provided for @readingDuration.
  ///
  /// In en, this message translates to:
  /// **'Reading duration'**
  String get readingDuration;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String minutesShort(int minutes);

  /// No description provided for @dailyReadingGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily reading goal'**
  String get dailyReadingGoal;

  /// No description provided for @dailyGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how many minutes you want to read each day.'**
  String get dailyGoalDescription;

  /// No description provided for @currentGoal.
  ///
  /// In en, this message translates to:
  /// **'Current goal'**
  String get currentGoal;

  /// No description provided for @customGoal.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customGoal;

  /// No description provided for @customGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom daily goal'**
  String get customGoalTitle;

  /// No description provided for @customGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Minutes per day'**
  String get customGoalHint;

  /// No description provided for @customGoalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between {min} and {max}.'**
  String customGoalInvalid(int min, int max);

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{minutes} / {goal} min'**
  String dailyGoalProgress(int minutes, int goal);

  /// No description provided for @dailyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Daily goal completed!'**
  String get dailyGoalReached;

  /// No description provided for @dailyGoalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String dailyGoalRemaining(int minutes);

  /// No description provided for @monthlyGoals.
  ///
  /// In en, this message translates to:
  /// **'Monthly reading goals'**
  String get monthlyGoals;

  /// No description provided for @monthlyGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Track minutes, pages, or completed books each month.'**
  String get monthlyGoalDescription;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @monthlyMinutes.
  ///
  /// In en, this message translates to:
  /// **'Reading minutes'**
  String get monthlyMinutes;

  /// No description provided for @monthlyPages.
  ///
  /// In en, this message translates to:
  /// **'Pages read'**
  String get monthlyPages;

  /// No description provided for @monthlyBooks.
  ///
  /// In en, this message translates to:
  /// **'Completed books'**
  String get monthlyBooks;

  /// No description provided for @monthlyGoalSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested minute targets: 300, 600, 1,000, or 1,500'**
  String get monthlyGoalSuggestions;

  /// No description provided for @noMonthlyGoals.
  ///
  /// In en, this message translates to:
  /// **'Set one or more goals to track this month.'**
  String get noMonthlyGoals;

  /// No description provided for @monthlyGoalsAchieved.
  ///
  /// In en, this message translates to:
  /// **'Monthly goals achieved!'**
  String get monthlyGoalsAchieved;

  /// No description provided for @monthlyGoalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} {unit} remaining'**
  String monthlyGoalRemaining(int remaining, String unit);

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get startReading;

  /// No description provided for @pauseReading.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseReading;

  /// No description provided for @resumeReading.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeReading;

  /// No description provided for @finishReading.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get finishReading;

  /// No description provided for @averageDailyReading.
  ///
  /// In en, this message translates to:
  /// **'Average daily reading'**
  String get averageDailyReading;

  /// No description provided for @averageSession.
  ///
  /// In en, this message translates to:
  /// **'Average session'**
  String get averageSession;

  /// No description provided for @totalSessions.
  ///
  /// In en, this message translates to:
  /// **'Reading sessions'**
  String get totalSessions;

  /// No description provided for @mostActiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most active day'**
  String get mostActiveDay;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @readingConsistency.
  ///
  /// In en, this message translates to:
  /// **'Reading consistency (last 14 days)'**
  String get readingConsistency;

  /// No description provided for @dailyHistory.
  ///
  /// In en, this message translates to:
  /// **'Daily reading history'**
  String get dailyHistory;

  /// No description provided for @bookProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading progress per book'**
  String get bookProgress;

  /// No description provided for @noReadingData.
  ///
  /// In en, this message translates to:
  /// **'No reading data for this period.'**
  String get noReadingData;

  /// No description provided for @startReadingForStats.
  ///
  /// In en, this message translates to:
  /// **'Start reading to see your personal insights.'**
  String get startReadingForStats;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @bookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmark title'**
  String get bookmarkTitle;

  /// No description provided for @bookmarkTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Optional title'**
  String get bookmarkTitleHint;

  /// No description provided for @annotations.
  ///
  /// In en, this message translates to:
  /// **'Annotations'**
  String get annotations;

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlight;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @saveHighlight.
  ///
  /// In en, this message translates to:
  /// **'Save highlight'**
  String get saveHighlight;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks saved.'**
  String get noBookmarks;

  /// No description provided for @noHighlights.
  ///
  /// In en, this message translates to:
  /// **'No highlights saved.'**
  String get noHighlights;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts...'**
  String get noteHint;

  /// No description provided for @linkNoteToPage.
  ///
  /// In en, this message translates to:
  /// **'Link note to this page'**
  String get linkNoteToPage;

  /// No description provided for @generalNote.
  ///
  /// In en, this message translates to:
  /// **'General note'**
  String get generalNote;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotes;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get noNotes;

  /// No description provided for @noMatchingNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes match your search.'**
  String get noMatchingNotes;

  /// No description provided for @noteUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String noteUpdatedAt(String date);

  /// No description provided for @readingJournal.
  ///
  /// In en, this message translates to:
  /// **'Reading journal'**
  String get readingJournal;

  /// No description provided for @newJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'New journal entry'**
  String get newJournalEntry;

  /// No description provided for @editJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit journal entry'**
  String get editJournalEntry;

  /// No description provided for @writeReflection.
  ///
  /// In en, this message translates to:
  /// **'Write reflection'**
  String get writeReflection;

  /// No description provided for @searchJournal.
  ///
  /// In en, this message translates to:
  /// **'Search journal'**
  String get searchJournal;

  /// No description provided for @emptyJournal.
  ///
  /// In en, this message translates to:
  /// **'Your reading reflections will appear here.'**
  String get emptyJournal;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get journalTitle;

  /// No description provided for @journalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Give this reflection a title'**
  String get journalTitleHint;

  /// No description provided for @associatedBook.
  ///
  /// In en, this message translates to:
  /// **'Associated book'**
  String get associatedBook;

  /// No description provided for @noAssociatedBook.
  ///
  /// In en, this message translates to:
  /// **'No associated book'**
  String get noAssociatedBook;

  /// No description provided for @pageReferenceOptional.
  ///
  /// In en, this message translates to:
  /// **'Page reference (optional)'**
  String get pageReferenceOptional;

  /// No description provided for @pageReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Page number'**
  String get pageReferenceHint;

  /// No description provided for @reflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// No description provided for @reflectionHint.
  ///
  /// In en, this message translates to:
  /// **'Take a quiet moment to write about your reading...'**
  String get reflectionHint;

  /// No description provided for @journalPrompts.
  ///
  /// In en, this message translates to:
  /// **'Optional prompts'**
  String get journalPrompts;

  /// No description provided for @promptLearned.
  ///
  /// In en, this message translates to:
  /// **'What did you learn today?'**
  String get promptLearned;

  /// No description provided for @promptIdea.
  ///
  /// In en, this message translates to:
  /// **'What idea interested you most?'**
  String get promptIdea;

  /// No description provided for @promptPassage.
  ///
  /// In en, this message translates to:
  /// **'What passage would you like to remember?'**
  String get promptPassage;

  /// No description provided for @promptFeeling.
  ///
  /// In en, this message translates to:
  /// **'How did this reading make you feel?'**
  String get promptFeeling;

  /// No description provided for @untitledJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Untitled reflection'**
  String get untitledJournalEntry;

  /// No description provided for @deleteJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete journal entry?'**
  String get deleteJournalEntry;

  /// No description provided for @deleteJournalEntryBody.
  ///
  /// In en, this message translates to:
  /// **'This reflection will be permanently deleted.'**
  String get deleteJournalEntryBody;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementStreaks.
  ///
  /// In en, this message translates to:
  /// **'Reading streak'**
  String get achievementStreaks;

  /// No description provided for @achievementTime.
  ///
  /// In en, this message translates to:
  /// **'Reading time'**
  String get achievementTime;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading progress'**
  String get achievementProgress;

  /// No description provided for @achievementsProgress.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} achievements unlocked'**
  String achievementsProgress(Object total, Object unlocked);

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked: {title}'**
  String achievementUnlocked(Object title);

  /// No description provided for @achievementUnlockedDate.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String achievementUnlockedDate(Object date);

  /// No description provided for @achievementStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach a {days}-day reading streak.'**
  String achievementStreakDescription(Object days);

  /// No description provided for @achievementMinutesDescription.
  ///
  /// In en, this message translates to:
  /// **'Read for {hours} hours in total.'**
  String achievementMinutesDescription(Object hours);

  /// No description provided for @achievementPagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Read {pages} pages in total.'**
  String achievementPagesDescription(Object pages);

  /// No description provided for @achievementBooksDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete {books} books.'**
  String achievementBooksDescription(Object books);

  /// No description provided for @achievementFirstDay.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get achievementFirstDay;

  /// No description provided for @achievementThreeDayStreak.
  ///
  /// In en, this message translates to:
  /// **'3-day streak'**
  String get achievementThreeDayStreak;

  /// No description provided for @achievementSevenDayStreak.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get achievementSevenDayStreak;

  /// No description provided for @achievementFourteenDayStreak.
  ///
  /// In en, this message translates to:
  /// **'14-day streak'**
  String get achievementFourteenDayStreak;

  /// No description provided for @achievementThirtyDayStreak.
  ///
  /// In en, this message translates to:
  /// **'30-day streak'**
  String get achievementThirtyDayStreak;

  /// No description provided for @achievementHundredDayStreak.
  ///
  /// In en, this message translates to:
  /// **'100-day streak'**
  String get achievementHundredDayStreak;

  /// No description provided for @achievementFirstHour.
  ///
  /// In en, this message translates to:
  /// **'First hour'**
  String get achievementFirstHour;

  /// No description provided for @achievementTenHours.
  ///
  /// In en, this message translates to:
  /// **'10 hours'**
  String get achievementTenHours;

  /// No description provided for @achievementFiftyHours.
  ///
  /// In en, this message translates to:
  /// **'50 hours'**
  String get achievementFiftyHours;

  /// No description provided for @achievementHundredHours.
  ///
  /// In en, this message translates to:
  /// **'100 hours'**
  String get achievementHundredHours;

  /// No description provided for @achievementFirstHundredPages.
  ///
  /// In en, this message translates to:
  /// **'First 100 pages'**
  String get achievementFirstHundredPages;

  /// No description provided for @achievementFiveHundredPages.
  ///
  /// In en, this message translates to:
  /// **'500 pages'**
  String get achievementFiveHundredPages;

  /// No description provided for @achievementThousandPages.
  ///
  /// In en, this message translates to:
  /// **'1,000 pages'**
  String get achievementThousandPages;

  /// No description provided for @achievementFirstCompletedBook.
  ///
  /// In en, this message translates to:
  /// **'First completed book'**
  String get achievementFirstCompletedBook;

  /// No description provided for @achievementFiveCompletedBooks.
  ///
  /// In en, this message translates to:
  /// **'5 completed books'**
  String get achievementFiveCompletedBooks;

  /// No description provided for @achievementTenCompletedBooks.
  ///
  /// In en, this message translates to:
  /// **'10 completed books'**
  String get achievementTenCompletedBooks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
