import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';

class LocaleController extends ChangeNotifier {
  static const _prefKey = 'app_locale_v1';

  AppLocale _locale = AppLocale.en;

  AppLocale get locale => _locale;
  AppStrings get strings => AppStrings(_locale);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = AppLocale.fromCode(prefs.getString(_prefKey));
    notifyListeners();
  }

  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.code);
    notifyListeners();
  }
}
