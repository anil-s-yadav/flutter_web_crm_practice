import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/api/api_client.dart';

class TicketRepository {
  final ApiClient apiClient;

  TicketRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<List<TicketModel>> getTickets({
    String? q,
    TicketStatus? status,
    TicketPriority? priority,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String>[];
    if (q != null && q.isNotEmpty) queryParams.add('q=$q');
    if (status != null) queryParams.add('status=${status.name}');
    if (priority != null) queryParams.add('priority=${priority.name}');
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    final endpoint = queryParams.isEmpty
        ? '/api/tickets'
        : '/api/tickets?${queryParams.join('&')}';

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return TicketModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) {
        return TicketModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  Future<TicketModel> getTicketById(String id) async {
    final response = await ApiClient.get('/api/tickets/$id');
    if (response != null) {
      return TicketModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load ticket details');
    }
  }

  Future<String> createTicket(TicketModel ticket) async {
    final response = await ApiClient.post(
      '/api/tickets',
      ticket.toJson(),
    );

    if (response != null && response is Map<String, dynamic> && response.containsKey('id')) {
      return response['id'];
    } else {
      throw Exception('Failed to create ticket');
    }
  }

  Future<void> updateTicket(String id, {TicketStatus? status, String? resolution, String? assignedTo}) async {
    final Map<String, dynamic> body = {};
    if (status != null) body['status'] = status.name;
    if (resolution != null) body['resolution'] = resolution;
    if (assignedTo != null) body['assignedTo'] = assignedTo;

    final response = await ApiClient.put(
      '/api/tickets/$id',
      body,
    );

    if (response == null) {
      throw Exception('Failed to update ticket');
    }
  }

  Future<void> deleteTicket(String id) async {
    final response = await ApiClient.delete('/api/tickets/$id');
    if (response == null) {
      throw Exception('Failed to delete ticket');
    }
  }
}
