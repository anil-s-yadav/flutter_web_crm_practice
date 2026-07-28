import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/repositories/auth_repository.dart';
import 'package:practice_app/utils/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<FcmTokenUpdated>(_onFcmTokenUpdated);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final token = LocalStoragePref().getToken();
      if (token != null) {
        final user = LocalStoragePref().getUserModel();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  void _onFcmTokenUpdated(FcmTokenUpdated event, Emitter<AuthState> emit) async {
    if (state is AuthAuthenticated) {
      await authRepository.updateFcmToken(event.token);
    }
  }
}
