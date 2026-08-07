import 'package:equatable/equatable.dart';
import 'package:practice_app/models/candidate_model.dart';

abstract class CandidateEvent extends Equatable {
  const CandidateEvent();

  @override
  List<Object> get props => [];
}

class LoadCandidates extends CandidateEvent {
  final String? status;

  const LoadCandidates({this.status});

  @override
  List<Object> get props => status != null ? [status!] : [];
}

class CreateCandidate extends CandidateEvent {
  final CandidateModel candidate;

  const CreateCandidate(this.candidate);

  @override
  List<Object> get props => [candidate];
}

class UpdateCandidate extends CandidateEvent {
  final CandidateModel candidate;

  const UpdateCandidate(this.candidate);

  @override
  List<Object> get props => [candidate];
}

class UpdateCandidateLocally extends CandidateEvent {
  final CandidateModel candidate;

  const UpdateCandidateLocally(this.candidate);

  @override
  List<Object> get props => [candidate];
}
