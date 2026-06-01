import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/quran_playback.dart';
import 'services/locale_service.dart';
import 'services/location_service.dart';
import 'l10n/l10n_scope.dart';
import 'location/location_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeService = LocaleService();
  await localeService.load();

  final locationService = LocationService();
  await locationService.loadCached();

  runApp(ImamAIApp(
    localeService: localeService,
    locationService: locationService,
  ));

  // Arayüz hemen açılsın; ağır işler arkada yüklensin.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_deferredStartup(locationService));
  });
}

Future<void> _deferredStartup(LocationService locationService) async {
  try {
    await Future.wait([
      initializeDateFormatting('tr_TR', null),
      initializeDateFormatting('ar', null),
    ]);
  } catch (_) {}

  unawaited(locationService.startBackgroundUpdates());
  unawaited(NotificationService().init());
  unawaited(QuranPlayback.ensureInit());
}

class ImamAIApp extends StatelessWidget {
  final LocaleService localeService;
  final LocationService locationService;

  const ImamAIApp({
    super.key,
    required this.localeService,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeService,
      builder: (context, _) {
        return LocationScope(
          locationService: locationService,
          child: L10nScope(
            localeService: localeService,
            child: MaterialApp(
              title: 'İmam AI',
              debugShowCheckedModeBanner: false,
              locale: localeService.locale,
              supportedLocales: const [
                Locale('tr'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.lightTheme(localeService.isArabic),
              builder: (context, child) {
                return Directionality(
                  textDirection: localeService.isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: const HomeScreen(),
            ),
          ),
        );
      },
    );
  }
}
