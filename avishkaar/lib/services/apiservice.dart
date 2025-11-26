import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const BACKEND = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://6f5f65f1825e.ngrok-free.app',
  );

  static Future<Map<String, dynamic>> callGemini({
    required String uid,
    required String sessionId,
    required String message,
    double? latitude,
    double? longitude,
  }) async {
    final url = Uri.parse('$BACKEND/llm/gemini_chat');

    final body = {
      "session_id": sessionId,
      "uid": uid,
      "message": message,
      "latitude": latitude,   // must be number
      "longitude": longitude, // must be number
    };

    try {
      print("➡️ Calling Gemini API with body: ${jsonEncode(body)}");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        print("❌ Backend error ${res.statusCode}: ${res.body}");
        return {
          "gemini_text":
              "⚠️ Server returned ${res.statusCode}. Please try again later."
        };
      }

      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print("❌ HTTP Error: $e");
      return {"gemini_text": "⚠️ Network error: $e"};
    }
  }
}
