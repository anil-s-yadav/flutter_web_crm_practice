import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/api/api_client.dart';

class CandidateRepository {
  final ApiClient apiClient;

  CandidateRepository({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  Future<List<CandidateModel>> getCandidates({
    String? status,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String>[];
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    final endpoint =
        queryParams.isEmpty
            ? '/api/candidates'
            : '/api/candidates?${queryParams.join('&')}';

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return CandidateModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else if (response is Map<String, dynamic> &&
        response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) {
        return CandidateModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load candidates');
    }
  }

  Future<CandidateModel> createCandidate(CandidateModel candidate) async {
    final response = await ApiClient.post(
      '/api/candidates',
      candidate.toJson(),
    );

    // Backend returns { message, candidateId, id } on success
    if (response != null && response is Map<String, dynamic>) {
      if (response.containsKey('fullName') ||
          response.containsKey('full_name')) {
        return CandidateModel.fromJson(response);
      }
      final assignedId =
          (response['candidateId'] ?? response['id'])?.toString();
      if (assignedId != null && assignedId.isNotEmpty) {
        return candidate.copyWith(id: assignedId);
      }
      return candidate;
    } else {
      throw Exception('Failed to create candidate');
    }
  }

  Future<CandidateModel> updateCandidate(CandidateModel candidate) async {
    final response = await ApiClient.put(
      '/api/candidates/${candidate.id}',
      candidate.toJson(),
    );

    if (response != null) {
      return CandidateModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update candidate');
    }
  }
}
