import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/api/api_client.dart';

class ContractRepository {
  final ApiClient apiClient;

  ContractRepository({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  Future<List<ContractModel>> getContracts({
    String? status,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String>[];
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    final endpoint = queryParams.isEmpty
        ? '/api/contracts'
        : '/api/contracts?${queryParams.join('&')}';

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return ContractModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) {
        return ContractModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load contracts');
    }
  }

  Future<ContractModel> createContract(ContractModel contract) async {
    final response = await ApiClient.post('/api/contracts', contract.toJson());

    if (response != null) {
      return ContractModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create contract');
    }
  }

  Future<ContractModel> updateContract(ContractModel contract) async {
    final response = await ApiClient.put(
      '/api/contracts/${contract.id}',
      contract.toJson(),
    );

    if (response != null) {
      return ContractModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update contract');
    }
  }

  Future<ContractModel> renewContract(
    String contractId, {
    String? newCandidateId,
    String? newCandidateName,
  }) async {
    final body = {
      if (newCandidateId != null) 'newCandidateId': newCandidateId,
      if (newCandidateName != null) 'newCandidateName': newCandidateName,
    };
    final response = await ApiClient.post(
      '/api/contracts/$contractId/renew',
      body,
    );

    if (response != null) {
      return ContractModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to renew contract');
    }
  }
}
