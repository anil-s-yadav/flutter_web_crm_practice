import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/learning/learning_event.dart';
import 'package:practice_app/blocs/learning/learning_state.dart';
import 'package:practice_app/repositories/learning_repository.dart';

class LearningBloc extends Bloc<LearningEvent, LearningState> {
  final LearningRepository learningRepository;

  LearningBloc({required this.learningRepository}) : super(LearningInitial()) {
    on<LoadLearningTopics>(_onLoadLearningTopics);
    on<CreateLearningTopicEvent>(_onCreateLearningTopic);
    on<UpdateLearningTopicEvent>(_onUpdateLearningTopic);
    on<DeleteLearningTopicEvent>(_onDeleteLearningTopic);
  }

  Future<void> _onLoadLearningTopics(
    LoadLearningTopics event,
    Emitter<LearningState> emit,
  ) async {
    emit(LearningLoading());
    try {
      final topics = await learningRepository.getLearningTopics(
        category: event.category,
        search: event.search,
        roleFilter: event.roleFilter,
      );
      emit(LearningLoaded(
        topics: topics,
        selectedCategory: event.category,
        searchQuery: event.search,
      ));
    } catch (e) {
      emit(LearningError(e.toString()));
    }
  }

  Future<void> _onCreateLearningTopic(
    CreateLearningTopicEvent event,
    Emitter<LearningState> emit,
  ) async {
    try {
      await learningRepository.createLearningTopic(event.topic);
      add(const LoadLearningTopics());
    } catch (e) {
      emit(LearningError(e.toString()));
    }
  }

  Future<void> _onUpdateLearningTopic(
    UpdateLearningTopicEvent event,
    Emitter<LearningState> emit,
  ) async {
    try {
      await learningRepository.updateLearningTopic(event.topic);
      add(const LoadLearningTopics());
    } catch (e) {
      emit(LearningError(e.toString()));
    }
  }

  Future<void> _onDeleteLearningTopic(
    DeleteLearningTopicEvent event,
    Emitter<LearningState> emit,
  ) async {
    try {
      await learningRepository.deleteLearningTopic(event.id);
      add(const LoadLearningTopics());
    } catch (e) {
      emit(LearningError(e.toString()));
    }
  }
}
