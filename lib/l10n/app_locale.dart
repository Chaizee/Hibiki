import 'package:flutter/material.dart';

enum AppLocale {
  en,
  ru;

  String get code => this == AppLocale.ru ? 'ru' : 'en';

  Locale get flutterLocale => Locale(code);

  static AppLocale fromCode(String? code) {
    if (code == 'ru') return AppLocale.ru;
    return AppLocale.en;
  }
}
