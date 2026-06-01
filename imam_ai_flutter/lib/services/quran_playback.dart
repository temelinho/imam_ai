import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'quran_audio_handler.dart';

/// Uygulama genelinde sesli Kuran — bildirim çubuğu ve arka plan oynatma.
class QuranPlayback {
  QuranPlayback._();

  static QuranAudioHandler? _handler;
  static Future<QuranAudioHandler>? _initFuture;

  static bool get isReady => _handler != null;

  static Future<QuranAudioHandler> ensureInit() {
    if (_handler != null) return Future.value(_handler!);
    _initFuture ??= _initWithTimeout();
    return _initFuture!;
  }

  static QuranAudioHandler get handler {
    if (_handler == null) {
      throw StateError('QuranPlayback.ensureInit() must complete first');
    }
    return _handler!;
  }

  static Future<void> _ensureAndroidNotificationPermission() async {
    if (kIsWeb) return;
    final android = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<QuranAudioHandler> _initWithTimeout() async {
    try {
      await _ensureAndroidNotificationPermission();
      _handler = await AudioService.init(
        builder: () => QuranAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.imamai.quran.audio',
          androidNotificationChannelName: 'Kuran Dinleme',
          androidNotificationChannelDescription: 'Sesli Kuran oynatma kontrolleri',
          // ongoing=true iken stopForegroundOnPause=false kullanılamaz (audio_service kuralı).
          // false/false: duraklatınca bildirim ve arka plan oynatma kontrolleri kalır.
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: false,
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidShowNotificationBadge: true,
          androidNotificationClickStartsActivity: true,
          preloadArtwork: false,
        ),
      ).timeout(const Duration(seconds: 15));
      return _handler!;
    } catch (e) {
      _initFuture = null;
      rethrow;
    }
  }

  @Deprecated('Use ensureInit()')
  static Future<QuranAudioHandler> init() => ensureInit();
}
