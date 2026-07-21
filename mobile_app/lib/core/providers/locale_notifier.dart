import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('language_code');
    if (code == null || (code != 'ar' && code != 'en')) {
      final device =
          ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      code = device.startsWith('en') ? 'en' : 'ar';
      await prefs.setString('language_code', code);
    }
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    if (state.valueOrNull == locale) return;
    state = AsyncData(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final current = state.valueOrNull ?? const Locale('ar');
    await setLocale(
      current.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
    );
  }
}

final localeProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

final localeSyncProvider = Provider<Locale>(
  (ref) => ref.watch(localeProvider).valueOrNull ?? const Locale('ar'),
);

final isArabicProvider = Provider<bool>(
  (ref) => ref.watch(localeSyncProvider).languageCode == 'ar',
);
