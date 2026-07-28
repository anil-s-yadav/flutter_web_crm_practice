import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/api/api_client.dart';

class ClientRepository {
  final ApiClient apiClient;

  ClientRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<ClientModel>> getClients({String? status}) async {
    String endpoint = '/api/clients';
    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return ClientModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<ClientModel> createClient(ClientModel client) async {
    final response = await ApiClient.post(
      '/api/clients',
      client.toJson(),
    );

    if (response != null) {
      return ClientModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create client');
    }
  }

  Future<ClientModel> updateClient(ClientModel client) async {
    final response = await ApiClient.put(
      '/api/clients/${client.id}',
      client.toJson(),
    );

    if (response != null) {
      return ClientModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update client');
    }
  }
}
