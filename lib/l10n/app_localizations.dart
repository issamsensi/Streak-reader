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
