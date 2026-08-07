import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/replacement/replacement_event.dart';
import 'package:practice_app/blocs/replacement/replacement_state.dart';
import 'package:practice_app/repositories/replacement_repository.dart';

class ReplacementBloc extends Bloc<ReplacementEvent, ReplacementState> {
  final ReplacementRepository replacementRepository;

  ReplacementBloc({required this.replacementRepository})
      : super(ReplacementInitial()) {
    on<LoadReplacements>(_onLoadReplacements);
    on<CreateReplacement>(_onCreateReplacement);
    on<UpdateReplacement>(_onUpdateReplacement);
    on<AssignReplacementStaff>(_onAssignReplacementStaff);
  }

  Future<void> _onLoadReplacements(
    LoadReplacements event,
    Emitter<ReplacementState> emit,
  ) async {
    emit(ReplacementLoading());
    try {
      final replacements =
          await replacementRepository.getReplacements(status: event.status);
      emit(ReplacementLoaded(replacements: replacements));
    } catch (e) {
      emit(ReplacementError(message: e.toString()));
    }
  }

  Future<void> _onCreateReplacement(
    CreateReplacement event,
    Emitter<ReplacementState> emit,
  ) async {
    try {
      final created = await replacementRepository.createReplacement(event.replacement);
      if (state is ReplacementLoaded) {
        final current = (state as ReplacementLoaded).replacements;
        emit(ReplacementLoaded(replacements: [created, ...current]));
      } else {
        add(const LoadReplacements());
      }
    } catch (e) {
      emit(ReplacementError(message: e.toString()));
    }
  }

  Future<void> _onUpdateReplacement(
    UpdateReplacement event,
    Emitter<ReplacementState> emit,
  ) async {
    try {
      final updated = await replacementRepository.updateReplacement(event.replacement);
      if (state is ReplacementLoaded) {
        final current = (state as ReplacementLoaded).replacements;
        final newList = current.map((r) => r.id == updated.id ? updated : r).toList();
        emit(ReplacementLoaded(replacements: newList));
      } else {
        add(const LoadReplacements());
      }
    } catch (e) {
      emit(ReplacementError(message: e.toString()));
    }
  }

  Future<void> _onAssignReplacementStaff(
    AssignReplacementStaff event,
    Emitter<ReplacementState> emit,
  ) async {
    try {
      final assigned = await replacementRepository.assignReplacementStaff(
        event.requestId,
        event.newCandidateId,
        event.newCandidateName,
      );
      if (state is ReplacementLoaded) {
        final current = (state as ReplacementLoaded).replacements;
        final newList = current.map((r) => r.id == assigned.id ? assigned : r).toList();
        emit(ReplacementLoaded(replacements: newList));
      } else {
        add(const LoadReplacements());
      }
    } catch (e) {
      emit(ReplacementError(message: e.toString()));
    }
  }
}
