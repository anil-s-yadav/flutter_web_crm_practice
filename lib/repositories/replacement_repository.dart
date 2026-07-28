import 'package:practice_app/models/replacement_request_model.dart';
import 'package:practice_app/api/api_client.dart';

class ReplacementRepository {
  final ApiClient apiClient;

  ReplacementRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<ReplacementRequestModel>> getReplacements({String? status}) async {
    String endpoint = '/api/replacements';
    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return ReplacementRequestModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load replacements');
    }
  }

  Future<ReplacementRequestModel> createReplacement(
      ReplacementRequestModel replacement) async {
    final response = await ApiClient.post(
      '/api/replacements',
      replacement.toJson(),
    );

    if (response != null) {
      return ReplacementRequestModel.fromJson(
          response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create replacement');
    }
  }

  Future<ReplacementRequestModel> updateReplacement(
      ReplacementRequestModel replacement) async {
    final response = await ApiClient.put(
      '/api/replacements/${replacement.id}',
      replacement.toJson(),
    );

    if (response != null) {
      return ReplacementRequestModel.fromJson(
          response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update replacement');
    }
  }
}
