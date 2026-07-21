import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const _prefKey = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    const migrateKey = 'theme_migrated_light_v1';
    if (!(prefs.getBool(migrateKey) ?? false)) {
      await prefs.setString(_prefKey, 'light');
      await prefs.setBool(migrateKey, true);
      return ThemeMode.light;
    }
    final saved = prefs.getString(_prefKey);
    return switch (saved) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.valueOrNull == mode) return;
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await prefs.setString(_prefKey, value);
  }

  static String labelAr(ThemeMode mode, Brightness brightness) {
    return switch (mode) {
      ThemeMode.light => 'فاتح',
      ThemeMode.dark => 'داكن',
      ThemeMode.system => brightness == Brightness.dark
          ? 'تلقائي (داكن)'
          : 'تلقائي (فاتح)',
    };
  }

  static String labelEn(ThemeMode mode, Brightness brightness) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => brightness == Brightness.dark
          ? 'System (Dark)'
          : 'System (Light)',
    };
  }
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final themeModeSyncProvider = Provider<ThemeMode>(
  (ref) => ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.light,
);
