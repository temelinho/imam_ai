import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/city_coordinates.dart';
import '../location/location_scope.dart';
import '../l10n/l10n_scope.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

class QiblaScreen extends StatefulWidget {
  final String selectedCity;

  const QiblaScreen({
    super.key,
    required this.selectedCity,
  });

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  double _qiblaAngle = 213.0;
  double _distanceToMecca = 1847.0;

  double? _deviceHeading;
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _isAligned = false;
  LocationService? _locationService;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _initCompass();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = LocationScope.of(context);
    if (_locationService != loc) {
      _locationService?.removeListener(_onLocationChanged);
      _locationService = loc;
      _locationService!.addListener(_onLocationChanged);
      _recomputeFromLocation();
    }
  }

  void _onLocationChanged() => _recomputeFromLocation();

  void _recomputeFromLocation() {
    final loc = _locationService;
    if (loc == null) return;
    final coords = loc.coordsOrCityFallback(widget.selectedCity);
    _computeValues(coords[0], coords[1]);
  }

  void _initCompass() {
    try {
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (!mounted) return;
        final heading = event.heading;
        if (heading != null) {
          double diff = (_qiblaAngle - heading).abs() % 360;
          if (diff > 180) diff = 360 - diff;
          final isAligned = diff < 5.0;
          if (isAligned && !_isAligned) {
            HapticFeedback.lightImpact();
          }
          setState(() {
            _deviceHeading = heading;
            _isAligned = isAligned;
          });
        }
      });
    } catch (_) {}
  }

  void _computeValues(double lat, double lon) {
    const double kaabaLat = 21.4225;
    const double kaabaLon = 39.8262;

    final latRad = lat * math.pi / 180.0;
    final lonRad = lon * math.pi / 180.0;
    final kaabaLatRad = kaabaLat * math.pi / 180.0;
    final kaabaLonRad = kaabaLon * math.pi / 180.0;
    final dLon = kaabaLonRad - lonRad;

    final y = math.sin(dLon);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) - math.sin(latRad) * math.cos(dLon);
    double qiblaAngle = math.atan2(y, x) * 180.0 / math.pi;
    qiblaAngle = (qiblaAngle + 360.0) % 360.0;

    final distance = CityCoordinates.haversineKm(lat, lon, kaabaLat, kaabaLon);

    setState(() {
      _qiblaAngle = qiblaAngle;
      _distanceToMecca = distance;
    });
    _animationController.reset();
    _animationController.forward();
  }

  String _getDirectionName(double angle, AppLocalizations l10n) {
    if (angle >= 337.5 || angle < 22.5) return l10n.directionName('Kuzey');
    if (angle >= 22.5 && angle < 67.5) return l10n.directionName('Kuzeydoğu');
    if (angle >= 67.5 && angle < 112.5) return l10n.directionName('Doğu');
    if (angle >= 112.5 && angle < 157.5) return l10n.directionName('Güneydoğu');
    if (angle >= 157.5 && angle < 202.5) return l10n.directionName('Güney');
    if (angle >= 202.5 && angle < 247.5) return l10n.directionName('Güneybatı');
    if (angle >= 247.5 && angle < 292.5) return l10n.directionName('Batı');
    return l10n.directionName('Kuzeybatı');
  }

  String _sourceLabel(AppLocalizations l10n, LocationService loc) {
    if (loc.fromGps) return l10n.qiblaByGps;
    if (loc.nearestCity != null) {
      return l10n.qiblaByCityNamed(loc.nearestCity!);
    }
    return l10n.qiblaByCityNamed(widget.selectedCity);
  }

  @override
  void dispose() {
    _locationService?.removeListener(_onLocationChanged);
    _compassSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nScope.of(context);
    final loc = LocationScope.of(context);
    final displayCity = loc.fromGps ? (loc.nearestCity ?? widget.selectedCity) : widget.selectedCity;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                loc.fromGps ? Icons.gps_fixed : Icons.location_city,
                size: 11,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _sourceLabel(l10n, loc),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (loc.loading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                ),
              ],
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => loc.refresh(),
                child: const Icon(Icons.refresh, size: 18, color: Colors.grey),
              ),
            ],
          ),
          if (loc.permissionDenied || loc.serviceDisabled) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => loc.refresh(),
              icon: const Icon(Icons.location_disabled, size: 16),
              label: Text(l10n.enableLocation),
            ),
          ],
          const Spacer(),
          Builder(
            builder: (context) {
              final dialRotation = _deviceHeading != null ? -_deviceHeading! * math.pi / 180.0 : 0.0;
              final arrowRotation = _deviceHeading != null
                  ? (_qiblaAngle - _deviceHeading!) * math.pi / 180.0
                  : (_qiblaAngle * _animation.value) * math.pi / 180.0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: dialRotation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: _isAligned ? AppColors.surface : AppColors.surface2,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isAligned ? Colors.amber : AppColors.primary,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isAligned ? Colors.amber : AppColors.primary)
                                    .withOpacity(_isAligned ? 0.25 : 0.06),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text('K', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text('G', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text('D', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text('B', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Transform.rotate(
                            angle: _qiblaAngle * math.pi / 180.0,
                            child: const Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Text('🕋', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: arrowRotation,
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 10,
                            bottom: 70,
                            child: Container(
                              width: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isAligned
                                      ? [Colors.amber, Colors.orange]
                                      : [AppColors.primaryLight, AppColors.primary],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Icon(
                              Icons.arrow_drop_up_rounded,
                              size: 32,
                              color: _isAligned ? Colors.amber : AppColors.primary,
                            ),
                          ),
                          Positioned(
                            top: 70,
                            bottom: 25,
                            child: Container(width: 4, color: Colors.grey.withOpacity(0.4)),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _isAligned ? Colors.amber : AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _deviceHeading != null ? '${_deviceHeading!.toStringAsFixed(0)}°' : '${_qiblaAngle.toStringAsFixed(0)}°',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          if (_deviceHeading != null) ...[
            Text(
              _isAligned ? l10n.qiblaAligned : l10n.qiblaFollow,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: _isAligned ? AppColors.amberDark : AppColors.primaryDark,
              ),
            ),
          ] else ...[
            Text(
              l10n.qiblaDirection(_getDirectionName(_qiblaAngle, l10n)),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
          ],
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  l10n.qiblaDistance(displayCity),
                  style: const TextStyle(fontSize: 13.5, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_distanceToMecca.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} km',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
