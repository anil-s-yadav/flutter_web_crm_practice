import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/api/api_client.dart';

class CandidateRepository {
  final ApiClient apiClient;

  CandidateRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<List<CandidateModel>> getCandidates({String? status}) async {
    String endpoint = '/api/candidates';
    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
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

    if (response != null) {
      return CandidateModel.fromJson(response as Map<String, dynamic>);
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

