import 'package:equatable/equatable.dart';
import 'package:practice_app/models/candidate_model.dart';

abstract class CandidateState extends Equatable {
  const CandidateState();

  @override
  List<Object> get props => [];
}

class CandidateInitial extends CandidateState {}

class CandidateLoading extends CandidateState {}

class CandidateLoaded extends CandidateState {
  final List<CandidateModel> candidates;
  final DateTime timestamp;

  CandidateLoaded({required this.candidates, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object> get props => [candidates, timestamp];
}

class CandidateError extends CandidateState {
  final String message;

  const CandidateError({required this.message});

  @override
  List<Object> get props => [message];
}
