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
}
