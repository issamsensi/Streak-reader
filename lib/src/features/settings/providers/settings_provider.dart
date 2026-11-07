import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/daily_goal_history.dart';
import '../../../domain/entities/focus_mode_preferences.dart';
import '../../../domain/entities/monthly_goal.dart';
import '../../../domain/entities/reading_reminder.dart';
import '../../../domain/entities/streak_protection.dart';
import '../../../core/notifications/reading_reminder_service.dart';

class AppSettings {
  final String languageCode;
  final ThemeMode themeMode;
  final int dailyGoalMinutes;
  final DailyGoalHistory dailyGoalHistory;
  final MonthlyGoalHistory monthlyGoalHistory;
  final Map<String, Set<int>> completedBookHistory;
  final ReadingReminderSettings readingReminder;
  final StreakProtection streakProtection;
  final FocusModePreferences focusMode;

  const AppSettings({
    this.languageCode = 'ar',
    this.themeMode = ThemeMode.system,
    this.dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes,
    this.dailyGoalHistory = const DailyGoalHistory(),
    this.monthlyGoalHistory = const MonthlyGoalHistory(),
    this.completedBookHistory = const {},
    this.readingReminder = const ReadingReminderSettings(),
    this.streakProtection = const StreakProtection(),
    this.focusMode = const FocusModePreferences(),
  });

  Locale get locale => Locale(languageCode);

  AppSettings copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    int? dailyGoalMinutes,
    DailyGoalHistory? dailyGoalHistory,
    MonthlyGoalHistory? monthlyGoalHistory,
    Map<String, Set<int>>? completedBookHistory,
    ReadingReminderSettings? readingReminder,
    StreakProtection? streakProtection,
    FocusModePreferences? focusMode,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      dailyGoalHistory: dailyGoalHistory ?? this.dailyGoalHistory,
      monthlyGoalHistory: monthlyGoalHistory ?? this.monthlyGoalHistory,
      completedBookHistory: completedBookHistory ?? this.completedBookHistory,
      readingReminder: readingReminder ?? this.readingReminder,
      streakProtection: streakProtection ?? this.streakProtection,
      focusMode: focusMode ?? this.focusMode,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  static const _languageKey = 'settings_language_code';
  static const _themeKey = 'settings_theme_mode';
  static const _dailyGoalHistoryKey = 'settings_daily_goal_history';
  static const _monthlyGoalHistoryKey = 'settings_monthly_goal_history';
  static const _completedBookHistoryKey = 'settings_completed_book_history';
  static const _readingReminderKey = 'settings_reading_reminder';
  static const _streakProtectionKey = 'settings_streak_protection';
  static const _focusModeKey = 'settings_focus_mode';

  final DateTime Function() _now;
  late final Future<void> initialized;

  SettingsController({DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(const AppSettings()) {
    initialized = _load();
  }

  Future<void> _load() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Settings are optional for read-only consumers (for example tests or
      // platforms without the preferences plugin); keep the defaults.
      return;
    }
    final language = prefs.getString(_languageKey);
    final theme = prefs.getString(_themeKey);
    final history = _readGoalHistory(prefs.getString(_dailyGoalHistoryKey));
    final monthlyHistory =
        _readMonthlyGoalHistory(prefs.getString(_monthlyGoalHistoryKey));
    final completedHistory =
        _readCompletedBookHistory(prefs.getString(_completedBookHistoryKey));
    final reminder = _readReminder(prefs.getString(_readingReminderKey));
    final protection = _readProtection(
      prefs.getString(_streakProtectionKey),
    );
    final focusMode = _readFocusMode(prefs.getString(_focusModeKey));
    state = AppSettings(
      languageCode: switch (language) {
        'ar' || 'en' || 'fr' => language!,
        _ => 'ar',
      },
      themeMode: switch (theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      dailyGoalMinutes: history.minutesForDate(_now()),
      dailyGoalHistory: history,
      monthlyGoalHistory: monthlyHistory,
      completedBookHistory: completedHistory,
      readingReminder: reminder,
      streakProtection: protection,
      focusMode: focusMode,
    );
  }

  FocusModePreferences _readFocusMode(String? raw) {
    if (raw == null || raw.isEmpty) return const FocusModePreferences();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return FocusModePreferences.fromMap(decoded);
    } on FormatException {
      // Corrupted preferences should not prevent the app from starting.
    }
    return const FocusModePreferences();
  }

  Future<void> setFocusMode(FocusModePreferences preferences) async {
    state = state.copyWith(focusMode: preferences);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_focusModeKey, jsonEncode(preferences.toMap()));
  }

