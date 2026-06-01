import 'dart:math' as math;

/// Diyanet şehirleri ve koordinatları (enlem, boylam).
class CityCoordinates {
  CityCoordinates._();

  static const Map<String, List<double>> coords = {
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

  static String nearestCity(double lat, double lon) {
    String nearest = 'Malatya';
    double minKm = double.infinity;
    for (final entry in coords.entries) {
      final d = haversineKm(lat, lon, entry.value[0], entry.value[1]);
      if (d < minKm) {
        minKm = d;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;
}
