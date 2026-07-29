import 'package:practice_app/api/api_client.dart';
import 'package:practice_app/models/crm_user_model.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<CrmUserModel>> getUsers({
    String? role,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String>[];
    if (role != null && role.isNotEmpty) queryParams.add('role=$role');
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    final endpoint = queryParams.isEmpty
        ? '/api/users'
        : '/api/users?${queryParams.join('&')}';

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return CrmUserModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) {
        return CrmUserModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load team users');
    }
  }

  Future<CrmUserModel> createUser(Map<String, dynamic> userData) async {
    final response = await ApiClient.post('/api/users', userData);
    if (response != null && response is Map<String, dynamic>) {
      return CrmUserModel.fromJson(response);
    } else {
      throw Exception('Failed to create team member');
    }
  }

  Future<CrmUserModel> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await ApiClient.put('/api/users/$id', userData);
    if (response != null && response is Map<String, dynamic>) {
      return CrmUserModel.fromJson(response);
    } else {
      throw Exception('Failed to update team member');
    }
  }
}
