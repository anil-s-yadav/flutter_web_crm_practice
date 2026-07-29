import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/repositories/audit_log_repository.dart';

// Events
abstract class AuditLogEvent {
  const AuditLogEvent();
}

class LoadAuditLogs extends AuditLogEvent {
  const LoadAuditLogs();
}

// States
abstract class AuditLogState {
  const AuditLogState();
}

class AuditLogInitial extends AuditLogState {}

class AuditLogLoading extends AuditLogState {}

class AuditLogLoaded extends AuditLogState {
  final List<AuditLogModel> auditLogs;
  const AuditLogLoaded({required this.auditLogs});
}

class AuditLogError extends AuditLogState {
  final String message;
  const AuditLogError({required this.message});
}

// BLoC
class AuditLogBloc extends Bloc<AuditLogEvent, AuditLogState> {
  final AuditLogRepository auditLogRepository;

  AuditLogBloc({required this.auditLogRepository}) : super(AuditLogInitial()) {
    on<LoadAuditLogs>(_onLoadAuditLogs);
  }

  Future<void> _onLoadAuditLogs(
    LoadAuditLogs event,
    Emitter<AuditLogState> emit,
  ) async {
    emit(AuditLogLoading());
    try {
      final logs = await auditLogRepository.getAuditLogs();
      emit(AuditLogLoaded(auditLogs: logs));
    } catch (e) {
      emit(AuditLogError(message: e.toString()));
    }
  }
}
