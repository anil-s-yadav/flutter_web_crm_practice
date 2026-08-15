import 'package:equatable/equatable.dart';
import 'package:practice_app/models/learning_topic_model.dart';

abstract class LearningState extends Equatable {
  const LearningState();

  @override
  List<Object?> get props => [];
}

class LearningInitial extends LearningState {}

class LearningLoading extends LearningState {}

class LearningLoaded extends LearningState {
  final List<LearningTopicModel> topics;
  final String? selectedCategory;
  final String? searchQuery;

  const LearningLoaded({
    required this.topics,
    this.selectedCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [topics, selectedCategory, searchQuery];
}

class LearningError extends LearningState {
  final String message;

  const LearningError(this.message);

  @override
  List<Object?> get props => [message];
}
