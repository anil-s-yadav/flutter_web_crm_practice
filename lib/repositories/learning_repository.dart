import 'package:practice_app/api/api_client.dart';
import 'package:practice_app/models/learning_topic_model.dart';

class LearningRepository {
  Future<List<LearningTopicModel>> getLearningTopics({
    String? category,
    String? search,
    String? roleFilter,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty && category != 'all') {
      queryParams['category'] = category;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (roleFilter != null && roleFilter.isNotEmpty && roleFilter != 'all') {
      queryParams['role_filter'] = roleFilter;
    }

    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final endpoint = queryString.isEmpty ? '/api/learnings' : '/api/learnings?$queryString';
    final response = await ApiClient.get(endpoint);

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List;
      return list.map((json) => LearningTopicModel.fromJson(json as Map<String, dynamic>)).toList();
    } else if (response is List) {
      return response.map((json) => LearningTopicModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<LearningTopicModel> createLearningTopic(LearningTopicModel topic) async {
    final response = await ApiClient.post('/api/learnings', topic.toJson());
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return LearningTopicModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return topic;
  }

  Future<LearningTopicModel> updateLearningTopic(LearningTopicModel topic) async {
    final response = await ApiClient.put('/api/learnings/${topic.id}', topic.toJson());
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return LearningTopicModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return topic;
  }

  Future<void> deleteLearningTopic(String id) async {
    await ApiClient.delete('/api/learnings/$id');
  }
}
