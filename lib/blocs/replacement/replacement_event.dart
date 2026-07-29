import 'package:equatable/equatable.dart';
import 'package:practice_app/models/replacement_request_model.dart';

abstract class ReplacementEvent extends Equatable {
  const ReplacementEvent();

  @override
  List<Object> get props => [];
}

class LoadReplacements extends ReplacementEvent {
  final String? status;

  const LoadReplacements({this.status});

  @override
  List<Object> get props => status != null ? [status!] : [];
}

class CreateReplacement extends ReplacementEvent {
  final ReplacementRequestModel replacement;

  const CreateReplacement(this.replacement);

  @override
  List<Object> get props => [replacement];
}

class UpdateReplacement extends ReplacementEvent {
  final ReplacementRequestModel replacement;

  const UpdateReplacement(this.replacement);

  @override
  List<Object> get props => [replacement];
}

class AssignReplacementStaff extends ReplacementEvent {
  final String requestId;
  final String newCandidateId;
  final String newCandidateName;

  const AssignReplacementStaff({
    required this.requestId,
    required this.newCandidateId,
    required this.newCandidateName,
  });

  @override
  List<Object> get props => [requestId, newCandidateId, newCandidateName];
}
