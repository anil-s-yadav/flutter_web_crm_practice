import 'package:practice_app/models/urgent_hire_model.dart';
import 'package:practice_app/api/api_client.dart';

class UrgentHireRepository {
  final ApiClient apiClient;

  UrgentHireRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<UrgentHireModel>> getUrgentHires({
    String? status,
    String? category,
    String? search,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String>[];
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams.add('status=$status');
    }
    if (category != null && category.isNotEmpty) {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    final endpoint = queryParams.isEmpty
        ? '/api/urgent-hires'
        : '/api/urgent-hires?${queryParams.join('&')}';

    final response = await ApiClient.get(endpoint, noCache: true);

    if (response is List) {
      return response.map((json) {
        return UrgentHireModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) {
        return UrgentHireModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load urgent hire requests');
    }
  }

  Future<UrgentHireModel> createUrgentHire(UrgentHireModel request) async {
    final response = await ApiClient.post(
      '/api/urgent-hires',
      request.toJson(),
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        return UrgentHireModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return UrgentHireModel.fromJson(response);
    } else {
      throw Exception('Failed to create urgent hire request');
    }
  }

  Future<UrgentHireModel> updateUrgentHireStatus({
    required String id,
    required UrgentHireStatus status,
    String? fulfilledCandidateId,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'status': status.toDbString(),
    };
    if (fulfilledCandidateId != null) {
      body['fulfilled_candidate_id'] = fulfilledCandidateId;
    }
    if (notes != null) {
      body['notes'] = notes;
    }

    final response = await ApiClient.put(
      '/api/urgent-hires/$id/status',
      body,
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        return UrgentHireModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      return UrgentHireModel.fromJson(response);
    } else {
      throw Exception('Failed to update urgent hire status');
    }
  }
}
