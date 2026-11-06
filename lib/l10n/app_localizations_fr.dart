// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Streak Reader';

  @override
  String get booksLibrary => 'Bibliothèque';

  @override
  String get statistics => 'Statistiques';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get noBooksYet =>
      'Aucun livre pour le moment\nAjoutez un livre en touchant +';

  @override
  String get addBook => 'Ajouter un livre';

  @override
  String get bookTitle => 'Titre du livre';

  @override
  String get choosePdfFile => 'Choisir un fichier PDF';

  @override
  String get titleOnlyHint =>
      'Vous pouvez ajouter juste un titre à votre liste « À lire »';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'OK';

  @override
  String get editTitle => 'Modifier le titre';

  @override
  String get missingFileWarning => 'Attention : fichier manquant ou déplacé';

  @override
  String get wantToReadNoFile => 'À lire (sans fichier)';

  @override
  String get fileNotFoundTitle => 'Fichier introuvable';

  @override
  String get fileNotFoundBody =>
      'Le fichier a été déplacé ou supprimé de l\'appareil.\nCe livre ne peut pas être ouvert.';

  @override
  String get noFileTitle => 'Aucun fichier';

  @override
  String get noFileBody =>
      'Ce livre n\'a pas de fichier PDF.\nAjoutez un fichier PDF pour l\'ouvrir dans le lecteur.';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get readerFileMissing =>
      'Le fichier n\'existe pas.\nIl a été déplacé ou supprimé de l\'appareil.';

  @override
  String get currentStreak => 'Série actuelle';

  @override
  String get longestStreak => 'Meilleure série';

  @override
  String get totalReading => 'Lecture totale';

  @override
  String get pagesRead => 'Pages lues';

  @override
  String get completedBooks => 'Livres terminés';

  @override
  String get day => 'jour';

  @override
  String get minute => 'min';

  @override
  String get page => 'page';

  @override
  String get book => 'livre';

  @override
  String errorMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get addPdf => 'Ajouter un PDF';

  @override
  String get changePdf => 'Changer de PDF';

  @override
  String get attachPdfWebUnsupported =>
      'L\'ajout d\'un fichier PDF n\'est pas encore pris en charge sur le web. Utilisez l\'application mobile ou de bureau.';

  @override
  String get yourBooks => 'Vos livres';

  @override
  String pageNumberLabel(int page) {
    return 'Page $page';
  }

  @override
  String streakGoalHint(int minutes) {
    return 'Lisez $minutes minutes aujourd\'hui pour garder votre série.';
  }

  @override
  String get readingOverview => 'Aperçu de lecture';

  @override
  String get appTagline => 'Un peu de lecture chaque jour fait la différence.';

  @override
  String get addBookSubtitle =>
      'Choisissez un PDF ou ajoutez-le à votre liste « À lire ».';
}
