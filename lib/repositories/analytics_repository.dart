import 'package:practice_app/api/api_client.dart';

class AnalyticsRepository {
  Future<Map<String, dynamic>> getAdminAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/admin', noCache: true);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSalesAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/sales', noCache: true);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSourcingAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/sourcing', noCache: true);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExecutiveAnalytics() async {
    try {
      final response = await ApiClient.get('/analytics/executive', noCache: true);
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