  StreakProtection _readProtection(String? raw) {
    if (raw == null || raw.isEmpty) return const StreakProtection();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return StreakProtection.fromMap(decoded);
    } on FormatException {
      // Corrupted preferences should not prevent the app from starting.
    }
    return const StreakProtection();
  }

  ReadingReminderSettings _readReminder(String? raw) {
    if (raw == null || raw.isEmpty) return const ReadingReminderSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return ReadingReminderSettings.fromMap(decoded);
    } on FormatException {
      // Corrupted preferences should not prevent the app from starting.
    }
    return const ReadingReminderSettings();
  }

  MonthlyGoalHistory _readMonthlyGoalHistory(String? raw) {
    if (raw == null || raw.isEmpty) return const MonthlyGoalHistory();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return MonthlyGoalHistory.fromMap(decoded);
    } on FormatException {
      // Corrupted preferences should not prevent the app from starting.
    }
    return const MonthlyGoalHistory();
  }

  Map<String, Set<int>> _readCompletedBookHistory(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is List)
            entry.key as String: {
              for (final id in entry.value)
                if (id is num) id.toInt(),
            },
      };
    } on FormatException {
      return const {};
    }
  }

  DailyGoalHistory _readGoalHistory(String? raw) {
    if (raw == null || raw.isEmpty) return const DailyGoalHistory();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return DailyGoalHistory.fromMap(decoded);
    } on FormatException {
      // Corrupted preferences should not prevent the app from starting.
    }
    return const DailyGoalHistory();
  }

  Future<void> setLanguage(String code) async {
    if (code != 'ar' && code != 'en' && code != 'fr') return;
    state = state.copyWith(languageCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  /// Applies [minutes] from today onward without changing earlier days.
  Future<void> setDailyGoal(int minutes) async {
    if (!AppConstants.isValidDailyGoal(minutes)) return;
    final history = state.dailyGoalHistory.withGoalFrom(_now(), minutes);
    state = state.copyWith(
      dailyGoalMinutes: minutes,
      dailyGoalHistory: history,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyGoalHistoryKey, jsonEncode(history.toMap()));
  }

  Future<void> setMonthlyGoal(DateTime month, MonthlyGoal goal) async {
    final history = state.monthlyGoalHistory.withGoalFor(month, goal);
    state = state.copyWith(monthlyGoalHistory: history);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_monthlyGoalHistoryKey, jsonEncode(history.toMap()));
  }

  Future<void> recordBookCompletion(int bookId, DateTime date) async {
    if (bookId <= 0) return;
    final key = MonthlyGoalHistory.monthKey(date);
    final history = {
      for (final entry in state.completedBookHistory.entries)
        entry.key: {...entry.value},
    };
    history.putIfAbsent(key, () => <int>{}).add(bookId);
    state = state.copyWith(completedBookHistory: history);
    final serializable = {
      for (final entry in history.entries) entry.key: entry.value.toList(),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedBookHistoryKey, jsonEncode(serializable));
  }

  Future<void> setReadingReminder(ReadingReminderSettings reminder) async {
    if (reminder.days.isEmpty && reminder.enabled) return;
    state = state.copyWith(readingReminder: reminder);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingReminderKey, jsonEncode(reminder.toMap()));
    await ReadingReminderService.instance.configure(
      reminder,
      goalCompleted: false,
    );
  }

  int protectionCreditsFor(int longestStreak) {
    final earned = [
      if (longestStreak >= 7) 'streak_7',
      if (longestStreak >= 30) 'streak_30',
      if (longestStreak >= 100) 'streak_100',
    ];
    return (earned.length - state.streakProtection.history.length)
        .clamp(0, earned.length);
  }

  Future<bool> protectDate(String dateKey, int longestStreak) async {
    if (state.streakProtection.history.containsKey(dateKey)) return false;
    if (protectionCreditsFor(longestStreak) <= 0) return false;
    final protection = state.streakProtection.protect(dateKey, DateTime.now());
    state = state.copyWith(streakProtection: protection);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _streakProtectionKey,
      jsonEncode(protection.toMap()),
    );
    return true;
  }
}

final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(),
);
