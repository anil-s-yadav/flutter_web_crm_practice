import 'package:practice_app/api/api_client.dart';

class SearchResultGroup {
  final List<dynamic> candidates;
  final List<dynamic> clients;
  final List<dynamic> contracts;
  final List<dynamic> users;
  final List<dynamic> tickets;

  const SearchResultGroup({
    required this.candidates,
    required this.clients,
    required this.contracts,
    required this.users,
    required this.tickets,
  });

  factory SearchResultGroup.fromJson(Map<String, dynamic> json) {
    return SearchResultGroup(
      candidates: json['candidates'] as List<dynamic>? ?? [],
      clients: json['clients'] as List<dynamic>? ?? [],
      contracts: json['contracts'] as List<dynamic>? ?? [],
      users: json['users'] as List<dynamic>? ?? [],
      tickets: json['tickets'] as List<dynamic>? ?? [],
    );
  }

  bool get isEmpty =>
      candidates.isEmpty && clients.isEmpty && contracts.isEmpty && users.isEmpty && tickets.isEmpty;

  int get totalCount =>
      candidates.length + clients.length + contracts.length + users.length;
}

class SearchRepository {
  final ApiClient apiClient;

  SearchRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<SearchResultGroup> search(String query) async {
    if (query.trim().isEmpty) {
      return const SearchResultGroup(
        candidates: [],
        clients: [],
        contracts: [],
        users: [],
        tickets: [],
      );
    }

    final response = await ApiClient.get('/api/search?q=${Uri.encodeComponent(query.trim())}');

    if (response is Map<String, dynamic>) {
      return SearchResultGroup.fromJson(response);
    } else {
      throw Exception('Failed to perform search');
    }
  }
}
