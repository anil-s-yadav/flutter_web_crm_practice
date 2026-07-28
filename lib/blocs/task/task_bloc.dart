import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/task/task_event.dart';
import 'package:practice_app/blocs/task/task_state.dart';
import 'package:practice_app/repositories/task_repository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await taskRepository.getTasks(status: event.status);
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepository.createTask(event.task);
      // Reload tasks after creating
      add(const LoadTasks());
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepository.updateTask(event.task);
      // Reload tasks after updating
      add(const LoadTasks());
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}
