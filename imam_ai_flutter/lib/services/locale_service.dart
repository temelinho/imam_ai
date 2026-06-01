import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Uygulama dili: Türkçe (tr) veya Arapça (ar).
class LocaleService extends ChangeNotifier {
  static const String prefKey = 'app_language';

  Locale _locale = const Locale('tr');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isArabic => languageCode == 'ar';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(prefKey) ?? 'tr';
    _locale = Locale(code == 'ar' ? 'ar' : 'tr');
    notifyListeners();
    unawaited(_initDateFormatting());
  }

  Future<void> setLanguage(String code) async {
    final normalized = code == 'ar' ? 'ar' : 'tr';
    if (_locale.languageCode == normalized) return;
    _locale = Locale(normalized);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, normalized);
    await _initDateFormatting();
    notifyListeners();
  }

  Future<void> _initDateFormatting() async {
    await initializeDateFormatting(isArabic ? 'ar' : 'tr_TR', null);
  }

  String datePattern() => isArabic ? 'dd MMMM yyyy' : 'dd MMMM yyyy';
  String dateLocaleTag() => isArabic ? 'ar' : 'tr_TR';
}
