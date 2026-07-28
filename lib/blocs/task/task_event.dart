import 'package:equatable/equatable.dart';
import 'package:practice_app/models/executive_task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final String? status;

  const LoadTasks({this.status});

  @override
  List<Object> get props => status != null ? [status!] : [];
}

class CreateTask extends TaskEvent {
  final ExecutiveTaskModel task;

  const CreateTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final ExecutiveTaskModel task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}
