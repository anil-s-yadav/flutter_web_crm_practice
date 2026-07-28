import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/api/api_client.dart';

class ContractRepository {
  final ApiClient apiClient;

  ContractRepository({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  Future<List<ContractModel>> getContracts({String? status}) async {
    String endpoint = '/api/contracts';
    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
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
}
