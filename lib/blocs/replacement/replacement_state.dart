import 'package:equatable/equatable.dart';
import 'package:practice_app/models/replacement_request_model.dart';

abstract class ReplacementState extends Equatable {
  const ReplacementState();

  @override
  List<Object> get props => [];
}

class ReplacementInitial extends ReplacementState {}

class ReplacementLoading extends ReplacementState {}

class ReplacementLoaded extends ReplacementState {
  final List<ReplacementRequestModel> replacements;

  const ReplacementLoaded({required this.replacements});

  @override
  List<Object> get props => [replacements];
}

class ReplacementError extends ReplacementState {
  final String message;

  const ReplacementError({required this.message});

  @override
  List<Object> get props => [message];
}
