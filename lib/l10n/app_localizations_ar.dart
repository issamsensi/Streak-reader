// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Streak Reader';

  @override
  String get booksLibrary => 'مكتبة الكتب';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get noBooksYet => 'لا توجد كتب بعد\nأضف كتاباً بالضغط على +';

  @override
  String get addBook => 'إضافة كتاب';

  @override
  String get bookTitle => 'عنوان الكتاب';

  @override
  String get choosePdfFile => 'اختيار ملف PDF';

  @override
  String get titleOnlyHint => 'يمكنك إضافة عنوان فقط لقائمة \"أريد قراءته\"';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسناً';

  @override
  String get editTitle => 'تعديل العنوان';

  @override
  String get missingFileWarning => 'تحذير: الملف مفقود أو تم نقله';

  @override
  String get wantToReadNoFile => 'أريد قراءته (بدون ملف)';

  @override
  String get fileNotFoundTitle => 'الملف غير موجود';

  @override
  String get fileNotFoundBody =>
      'تم نقل الملف أو حذفه من الجهاز.\nلا يمكن فتح هذا الكتاب.';

  @override
  String get noFileTitle => 'لا يوجد ملف';

  @override
  String get noFileBody =>
      'هذا الكتاب بدون ملف PDF.\nأضف ملف PDF لفتحه في القارئ.';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get readerFileMissing =>
      'الملف غير موجود.\nتم نقله أو حذفه من الجهاز.';

  @override
  String get currentStreak => 'الستريك الحالي';

  @override
  String get longestStreak => 'أعلى ستريك';

  @override
  String get totalReading => 'إجمالي القراءة';

  @override
  String get pagesRead => 'الصفحات المقروءة';

  @override
  String get completedBooks => 'الكتب المكتملة';

  @override
  String get day => 'يوم';

  @override
  String get minute => 'دقيقة';

  @override
  String get page => 'صفحة';

  @override
  String get book => 'كتاب';

  @override
  String errorMessage(String error) {
    return 'خطأ: $error';
  }

  @override
  String get addPdf => 'إضافة ملف PDF';

  @override
  String get changePdf => 'تغيير ملف PDF';

  @override
  String get attachPdfWebUnsupported =>
      'إرفاق ملف PDF غير مدعوم على الويب بعد. استخدم تطبيق الهاتف أو الحاسوب.';

  @override
  String get yourBooks => 'كتبك';

  @override
  String pageNumberLabel(int page) {
    return 'صفحة $page';
  }

  @override
  String streakGoalHint(int minutes) {
    return 'اقرأ $minutes دقائق اليوم لتحافظ على سلسلتك.';
  }

  @override
  String get readingOverview => 'نظرة عامة على القراءة';

  @override
  String get appTagline => 'قليل من القراءة كل يوم يصنع فرقاً.';

  @override
  String get addBookSubtitle =>
      'اختر ملف PDF أو أضفه إلى قائمة \"أريد قراءته\".';

  @override
  String get markAsCompleted => 'وضع علامة كمكتمل';

  @override
  String get markAsUnread => 'وضع علامة كغير مقروء';

  @override
  String get completed => 'مكتمل';

  @override
  String get deleteBook => 'حذف الكتاب';

  @override
  String get deleteBookTitle => 'حذف الكتاب؟';

  @override
  String deleteBookBody(String title) {
    return 'سيتم حذف \"$title\" وجلسات القراءة الخاصة به نهائياً.';
  }

  @override
  String get delete => 'حذف';

  @override
  String get bookDeleted => 'تم حذف الكتاب.';

  @override
  String get currentlyReading => 'تقرأ حالياً';

  @override
  String get wantToRead => 'أريد قراءته';

  @override
  String get paused => 'متوقف مؤقتاً';

  @override
  String get abandoned => 'متروك';

  @override
  String get searchBooks => 'البحث في الكتب';

  @override
  String get allBooks => 'كل الكتب';

  @override
  String get sortRecent => 'المضافة حديثاً';

  @override
  String get sortTitle => 'العنوان';

  @override
  String get sortProgress => 'التقدم';

  @override
  String get newCollection => 'مجموعة جديدة';

  @override
  String get collectionName => 'اسم المجموعة';

  @override
  String get authorOptional => 'المؤلف (اختياري)';

  @override
  String get totalPagesOptional => 'إجمالي الصفحات (اختياري)';

  @override
  String get bookDetailsOptional => 'تفاصيل إضافية للكتاب';

  @override
  String get search => 'بحث';

  @override
  String get clear => 'مسح';

  @override
  String get collections => 'المجموعات';

  @override
  String get collectionDescription => 'الوصف (اختياري)';

  @override
  String get titleRequired => 'يرجى إدخال عنوان الكتاب.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get readerLoadError => 'تعذر فتح ملف PDF.';

  @override
  String get loadingPdf => 'جارٍ تجهيز ملف PDF…';

  @override
  String get saveFailed => 'تعذر حفظ التغييرات. حاول مرة أخرى.';

  @override
  String get deleteFailed => 'تعذر حذف الكتاب. حاول مرة أخرى.';

  @override
  String get readingCalendar => 'تقويم القراءة';

  @override
  String get today => 'اليوم';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String get goalAchieved => 'تم تحقيق الهدف';

  @override
  String get goalNotAchieved => 'لم يتم تحقيق الهدف';

  @override
  String get readingActivity => 'نشاط قراءة';

  @override
  String get noActivity => 'لا يوجد نشاط';

  @override
  String get noReadingThisMonth => 'لا يوجد نشاط قراءة هذا الشهر.';

  @override
  String get monthSummary => 'ملخص الشهر';

  @override
  String get activeReadingDays => 'أيام القراءة النشطة';

  @override
  String get readingDuration => 'مدة القراءة';

  @override
  String get sessions => 'الجلسات';

  @override
  String minutesShort(int minutes) {
    return '$minutes د';
  }

  @override
  String get dailyReadingGoal => 'هدف القراءة اليومي';

  @override
  String get dailyGoalDescription =>
      'اختر عدد الدقائق التي تريد قراءتها كل يوم.';

  @override
  String get currentGoal => 'الهدف الحالي';

  @override
  String get customGoal => 'مخصص';

  @override
  String get customGoalTitle => 'هدف يومي مخصص';

  @override
  String get customGoalHint => 'عدد الدقائق يومياً';

  @override
  String customGoalInvalid(int min, int max) {
    return 'أدخل عدداً بين $min و$max.';
  }

  @override
  String dailyGoalProgress(int minutes, int goal) {
    return '$minutes / $goal دقيقة';
  }

  @override
  String get dailyGoalReached => 'تم إنجاز الهدف اليومي!';

  @override
  String dailyGoalRemaining(int minutes) {
    return 'متبقٍ $minutes دقيقة';
  }

  @override
  String get monthlyGoals => 'أهداف القراءة الشهرية';

  @override
  String get monthlyGoalDescription =>
      'تتبع الدقائق أو الصفحات أو الكتب المكتملة كل شهر.';

  @override
  String get configure => 'إعداد';

  @override
  String get monthlyMinutes => 'دقائق القراءة';

  @override
  String get monthlyPages => 'الصفحات المقروءة';

  @override
  String get monthlyBooks => 'الكتب المكتملة';

  @override
  String get monthlyGoalSuggestions =>
      'أهداف الدقائق المقترحة: 300 أو 600 أو 1,000 أو 1,500';

  @override
  String get noMonthlyGoals => 'أضف هدفاً واحداً أو أكثر لتتبع هذا الشهر.';

  @override
  String get monthlyGoalsAchieved => 'تم تحقيق الأهداف الشهرية!';

  @override
  String monthlyGoalRemaining(int remaining, String unit) {
    return 'متبقٍ $remaining $unit';
  }

  @override
  String get startReading => 'بدء القراءة';

  @override
  String get pauseReading => 'إيقاف مؤقت';

  @override
  String get resumeReading => 'استئناف';

  @override
  String get finishReading => 'إنهاء الجلسة';

  @override
  String get averageDailyReading => 'متوسط القراءة اليومية';

  @override
  String get averageSession => 'متوسط الجلسة';

  @override
  String get totalSessions => 'جلسات القراءة';

  @override
  String get mostActiveDay => 'أكثر يوم نشاطاً';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get year => 'سنة';

  @override
  String get readingConsistency => 'استمرارية القراءة (آخر 14 يوماً)';

  @override
  String get dailyHistory => 'سجل القراءة اليومي';

  @override
  String get bookProgress => 'تقدم القراءة لكل كتاب';

  @override
  String get noReadingData => 'لا توجد بيانات قراءة لهذه الفترة.';

  @override
  String get startReadingForStats => 'ابدأ القراءة لرؤية إحصاءاتك.';

  @override
  String get bookmark => 'إشارة مرجعية';

  @override
  String get bookmarks => 'الإشارات المرجعية';

  @override
  String get bookmarkTitle => 'عنوان الإشارة المرجعية';

  @override
  String get bookmarkTitleHint => 'عنوان اختياري';

  @override
  String get annotations => 'التعليقات والعلامات';

  @override
  String get highlight => 'تمييز';

  @override
  String get highlights => 'النصوص المميزة';

  @override
  String get saveHighlight => 'حفظ التمييز';

  @override
  String get noBookmarks => 'لا توجد إشارات مرجعية محفوظة.';

  @override
  String get noHighlights => 'لا توجد نصوص مميزة محفوظة.';

  @override
  String get edit => 'تعديل';

  @override
  String get notes => 'الملاحظات';

  @override
  String get newNote => 'ملاحظة جديدة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get noteHint => 'اكتب أفكارك...';

  @override
  String get linkNoteToPage => 'ربط الملاحظة بهذه الصفحة';

  @override
  String get generalNote => 'ملاحظة عامة';

  @override
  String get searchNotes => 'البحث في الملاحظات';

  @override
  String get noNotes => 'لا توجد ملاحظات بعد.';

  @override
  String get noMatchingNotes => 'لا توجد ملاحظات مطابقة للبحث.';

  @override
  String noteUpdatedAt(String date) {
    return 'آخر تعديل: $date';
  }

  @override
  String get readingJournal => 'يوميات القراءة';

  @override
  String get newJournalEntry => 'إدخال يوميات جديد';

  @override
  String get editJournalEntry => 'تعديل إدخال اليوميات';

  @override
  String get writeReflection => 'اكتب تأملك';

  @override
  String get searchJournal => 'البحث في اليوميات';

  @override
  String get emptyJournal => 'ستظهر تأملاتك القرائية هنا.';

  @override
  String get journalTitle => 'العنوان';

  @override
  String get journalTitleHint => 'أضف عنواناً لهذا التأمل';

  @override
  String get associatedBook => 'الكتاب المرتبط';

  @override
  String get noAssociatedBook => 'بدون كتاب مرتبط';

  @override
  String get pageReferenceOptional => 'مرجع الصفحة (اختياري)';

  @override
  String get pageReferenceHint => 'رقم الصفحة';

  @override
  String get reflection => 'التأمل';

  @override
  String get reflectionHint => 'خذ لحظة هادئة واكتب عن قراءتك...';

  @override
  String get journalPrompts => 'أسئلة اختيارية';

  @override
  String get promptLearned => 'ماذا تعلمت اليوم؟';

  @override
  String get promptIdea => 'ما الفكرة التي أثارت اهتمامك؟';

  @override
  String get promptPassage => 'ما المقطع الذي تود تذكره؟';

  @override
  String get promptFeeling => 'كيف جعلتك هذه القراءة تشعر؟';

  @override
  String get untitledJournalEntry => 'تأمل بلا عنوان';

  @override
  String get deleteJournalEntry => 'حذف إدخال اليوميات؟';

  @override
  String get deleteJournalEntryBody => 'سيتم حذف هذا التأمل نهائياً.';
}
