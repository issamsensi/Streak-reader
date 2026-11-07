import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/daily_goal_history.dart';

class AppSettings {
  final String languageCode;
  final ThemeMode themeMode;
  final int dailyGoalMinutes;
  final DailyGoalHistory dailyGoalHistory;

  const AppSettings({
    this.languageCode = 'ar',
    this.themeMode = ThemeMode.system,
    this.dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes,
    this.dailyGoalHistory = const DailyGoalHistory(),
  });

  Locale get locale => Locale(languageCode);

  AppSettings copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    int? dailyGoalMinutes,
    DailyGoalHistory? dailyGoalHistory,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      dailyGoalHistory: dailyGoalHistory ?? this.dailyGoalHistory,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  static const _languageKey = 'settings_language_code';
  static const _themeKey = 'settings_theme_mode';
  static const _dailyGoalHistoryKey = 'settings_daily_goal_history';

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
    );
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
}

final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(),
);
