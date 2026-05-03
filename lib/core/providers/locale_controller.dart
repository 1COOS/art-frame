import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_controller.g.dart';

const _localeStorageKey = 'app_locale';

@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale? build() {
    _loadPersistedLocale();
    return null;
  }

  Future<void> _loadPersistedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localeStorageKey);
    if (stored != null && stored.isNotEmpty) {
      state = Locale(stored);
    }
  }

  Future<void> update(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeStorageKey, locale.languageCode);
  }
}
