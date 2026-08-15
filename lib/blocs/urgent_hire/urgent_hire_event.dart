import 'package:equatable/equatable.dart';
import 'package:practice_app/models/urgent_hire_model.dart';

abstract class UrgentHireEvent extends Equatable {
  const UrgentHireEvent();

  @override
  List<Object?> get props => [];
}

class LoadUrgentHires extends UrgentHireEvent {
  final String? status;
  final String? category;
  final String? search;

  const LoadUrgentHires({this.status, this.category, this.search});

  @override
  List<Object?> get props => [status, category, search];
}

class CreateUrgentHireEvent extends UrgentHireEvent {
  final UrgentHireModel request;

  const CreateUrgentHireEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateUrgentHireStatusEvent extends UrgentHireEvent {
  final String id;
  final UrgentHireStatus status;
  final String? fulfilledCandidateId;
  final String? notes;

  const UpdateUrgentHireStatusEvent({
    required this.id,
    required this.status,
    this.fulfilledCandidateId,
    this.notes,
  });

  @override
  List<Object?> get props => [id, status, fulfilledCandidateId, notes];
}
