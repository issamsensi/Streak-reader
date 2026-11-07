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

  @override
  String get markAsCompleted => 'Marquer comme terminé';

  @override
  String get markAsUnread => 'Marquer comme non lu';

  @override
  String get completed => 'Terminé';

  @override
  String get deleteBook => 'Supprimer le livre';

  @override
  String get deleteBookTitle => 'Supprimer le livre ?';

  @override
  String deleteBookBody(String title) {
    return 'Cela supprime définitivement \"$title\" et ses sessions de lecture.';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get bookDeleted => 'Livre supprimé.';

  @override
  String get currentlyReading => 'En cours de lecture';

  @override
  String get wantToRead => 'À lire';

  @override
  String get paused => 'En pause';

  @override
  String get abandoned => 'Abandonné';

  @override
  String get searchBooks => 'Rechercher des livres';

  @override
  String get allBooks => 'Tous les livres';

  @override
  String get sortRecent => 'Ajoutés récemment';

  @override
  String get sortTitle => 'Titre';

  @override
  String get sortProgress => 'Progression';

  @override
  String get newCollection => 'Nouvelle collection';

  @override
  String get collectionName => 'Nom de la collection';

  @override
  String get authorOptional => 'Auteur (facultatif)';

  @override
  String get totalPagesOptional => 'Pages totales (facultatif)';

  @override
  String get bookDetailsOptional => 'Détails supplémentaires';

  @override
  String get search => 'Rechercher';

  @override
  String get clear => 'Effacer';

  @override
  String get collections => 'Collections';

  @override
  String get collectionDescription => 'Description (facultatif)';

  @override
  String get titleRequired => 'Veuillez saisir un titre de livre.';

  @override
  String get retry => 'Réessayer';

  @override
  String get readerLoadError => 'Impossible d\'ouvrir ce PDF.';

  @override
  String get loadingPdf => 'Préparation du PDF…';

  @override
  String get saveFailed =>
      'Impossible d\'enregistrer les modifications. Réessayez.';

  @override
  String get deleteFailed => 'Impossible de supprimer le livre. Réessayez.';

  @override
  String get readingCalendar => 'Calendrier de lecture';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get previousMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String get dailyGoal => 'Objectif quotidien';

  @override
  String get goalAchieved => 'Objectif atteint';

  @override
  String get goalNotAchieved => 'Objectif non atteint';

  @override
  String get readingActivity => 'Activité de lecture';

  @override
  String get noActivity => 'Aucune activité';

  @override
  String get noReadingThisMonth => 'Aucune activité de lecture ce mois-ci.';

  @override
  String get monthSummary => 'Résumé mensuel';

  @override
  String get activeReadingDays => 'Jours de lecture actifs';

  @override
  String get readingDuration => 'Durée de lecture';

  @override
  String get sessions => 'Sessions';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get dailyReadingGoal => 'Objectif de lecture quotidien';

  @override
  String get dailyGoalDescription =>
      'Choisissez le nombre de minutes à lire chaque jour.';

  @override
  String get currentGoal => 'Objectif actuel';

  @override
  String get customGoal => 'Personnalisé';

  @override
  String get customGoalTitle => 'Objectif quotidien personnalisé';

  @override
  String get customGoalHint => 'Minutes par jour';

  @override
  String customGoalInvalid(int min, int max) {
    return 'Saisissez un nombre entre $min et $max.';
  }

  @override
  String dailyGoalProgress(int minutes, int goal) {
    return '$minutes / $goal min';
  }

  @override
  String get dailyGoalReached => 'Objectif quotidien atteint !';

  @override
  String dailyGoalRemaining(int minutes) {
    return 'Encore $minutes min';
  }

  @override
  String get monthlyGoals => 'Objectifs de lecture mensuels';

  @override
  String get monthlyGoalDescription =>
      'Suivez les minutes, pages ou livres terminés chaque mois.';

  @override
  String get configure => 'Configurer';

  @override
  String get monthlyMinutes => 'Minutes de lecture';

  @override
  String get monthlyPages => 'Pages lues';

  @override
  String get monthlyBooks => 'Livres terminés';

  @override
  String get monthlyGoalSuggestions =>
      'Suggestions en minutes : 300, 600, 1 000 ou 1 500';

  @override
  String get noMonthlyGoals =>
      'Configurez un ou plusieurs objectifs pour ce mois.';

  @override
  String get monthlyGoalsAchieved => 'Objectifs mensuels atteints !';

  @override
  String monthlyGoalRemaining(int remaining, String unit) {
    return 'Encore $remaining $unit';
  }

  @override
  String get startReading => 'Commencer la lecture';

  @override
  String get pauseReading => 'Pause';

  @override
  String get resumeReading => 'Reprendre';

  @override
  String get finishReading => 'Terminer la session';

  @override
  String get averageDailyReading => 'Lecture quotidienne moyenne';

  @override
  String get averageSession => 'Session moyenne';

  @override
  String get totalSessions => 'Sessions de lecture';

  @override
  String get mostActiveDay => 'Jour le plus actif';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get readingConsistency => 'Régularité de lecture (14 derniers jours)';

  @override
  String get dailyHistory => 'Historique quotidien';

  @override
  String get bookProgress => 'Progression par livre';

  @override
  String get noReadingData => 'Aucune donnée de lecture pour cette période.';

  @override
  String get startReadingForStats =>
      'Commencez à lire pour voir vos statistiques.';

  @override
  String get bookmark => 'Signet';

  @override
  String get bookmarks => 'Signets';

  @override
  String get bookmarkTitle => 'Titre du signet';

  @override
  String get bookmarkTitleHint => 'Titre facultatif';

  @override
  String get annotations => 'Annotations';

  @override
  String get highlight => 'Surlignage';

  @override
  String get highlights => 'Surlignages';

  @override
  String get saveHighlight => 'Enregistrer le surlignage';

  @override
  String get noBookmarks => 'Aucun signet enregistré.';

  @override
  String get noHighlights => 'Aucun surlignage enregistré.';

  @override
  String get edit => 'Modifier';

  @override
  String get notes => 'Notes';

  @override
  String get newNote => 'Nouvelle note';

  @override
  String get editNote => 'Modifier la note';

  @override
  String get noteHint => 'Écrivez vos réflexions...';

  @override
  String get linkNoteToPage => 'Lier la note à cette page';

  @override
  String get generalNote => 'Note générale';

  @override
  String get searchNotes => 'Rechercher dans les notes';

  @override
  String get noNotes => 'Aucune note pour le moment.';

  @override
  String get noMatchingNotes => 'Aucune note ne correspond à la recherche.';

  @override
  String noteUpdatedAt(String date) {
    return 'Modifiée le $date';
  }

  @override
  String get readingJournal => 'Journal de lecture';

  @override
  String get newJournalEntry => 'Nouvelle entrée';

  @override
  String get editJournalEntry => 'Modifier l\'entrée';

  @override
  String get writeReflection => 'Écrire une réflexion';

  @override
  String get searchJournal => 'Rechercher dans le journal';

  @override
  String get emptyJournal => 'Vos réflexions de lecture apparaîtront ici.';

  @override
  String get journalTitle => 'Titre';

  @override
  String get journalTitleHint => 'Donnez un titre à cette réflexion';

  @override
  String get associatedBook => 'Livre associé';

  @override
  String get noAssociatedBook => 'Aucun livre associé';

  @override
  String get pageReferenceOptional => 'Référence de page (facultatif)';

  @override
  String get pageReferenceHint => 'Numéro de page';

  @override
  String get reflection => 'Réflexion';

  @override
  String get reflectionHint =>
      'Prenez un moment calme pour écrire sur votre lecture...';

  @override
  String get journalPrompts => 'Questions facultatives';

  @override
  String get promptLearned => 'Qu\'avez-vous appris aujourd\'hui ?';

  @override
  String get promptIdea => 'Quelle idée vous a le plus intéressé ?';

  @override
  String get promptPassage => 'Quel passage aimeriez-vous retenir ?';

  @override
  String get promptFeeling =>
      'Comment cette lecture vous a-t-elle fait sentir ?';

  @override
  String get untitledJournalEntry => 'Réflexion sans titre';

  @override
  String get deleteJournalEntry => 'Supprimer l\'entrée ?';

  @override
  String get deleteJournalEntryBody =>
      'Cette réflexion sera définitivement supprimée.';

  @override
  String get achievements => 'Succès';

  @override
  String get achievementStreaks => 'Série de lecture';

  @override
  String get achievementTime => 'Temps de lecture';

  @override
  String get achievementProgress => 'Progression de lecture';

  @override
  String achievementsProgress(Object total, Object unlocked) {
    return '$unlocked succès sur $total débloqués';
  }

  @override
  String achievementUnlocked(Object title) {
    return 'Succès débloqué : $title';
  }

  @override
  String achievementUnlockedDate(Object date) {
    return 'Débloqué le $date';
  }

  @override
  String achievementStreakDescription(Object days) {
    return 'Atteignez une série de lecture de $days jours.';
  }

  @override
  String achievementMinutesDescription(Object hours) {
    return 'Lisez $hours heures au total.';
  }

  @override
  String achievementPagesDescription(Object pages) {
    return 'Lisez $pages pages au total.';
  }

  @override
  String achievementBooksDescription(Object books) {
    return 'Terminez $books livres.';
  }

  @override
  String get achievementFirstDay => 'Premier jour';

  @override
  String get achievementThreeDayStreak => 'Série de 3 jours';

  @override
  String get achievementSevenDayStreak => 'Série de 7 jours';

  @override
  String get achievementFourteenDayStreak => 'Série de 14 jours';

  @override
  String get achievementThirtyDayStreak => 'Série de 30 jours';

  @override
  String get achievementHundredDayStreak => 'Série de 100 jours';

  @override
  String get achievementFirstHour => 'Première heure';

  @override
  String get achievementTenHours => '10 heures';

  @override
  String get achievementFiftyHours => '50 heures';

  @override
  String get achievementHundredHours => '100 heures';

  @override
  String get achievementFirstHundredPages => 'Premières 100 pages';

  @override
  String get achievementFiveHundredPages => '500 pages';

  @override
  String get achievementThousandPages => '1 000 pages';

  @override
  String get achievementFirstCompletedBook => 'Premier livre terminé';

  @override
  String get achievementFiveCompletedBooks => '5 livres terminés';

  @override
  String get achievementTenCompletedBooks => '10 livres terminés';
}
