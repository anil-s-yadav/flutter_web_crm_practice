import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/utils/shared_preferences.dart';

class ApiClient {
  // Use 10.0.2.2 for Android Emulator, localhost for Web/Desktop
  static const String baseUrl = 'http://localhost:5000/api';

  static String _buildUrl(String endpoint) {
    String cleanEndpoint = endpoint;
    if (cleanEndpoint.startsWith('/api/')) {
      cleanEndpoint = cleanEndpoint.substring(4); // Strips leading /api
    } else if (!cleanEndpoint.startsWith('/')) {
      cleanEndpoint = '/$cleanEndpoint';
    }
    return '$baseUrl$cleanEndpoint';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = LocalStoragePref().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final urlStr = _buildUrl(endpoint);
    debugPrint('[API Debug] GET -> $urlStr');
    final response = await http.get(
      Uri.parse(urlStr),
      headers: await _getHeaders(),
    );
    debugPrint('[API Debug] GET -> $urlStr (${response.statusCode})');
    return _handleResponse(response, urlStr);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final urlStr = _buildUrl(endpoint);
    debugPrint('[API Debug] POST -> $urlStr');
    final response = await http.post(
      Uri.parse(urlStr),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    debugPrint('[API Debug] POST -> $urlStr (${response.statusCode})');
    return _handleResponse(response, urlStr);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final urlStr = _buildUrl(endpoint);
    debugPrint('[API Debug] PUT -> $urlStr');
    final response = await http.put(
      Uri.parse(urlStr),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    debugPrint('[API Debug] PUT -> $urlStr (${response.statusCode})');
    return _handleResponse(response, urlStr);
  }

  static Future<dynamic> delete(String endpoint) async {
    final urlStr = _buildUrl(endpoint);
    debugPrint('[API Debug] DELETE -> $urlStr');
    final response = await http.delete(
      Uri.parse(urlStr),
      headers: await _getHeaders(),
    );
    debugPrint('[API Debug] DELETE -> $urlStr (${response.statusCode})');
    return _handleResponse(response, urlStr);
  }

  static dynamic _handleResponse(http.Response response, String urlStr) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint('[API Debug Error] Invalid JSON from $urlStr: ${response.body}');
        throw Exception('Invalid JSON received from server.');
      }
    } else {
      debugPrint('[API Debug Error] $urlStr returned status ${response.statusCode}. Body: ${response.body}');
      try {
        final data = jsonDecode(response.body);
        if (data is Map && (data.containsKey('message') || data.containsKey('error'))) {
          throw Exception(data['message'] ?? data['error']);
        }
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
      }
      throw Exception('Server error (${response.statusCode}): Route $urlStr returned ${response.statusCode}');
    }
  }
}
