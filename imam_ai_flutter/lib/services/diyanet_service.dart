import 'dart:convert';
import 'package:http/http.dart' as http;

class DiyanetService {
  static const String _base = 'https://ezanvakti.emushaf.net';

  // Major Turkish cities and their Diyanet district codes
  static const Map<String, String> majorCities = {
    'Malatya': '9798',
    'İstanbul': '9541',
    'Ankara': '9206',
    'İzmir': '9560',
    'Bursa': '9365',
    'Antalya': '9225',
    'Adana': '9146',
    'Konya': '9676',
    'Trabzon': '9984',
    'Diyarbakır': '9403',
    'Gaziantep': '9455',
  };

  Future<Map<String, String>> getPrayerTimes(String districtCode) async {
    try {
      final response = await http.get(Uri.parse('$_base/vakitler/$districtCode'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data.isNotEmpty) {
          final today = data[0]; // First element is today
          return {
            'imsak': today['Imsak'] ?? '00:00',
            'gunes': today['Gunes'] ?? '00:00',
            'ogle': today['Ogle'] ?? '00:00',
            'ikindi': today['Ikindi'] ?? '00:00',
            'aksam': today['Aksam'] ?? '00:00',
            'yatsi': today['Yatsi'] ?? '00:00',
          };
        }
      }
    } catch (e) {
      // Return fallback offline times for Istanbul in case of network issue
    }
    return {
      'imsak': '03:45',
      'gunes': '05:30',
      'ogle': '13:12',
      'ikindi': '17:05',
      'aksam': '20:45',
      'yatsi': '22:20',
    };
  }

  // Mezhep difference: Shafi's afternoon (Asr) starts earlier than Hanefi's.
  // Diyanet API provides standard Hanefi times.
  // We subtract ~25 minutes to get Shafi/Maliki/Hanbeli times.
  Map<String, String> adjustForMezhep(Map<String, String> times, String mezhep) {
    if (mezhep == 'Hanefi') return times;
    
    final ikindiOriginal = times['ikindi']!;
    final parts = ikindiOriginal.split(':');
    if (parts.length == 2) {
      int hour = int.tryParse(parts[0]) ?? 0;
      int min = (int.tryParse(parts[1]) ?? 0) - 25;
      if (min < 0) {
        hour--;
        min += 60;
      }
      final adjustedIkindi = '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
      return {
        ...times,
        'ikindi': adjustedIkindi,
      };
    }
    return times;
  }
}
