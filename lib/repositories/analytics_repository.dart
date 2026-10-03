import 'package:practice_app/api/api_client.dart';

class AnalyticsRepository {
  Future<Map<String, dynamic>> getAdminAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/admin');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSalesAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/sales');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSourcingAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/sourcing');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExecutiveAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/executive');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
