import 'package:equatable/equatable.dart';
import 'package:practice_app/models/urgent_hire_model.dart';

abstract class UrgentHireState extends Equatable {
  const UrgentHireState();

  @override
  List<Object?> get props => [];
}

class UrgentHireInitial extends UrgentHireState {}

class UrgentHireLoading extends UrgentHireState {}

class UrgentHireLoaded extends UrgentHireState {
  final List<UrgentHireModel> urgentHires;
  final DateTime timestamp;

  UrgentHireLoaded({
    required this.urgentHires,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  int get pendingCount =>
      urgentHires.where((u) => u.status == UrgentHireStatus.pending).length;

  int get inProgressCount =>
      urgentHires.where((u) => u.status == UrgentHireStatus.inProgress).length;

  int get fulfilledCount =>
      urgentHires.where((u) => u.status == UrgentHireStatus.fulfilled).length;

  @override
  List<Object?> get props => [urgentHires, timestamp];
}

class UrgentHireError extends UrgentHireState {
  final String message;

  const UrgentHireError(this.message);

  @override
  List<Object?> get props => [message];
}

class UrgentHireActionSuccess extends UrgentHireState {
  final String message;
  final UrgentHireModel urgentHire;

  const UrgentHireActionSuccess({required this.message, required this.urgentHire});

  @override
  List<Object?> get props => [message, urgentHire];
}
