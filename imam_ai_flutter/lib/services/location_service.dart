import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/city_coordinates.dart';

/// Uygulama genelinde canlı GPS konumu ve en yakın şehir.
class LocationService extends ChangeNotifier {
  static const String prefLat = 'last_lat';
  static const String prefLon = 'last_lon';
  static const String prefNearestCity = 'last_nearest_city';
  static const String prefFromGps = 'last_from_gps';

  double? _latitude;
  double? _longitude;
  String? _nearestCity;
  bool _fromGps = false;
  bool _loading = false;
  bool _permissionDenied = false;
  bool _serviceDisabled = false;
  StreamSubscription<Position>? _positionSub;
  DateTime? _lastNotifyAt;
  Timer? _saveDebounce;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get nearestCity => _nearestCity;
  bool get fromGps => _fromGps;
  bool get loading => _loading;
  bool get permissionDenied => _permissionDenied;
  bool get serviceDisabled => _serviceDisabled;
  bool get hasLocation => _latitude != null && _longitude != null;

  List<double> coordsOrCityFallback(String fallbackCity) {
    if (hasLocation) return [_latitude!, _longitude!];
    final c = CityCoordinates.coords[fallbackCity] ?? CityCoordinates.coords['Malatya']!;
    return [c[0], c[1]];
  }

  /// Hızlı açılış: sadece önbellek, GPS beklemez.
  Future<void> loadCached() async {
    await _loadCached();
    if (!hasLocation) _applyCityFallback();
    notifyListeners();
  }

  /// GPS ve konum akışı — uygulama açıldıktan sonra arka planda.
  Future<void> startBackgroundUpdates() async {
    await refresh();
    _startPositionStream();
  }

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(prefLat);
    final lon = prefs.getDouble(prefLon);
    if (lat != null && lon != null) {
      _latitude = lat;
      _longitude = lon;
      _nearestCity = prefs.getString(prefNearestCity) ?? CityCoordinates.nearestCity(lat, lon);
      _fromGps = prefs.getBool(prefFromGps) ?? false;
    }
  }

  void _scheduleSaveCache() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(seconds: 30), () {
      _saveCache();
    });
  }

  Future<void> _saveCache() async {
    if (!hasLocation) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prefLat, _latitude!);
    await prefs.setDouble(prefLon, _longitude!);
    if (_nearestCity != null) {
      await prefs.setString(prefNearestCity, _nearestCity!);
    }
    await prefs.setBool(prefFromGps, _fromGps);
  }

  Future<bool> _ensurePermission() async {
    _serviceDisabled = !await Geolocator.isLocationServiceEnabled();
    if (_serviceDisabled) {
      _permissionDenied = false;
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    _permissionDenied = permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever;
    return !_permissionDenied;
  }

  Future<void> refresh() async {
    _loading = true;
    _notifyThrottled(force: true);

    try {
      final ok = await _ensurePermission();
      if (!ok) {
        _applyCityFallback();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );
      _applyPosition(position, forceNotify: true);
    } catch (_) {
      if (!hasLocation) _applyCityFallback();
    } finally {
      _loading = false;
      _notifyThrottled(force: true);
    }
  }

  void _startPositionStream() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 150,
      ),
    ).listen(
      (position) => _applyPosition(position),
      onError: (_) {},
    );
  }

  void _applyPosition(Position position, {bool forceNotify = false}) {
    _latitude = position.latitude;
    _longitude = position.longitude;
    _fromGps = true;
    _permissionDenied = false;
    _serviceDisabled = false;
    final city = CityCoordinates.nearestCity(position.latitude, position.longitude);
    final cityChanged = _nearestCity != city;
    _nearestCity = city;
    if (cityChanged) {
      _saveCache();
    } else {
      _scheduleSaveCache();
    }
    _notifyThrottled(force: forceNotify || cityChanged);
  }

  void _notifyThrottled({bool force = false}) {
    final now = DateTime.now();
    if (!force &&
        _lastNotifyAt != null &&
        now.difference(_lastNotifyAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastNotifyAt = now;
    notifyListeners();
  }

  void _applyCityFallback() {
    if (hasLocation && _fromGps) return;
    const fallback = 'Malatya';
    final c = CityCoordinates.coords[fallback]!;
    _latitude = c[0];
    _longitude = c[1];
    _nearestCity = fallback;
    _fromGps = false;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _saveDebounce?.cancel();
    super.dispose();
  }
}
