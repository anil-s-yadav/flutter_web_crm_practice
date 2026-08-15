import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/urgent_hire/urgent_hire_event.dart';
import 'package:practice_app/blocs/urgent_hire/urgent_hire_state.dart';
import 'package:practice_app/repositories/urgent_hire_repository.dart';

class UrgentHireBloc extends Bloc<UrgentHireEvent, UrgentHireState> {
  final UrgentHireRepository repository;

  UrgentHireBloc({required this.repository}) : super(UrgentHireInitial()) {
    on<LoadUrgentHires>(_onLoadUrgentHires);
    on<CreateUrgentHireEvent>(_onCreateUrgentHire);
    on<UpdateUrgentHireStatusEvent>(_onUpdateUrgentHireStatus);
  }

  Future<void> _onLoadUrgentHires(
    LoadUrgentHires event,
    Emitter<UrgentHireState> emit,
  ) async {
    emit(UrgentHireLoading());
    try {
      final urgentHires = await repository.getUrgentHires(
        status: event.status,
        category: event.category,
        search: event.search,
      );
      emit(UrgentHireLoaded(urgentHires: urgentHires));
    } catch (e) {
      emit(UrgentHireError(e.toString()));
    }
  }

  Future<void> _onCreateUrgentHire(
    CreateUrgentHireEvent event,
    Emitter<UrgentHireState> emit,
  ) async {
    try {
      final created = await repository.createUrgentHire(event.request);
      final urgentHires = await repository.getUrgentHires();
      emit(UrgentHireActionSuccess(
        message: 'Urgent hire request submitted to Sourcing team',
        urgentHire: created,
      ));
      emit(UrgentHireLoaded(urgentHires: urgentHires));
    } catch (e) {
      emit(UrgentHireError(e.toString()));
    }
  }

  Future<void> _onUpdateUrgentHireStatus(
    UpdateUrgentHireStatusEvent event,
    Emitter<UrgentHireState> emit,
  ) async {
    try {
      final updated = await repository.updateUrgentHireStatus(
        id: event.id,
        status: event.status,
        fulfilledCandidateId: event.fulfilledCandidateId,
        notes: event.notes,
      );
      final urgentHires = await repository.getUrgentHires();
      emit(UrgentHireActionSuccess(
        message: 'Urgent hire status updated',
        urgentHire: updated,
      ));
      emit(UrgentHireLoaded(urgentHires: urgentHires));
    } catch (e) {
      emit(UrgentHireError(e.toString()));
    }
  }
}
