import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String languageCode;
  final ThemeMode themeMode;

  const AppSettings(
      {this.languageCode = 'ar', this.themeMode = ThemeMode.system});

  Locale get locale => Locale(languageCode);

  AppSettings copyWith({String? languageCode, ThemeMode? themeMode}) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  static const _languageKey = 'settings_language_code';
  static const _themeKey = 'settings_theme_mode';

  SettingsController() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString(_languageKey);
    final theme = prefs.getString(_themeKey);
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
    );
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
}

final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(),
);
