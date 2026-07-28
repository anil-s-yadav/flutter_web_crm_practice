import 'package:equatable/equatable.dart';
import 'package:practice_app/models/executive_task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<ExecutiveTaskModel> tasks;

  const TaskLoaded({required this.tasks});

  @override
  List<Object> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object> get props => [message];
}
