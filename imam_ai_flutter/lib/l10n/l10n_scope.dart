import 'package:flutter/material.dart';
import '../services/locale_service.dart';
import 'app_localizations.dart';

class L10nScope extends InheritedNotifier<LocaleService> {
  const L10nScope({
    super.key,
    required LocaleService localeService,
    required super.child,
  }) : super(notifier: localeService);

  static AppLocalizations of(BuildContext context) {
    final service = context.dependOnInheritedWidgetOfExactType<L10nScope>()?.notifier;
    if (service == null) {
      return AppLocalizations(const Locale('tr'));
    }
    return AppLocalizations(service.locale);
  }

  static LocaleService localeServiceOf(BuildContext context) {
    final service = context.dependOnInheritedWidgetOfExactType<L10nScope>()?.notifier;
    assert(service != null, 'L10nScope not found');
    return service!;
  }
}
