import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/user/user_event.dart';
import 'package:practice_app/blocs/user/user_state.dart';
import 'package:practice_app/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateCrmUser>(_onCreateCrmUser);
    on<UpdateCrmUser>(_onUpdateCrmUser);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final users = await userRepository.getUsers(role: event.role);
      emit(UserLoaded(users: users));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onCreateCrmUser(
    CreateCrmUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      final created = await userRepository.createUser(event.userData);
      if (state is UserLoaded) {
        final current = (state as UserLoaded).users;
        emit(UserLoaded(users: [created, ...current]));
      } else {
        add(const LoadUsers());
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCrmUser(
    UpdateCrmUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      final updated = await userRepository.updateUser(event.id, event.userData);
      if (state is UserLoaded) {
        final current = (state as UserLoaded).users;
        final newList = current.map((u) => u.id == updated.id ? updated : u).toList();
        emit(UserLoaded(users: newList));
      } else {
        add(const LoadUsers());
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }
}
