import 'package:equatable/equatable.dart';
import 'package:practice_app/models/learning_topic_model.dart';

abstract class LearningEvent extends Equatable {
  const LearningEvent();

  @override
  List<Object?> get props => [];
}

class LoadLearningTopics extends LearningEvent {
  final String? category;
  final String? search;
  final String? roleFilter;

  const LoadLearningTopics({
    this.category,
    this.search,
    this.roleFilter,
  });

  @override
  List<Object?> get props => [category, search, roleFilter];
}

class CreateLearningTopicEvent extends LearningEvent {
  final LearningTopicModel topic;

  const CreateLearningTopicEvent(this.topic);

  @override
  List<Object?> get props => [topic];
}

class UpdateLearningTopicEvent extends LearningEvent {
  final LearningTopicModel topic;

  const UpdateLearningTopicEvent(this.topic);

  @override
  List<Object?> get props => [topic];
}

class DeleteLearningTopicEvent extends LearningEvent {
  final String id;

  const DeleteLearningTopicEvent(this.id);

  @override
  List<Object?> get props => [id];
}
