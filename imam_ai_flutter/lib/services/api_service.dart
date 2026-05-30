import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Geliştirme için localhost, production'da gerçek URL ile değiştir
  static const String _baseUrl = 'http://10.0.2.2:8000';

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Sunucu hatası: ${response.statusCode}');
  }
}
