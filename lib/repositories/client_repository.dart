import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/api/api_client.dart';

class ClientRepository {
  final ApiClient apiClient;

  ClientRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<ClientModel>> getClients({
    String? status,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String>[];
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    final endpoint = queryParams.isEmpty
        ? '/api/clients'
        : '/api/clients?${queryParams.join('&')}';

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return ClientModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) {
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

    if (response != null && response is Map<String, dynamic>) {
      if (response.containsKey('name') || response.containsKey('full_name') || response.containsKey('fullName')) {
        return ClientModel.fromJson(response);
      }
      final assignedId = (response['clientId'] ?? response['id'])?.toString();
      if (assignedId != null && assignedId.isNotEmpty) {
        return client.copyWith(id: assignedId);
      }
      return client;
    } else {
      throw Exception('Failed to create client');
    }
  }


  Future<ClientModel> updateClient(ClientModel client, {String? reason}) async {
    final body = client.toJson();
    if (reason != null) body['reason'] = reason;
    
    final response = await ApiClient.put(
      '/api/clients/${client.id}',
      body,
    );

    if (response != null) {
      return ClientModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update client');
    }
  }
}
