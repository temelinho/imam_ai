import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/city_coordinates.dart';
import '../l10n/l10n_scope.dart';
import '../location/location_scope.dart';
import '../services/location_service.dart';

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
  LocationService? _locationService;

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
    ],
    'Antalya': [
      {'name': 'Yivli Minare Camii', 'lat': 36.8866, 'lon': 30.7046, 'address': 'Kaleiçi, Antalya'},
      {'name': 'Murat Paşa Camii', 'lat': 36.8871, 'lon': 30.7054, 'address': 'Muratpaşa, Antalya'},
    ],
    'Adana': [
      {'name': 'Sabancı Merkez Camii', 'lat': 36.9969, 'lon': 35.3213, 'address': 'Reşatbey, Seyhan'},
      {'name': 'Ulu Camii', 'lat': 36.9917, 'lon': 35.3308, 'address': 'Ulu Camii, Seyhan'},
    ],
    'Konya': [
      {'name': 'Mevlana Camii', 'lat': 37.8714, 'lon': 32.5047, 'address': 'Aziziye, Karatay'},
      {'name': 'Alaaddin Camii', 'lat': 37.8720, 'lon': 32.4925, 'address': 'Alaaddin, Karatay'},
    ],
    'Trabzon': [
      {'name': 'Ayasofya Camii', 'lat': 41.0086, 'lon': 39.7208, 'address': 'Ayasofya, Ortahisar'},
      {'name': 'Gülbahar Hatun Camii', 'lat': 41.0058, 'lon': 39.7265, 'address': 'Ortahisar, Trabzon'},
    ],
    'Diyarbakır': [
      {'name': 'Ulu Camii', 'lat': 37.9116, 'lon': 40.2303, 'address': 'Sur, Diyarbakır'},
      {'name': 'Hz. Süleyman Camii', 'lat': 37.9142, 'lon': 40.2351, 'address': 'Sur, Diyarbakır'},
    ],
    'Gaziantep': [
      {'name': 'Ömeriye Camii', 'lat': 37.0594, 'lon': 37.3825, 'address': 'Şehitkamil, Gaziantep'},
      {'name': 'Kurtuluş Camii', 'lat': 37.0660, 'lon': 37.3780, 'address': 'Şahinbey, Gaziantep'},
    ],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = LocationScope.of(context);
    if (_locationService != loc) {
      _locationService = loc;
    }
  }

  List<Map<String, dynamic>> _allMosques() {
    final list = <Map<String, dynamic>>[];
    for (final mosques in _mosquesByCity.values) {
      list.addAll(mosques);
    }
    return list;
  }

  List<Map<String, dynamic>> _mosquesForDisplay(LocationService loc) {
    if (loc.fromGps && loc.hasLocation) {
      return _allMosques();
    }
    final city = loc.nearestCity ?? widget.selectedCity;
    return List<Map<String, dynamic>>.from(
      _mosquesByCity[city] ?? _mosquesByCity['Malatya']!,
    );
  }

  double _distanceKm(LocationService loc, double lat, double lon) {
    final coords = loc.coordsOrCityFallback(widget.selectedCity);
    return CityCoordinates.haversineKm(coords[0], coords[1], lat, lon);
  }

  Future<void> _openMapRoute(double lat, double lon, String name) async {
    final geoUri = Uri.parse('geo:$lat,$lon?q=$lat,$lon(${Uri.encodeComponent(name)})');
    final mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');

    try {
      final launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10nScope.of(context).mapsError)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nScope.of(context);
    final loc = LocationScope.of(context);
    final rawMosques = _mosquesForDisplay(loc);

    final sortedMosques = rawMosques.map((m) {
      return {
        ...m,
        'distance': _distanceKm(loc, m['lat'] as double, m['lon'] as double),
      };
    }).toList()
      ..sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    final displayList = loc.fromGps ? sortedMosques.take(20).toList() : sortedMosques;
    final statusText = loc.fromGps ? l10n.sortedByGps : l10n.sortedByCity;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                loc.fromGps ? Icons.gps_fixed : Icons.location_on,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => loc.refresh(),
                child: const Icon(Icons.refresh, size: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (loc.loading)
          const LinearProgressIndicator(color: AppColors.primary, backgroundColor: AppColors.surface2),
        if (loc.fromGps && displayList.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.near_me, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.nearestMosqueHint(displayList.first['name'] as String),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: displayList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final mosque = displayList[index];
              final distance = mosque['distance'] as double;
              final distanceStr = distance < 1.0
                  ? '${(distance * 1000).toStringAsFixed(0)} m'
                  : '${distance.toStringAsFixed(1)} km';
              final isNearest = index == 0 && loc.fromGps;

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
                    color: isNearest ? const Color(0xFFF0FDF9) : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isNearest ? AppColors.primary : AppColors.cardBorder,
                      width: isNearest ? 2 : 1.5,
                    ),
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isNearest ? Icons.mosque_rounded : Icons.mosque,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mosque['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                if (isNearest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10n.nearestTag,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mosque['address'] as String,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.distanceLabel(distanceStr),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_outlined, color: Colors.white, size: 18),
                            const SizedBox(height: 2),
                            Text(
                              l10n.openMap,
                              style: const TextStyle(
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
