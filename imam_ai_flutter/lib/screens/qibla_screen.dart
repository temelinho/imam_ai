import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../core/theme/app_colors.dart';

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
  double _qiblaAngle = 213.0; // Fallback for Malatya
  double _distanceToMecca = 1847.0; // Fallback for Malatya
  String _sourceText = 'Şehir konumuna göre hesaplandı';
  bool _isLoading = false;
  
  double? _deviceHeading;
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _isAligned = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  // City Coordinates Map
  static const Map<String, List<double>> _cityCoords = {
    'Malatya': [38.3552, 38.3093],
    'İstanbul': [41.0082, 28.9784],
    'Ankara': [39.9334, 32.8597],
    'İzmir': [38.4192, 27.1287],
    'Bursa': [40.1826, 29.0667],
    'Antalya': [36.8969, 30.7133],
    'Adana': [36.9914, 35.3289],
    'Konya': [37.8714, 32.4847],
    'Trabzon': [41.0027, 39.7168],
    'Diyarbakır': [37.9144, 40.2306],
    'Gaziantep': [37.0662, 37.3833],
  };

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

    _calculateQiblaFromCity();
    _checkGPSLocation();
    _initCompass();
  }

  void _initCompass() {
    try {
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (!mounted) return;
        final heading = event.heading;
        if (heading != null) {
          // Calculate alignment with Qibla
          double diff = (_qiblaAngle - heading).abs() % 360;
          if (diff > 180) {
            diff = 360 - diff;
          }
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
    } catch (e) {
      // Compass not supported
    }
  }

  @override
  void didUpdateWidget(covariant QiblaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCity != widget.selectedCity) {
      _calculateQiblaFromCity();
    }
  }

  void _calculateQiblaFromCity() {
    final coords = _cityCoords[widget.selectedCity] ?? [38.3552, 38.3093];
    _computeValues(coords[0], coords[1]);
    setState(() {
      _sourceText = '${widget.selectedCity} konumuna göre hesaplandı';
    });
  }

  Future<void> _checkGPSLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      _computeValues(position.latitude, position.longitude);
      setState(() {
        _sourceText = 'GPS ile hesaplandı';
      });
    } catch (e) {
      // Keep city fallbacks on exception
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _computeValues(double lat, double lon) {
    // Kaaba coordinates
    const double kaabaLat = 21.4225;
    const double kaabaLon = 39.8262;

    // Calculate Qibla angle (bearing)
    double latRad = lat * math.pi / 180.0;
    double lonRad = lon * math.pi / 180.0;
    double kaabaLatRad = kaabaLat * math.pi / 180.0;
    double kaabaLonRad = kaabaLon * math.pi / 180.0;

    double dLon = kaabaLonRad - lonRad;

    double y = math.sin(dLon);
    double x = math.cos(latRad) * math.tan(kaabaLatRad) -
        math.sin(latRad) * math.cos(dLon);

    double qiblaAngle = math.atan2(y, x) * 180.0 / math.pi;
    qiblaAngle = (qiblaAngle + 360.0) % 360.0;

    // Calculate distance (Haversine formula)
    const double earthRadius = 6371.0;
    double dLat = (kaabaLat - lat) * math.pi / 180.0;
    double dLonDiff = (kaabaLon - lon) * math.pi / 180.0;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(latRad) *
            math.cos(kaabaLatRad) *
            math.sin(dLonDiff / 2) *
            math.sin(dLonDiff / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    setState(() {
      _qiblaAngle = qiblaAngle;
      _distanceToMecca = distance;
    });

    _animationController.reset();
    _animationController.forward();
  }

  String _getDirectionName(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'Kuzey';
    if (angle >= 22.5 && angle < 67.5) return 'Kuzeydoğu';
    if (angle >= 67.5 && angle < 112.5) return 'Doğu';
    if (angle >= 112.5 && angle < 157.5) return 'Güneydoğu';
    if (angle >= 157.5 && angle < 202.5) return 'Güney';
    if (angle >= 202.5 && angle < 247.5) return 'Güneybatı';
    if (angle >= 247.5 && angle < 292.5) return 'Batı';
    return 'Kuzeybatı';
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // GPS or City Status Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _sourceText.contains('GPS') ? Icons.gps_fixed : Icons.location_city,
                size: 11,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _sourceText,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          // Compass widget matching mockup (88x88 circle with K/G/D/B)
          Builder(
            builder: (context) {
              final double dialRotation = _deviceHeading != null
                  ? -_deviceHeading! * math.pi / 180.0
                  : 0.0;
              final double arrowRotation = _deviceHeading != null
                  ? (_qiblaAngle - _deviceHeading!) * math.pi / 180.0
                  : (_qiblaAngle * _animation.value) * math.pi / 180.0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Outer Dial (Container + Labels + Kaaba Marker)
                  Transform.rotate(
                    angle: dialRotation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Dial Container
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
                        // Direction Text Labels (Absolute positioned on 180x180 circle)
                        const SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            children: [
                              // North (K)
                              Positioned(
                                top: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    'K',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                              // South (G)
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                              // East (D)
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    'D',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                              // West (B)
                              Positioned(
                                left: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    'B',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Kaaba Marker at Qibla angle on the Dial
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Transform.rotate(
                            angle: _qiblaAngle * math.pi / 180.0,
                            child: const Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Text(
                                  '🕋',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rotating Arrow (Custom dynamic compass needle pointing straight North by default)
                  Transform.rotate(
                    angle: arrowRotation,
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // North pointing side (Mecca / Qibla pointer) - pointing UP
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
                          // Arrow head tip
                          Positioned(
                            top: 0,
                            child: Icon(
                              Icons.arrow_drop_up_rounded,
                              size: 32,
                              color: _isAligned ? Colors.amber : AppColors.primary,
                            ),
                          ),
                          // South pointing side (opposite / tail) - pointing DOWN
                          Positioned(
                            top: 70,
                            bottom: 25,
                            child: Container(
                              width: 4,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                          ),
                          // Center pivot circle
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _isAligned ? Colors.amber : AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
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
          // Degree Text
          Text(
            _deviceHeading != null
                ? '${_deviceHeading!.toStringAsFixed(0)}°'
                : '${_qiblaAngle.toStringAsFixed(0)}°',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          // Description Text
          if (_deviceHeading != null) ...[
            Text(
              _isAligned ? '🕌 Kâbe\'ye Doğru Hizalandınız!' : 'Telefonu çevirerek yeşil oku takip edin',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: _isAligned ? AppColors.amberDark : AppColors.primaryDark,
              ),
            ),
          ] else ...[
            Text(
              '${_getDirectionName(_qiblaAngle)} · Kâbe yönü',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
          const Spacer(),
          // Distance Info Box at the bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${widget.selectedCity} ➔ Mekke mesafesi',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_distanceToMecca.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
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
