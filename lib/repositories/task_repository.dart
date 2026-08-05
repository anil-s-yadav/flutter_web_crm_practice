import 'package:practice_app/models/executive_task_model.dart';
import 'package:practice_app/api/api_client.dart';

class TaskRepository {
  final ApiClient apiClient;

  TaskRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<ExecutiveTaskModel>> getTasks({
    String? status,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String>[];
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    final endpoint = queryParams.isEmpty
        ? '/api/tasks'
        : '/api/tasks?${queryParams.join('&')}';

    final response = await ApiClient.get(endpoint);

    if (response is List) {
      return response.map((json) {
        return ExecutiveTaskModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) {
        return ExecutiveTaskModel.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<ExecutiveTaskModel> createTask(ExecutiveTaskModel task) async {
    final response = await ApiClient.post(
      '/api/tasks',
      task.toJson(),
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response.containsKey('title') || response.containsKey('due_date')) {
        return ExecutiveTaskModel.fromJson(response);
      }
      final assignedId = (response['taskId'] ?? response['id'])?.toString();
      if (assignedId != null && assignedId.isNotEmpty) {
        return task.copyWith(id: assignedId);
      }
      return task;
    } else {
      throw Exception('Failed to create task');
    }
  }


  Future<ExecutiveTaskModel> updateTask(ExecutiveTaskModel task) async {
    final response = await ApiClient.put(
      '/api/tasks/${task.id}',
      task.toJson(),
    );

    if (response != null) {
      return ExecutiveTaskModel.fromJson(response as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update task');
    }
  }
}
