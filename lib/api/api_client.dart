import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:practice_app/utils/shared_preferences.dart';

class ApiClient {
  // Use 10.0.2.2 for Android Emulator, localhost for Web/Desktop
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = LocalStoragePref().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final errorMsg = jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
      throw Exception(errorMsg);
    }
  }
}
