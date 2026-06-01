import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';

class CamilerScreen extends StatefulWidget {
  final String selectedCity;

  const CamilerScreen({
    super.key,
    required this.selectedCity,
  });

  @override
  State<CamilerScreen> createState() => _CamilerScreenState();
}

class _CamilerScreenState extends State<CamilerScreen> {
  bool _isLoading = false;
  double _myLat = 38.3552; // Malatya center fallback
  double _myLon = 38.3093; // Malatya center fallback
  String _locationStatus = 'Şehir merkezine göre sıralandı';

  // List of pre-defined mosques grouped by city
  static const Map<String, List<Map<String, dynamic>>> _mosquesByCity = {
    'Malatya': [
      {'name': 'Yeni Cami (Teze Cami)', 'lat': 38.3502, 'lon': 38.3150, 'address': 'Merkez, Malatya'},
      {'name': 'Battalgazi Ulu Camii', 'lat': 38.4190, 'lon': 38.3683, 'address': 'Alacakapı, Battalgazi'},
      {'name': 'Yusuf Paşa Camii', 'lat': 38.3512, 'lon': 38.3114, 'address': 'Saricioğlu, Malatya'},
      {'name': 'Söğütlü Camii', 'lat': 38.3533, 'lon': 38.3134, 'address': 'Merkez Çarşı, Malatya'},
      {'name': 'Kernek Karagözlüler Camii', 'lat': 38.3472, 'lon': 38.3242, 'address': 'Kernek, Malatya'},
    ],
    'İstanbul': [
      {'name': 'Sultanahmet Camii', 'lat': 41.0054, 'lon': 28.9768, 'address': 'Sultanahmet, Fatih'},
      {'name': 'Süleymaniye Camii', 'lat': 41.0162, 'lon': 28.9639, 'address': 'Süleymaniye, Fatih'},
      {'name': 'Ayasofya-i Kebir Cami-i Şerifi', 'lat': 41.0086, 'lon': 28.9798, 'address': 'Sultanahmet, Fatih'},
      {'name': 'Eyüp Sultan Camii', 'lat': 41.0478, 'lon': 28.9341, 'address': 'Merkez, Eyüpsultan'},
      {'name': 'Çamlıca Camii', 'lat': 41.0345, 'lon': 29.0831, 'address': 'Ferah, Üsküdar'},
    ],
    'Ankara': [
      {'name': 'Kocatepe Camii', 'lat': 39.9168, 'lon': 32.8605, 'address': 'Kocatepe, Çankaya'},
      {'name': 'Hacı Bayram Camii', 'lat': 39.9444, 'lon': 32.8579, 'address': 'Altındağ, Ankara'},
      {'name': 'Millet Camii', 'lat': 39.9312, 'lon': 32.7995, 'address': 'Beştepe, Yenimahalle'},
      {'name': 'Arslanhane Camii', 'lat': 39.9385, 'lon': 32.8638, 'address': 'Kalenur, Altındağ'},
    ],
    'İzmir': [
      {'name': 'Hisar Camii', 'lat': 38.4253, 'lon': 27.1306, 'address': 'Konak, İzmir'},
      {'name': 'Konak Yalı Camii', 'lat': 38.4189, 'lon': 27.1288, 'address': 'Kemeraltı, Konak'},
      {'name': 'Kestane Pazarı Camii', 'lat': 38.4231, 'lon': 27.1325, 'address': 'Konak, İzmir'},
    ],
    'Bursa': [
      {'name': 'Bursa Ulu Camii', 'lat': 40.1837, 'lon': 29.0617, 'address': 'Nalbantoğlu, Osmangazi'},
      {'name': 'Yeşil Camii', 'lat': 40.1814, 'lon': 29.0753, 'address': 'Yeşil, Yıldırım'},
      {'name': 'Emir Sultan Camii', 'lat': 40.1804, 'lon': 29.0818, 'address': 'Emirsultan, Yıldırım'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _loadDefaultCityCoordinates();
    _fetchLiveLocation();
  }

  void _loadDefaultCityCoordinates() {
    // City coords mapping
    const Map<String, List<double>> cityCoords = {
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
    final coords = cityCoords[widget.selectedCity] ?? [38.3552, 38.3093];
    setState(() {
      _myLat = coords[0];
      _myLon = coords[1];
    });
  }

  Future<void> _fetchLiveLocation() async {
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
        timeLimit: const Duration(seconds: 4),
      );

      setState(() {
        _myLat = position.latitude;
        _myLon = position.longitude;
        _locationStatus = 'Canlı GPS konumuna göre sıralandı';
      });
    } catch (e) {
      // Retain default city coordinates on failure
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateDistance(double lat, double lon) {
    const double earthRadius = 6371.0; // in km
    double dLat = (lat - _myLat) * math.pi / 180.0;
    double dLon = (lon - _myLon) * math.pi / 180.0;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_myLat * math.pi / 180.0) *
            math.cos(lat * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  void _openMapRoute(double lat, double lon, String name) async {
    // Try native maps app via geo: URI first (works on Android natively)
    final geoUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon(${Uri.encodeComponent(name)})');
    final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon&query_place_id=$name');

    try {
      final launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to Google Maps browser link
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harita uygulaması açılamadı. Google Maps yüklü olduğundan emin olun.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get list of mosques for selected city or use generic defaults
    final rawMosques = _mosquesByCity[widget.selectedCity] ?? _mosquesByCity['Malatya']!;
    
    // Compute distance for all mosques and sort them
    final List<Map<String, dynamic>> sortedMosques = rawMosques.map((m) {
      return {
        ...m,
        'distance': _calculateDistance(m['lat'] as double, m['lon'] as double),
      };
    }).toList();

    sortedMosques.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return Column(
      children: [
        // Top GPS location status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                _locationStatus.contains('GPS') ? Icons.gps_fixed : Icons.location_on,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _locationStatus,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _fetchLiveLocation,
                child: const Icon(
                  Icons.refresh,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const LinearProgressIndicator(color: AppColors.primary, backgroundColor: AppColors.surface2),
        // Mosque Lists
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedMosques.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final mosque = sortedMosques[index];
              final distance = mosque['distance'] as double;
              final distanceStr = distance < 1.0
                  ? '${(distance * 1000).toStringAsFixed(0)} m'
                  : '${distance.toStringAsFixed(1)} km';

              return InkWell(
                onTap: () => _openMapRoute(
                  mosque['lat'] as double,
                  mosque['lon'] as double,
                  mosque['name'] as String,
                ),
                borderRadius: BorderRadius.circular(11),
                child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Mosque Icon Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mosque['name'] as String,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mosque['address'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '📍 Uzaklık: $distanceStr',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Navigation Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined, color: Colors.white, size: 18),
                          SizedBox(height: 2),
                          Text(
                            'Harita',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
