import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Geliştirme (Localhost) ve Canlı (Render) URL'leri. Toggleyabilirsiniz.
  static const String _localBaseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  // ignore: unused_field
  static const String _prodBaseUrl = 'https://imam-ai-backend.onrender.com'; // Render URL'niz ile değiştirin
  
  static const String baseUrl = _localBaseUrl; // Canlıya alırken _prodBaseUrl yapabilirsiniz

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
      }),
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      // Sizin prompttaki 'response' alanı ile API response'u 'reply' alanını uyumlu hale getiriyoruz
      return {
        'reply': decodedData['reply'] ?? decodedData['response'] ?? '',
        'session_id': decodedData['session_id'] ?? '',
      };
    }
    throw Exception('Sunucu hatası: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getHistory(String sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/history/$sessionId'),
    );
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
      if (decodedData is List) {
        return List<Map<String, dynamic>>.from(decodedData);
      } else if (decodedData is Map && decodedData.containsKey('history')) {
        return List<Map<String, dynamic>>.from(decodedData['history']);
      }
    }
    return [];
  }
}
