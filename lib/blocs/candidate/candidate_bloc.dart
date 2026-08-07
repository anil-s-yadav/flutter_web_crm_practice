import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';
import 'package:practice_app/repositories/candidate_repository.dart';

class CandidateBloc extends Bloc<CandidateEvent, CandidateState> {
  final CandidateRepository candidateRepository;

  CandidateBloc({required this.candidateRepository}) : super(CandidateInitial()) {
    on<LoadCandidates>(_onLoadCandidates);
    on<CreateCandidate>(_onCreateCandidate);
    on<UpdateCandidate>(_onUpdateCandidate);
    on<UpdateCandidateLocally>(_onUpdateCandidateLocally);
  }

  Future<void> _onLoadCandidates(
    LoadCandidates event,
    Emitter<CandidateState> emit,
  ) async {
    emit(CandidateLoading());
    try {
      final candidates = await candidateRepository.getCandidates(status: event.status);
      emit(CandidateLoaded(candidates: candidates));
    } catch (e) {
      emit(CandidateError(message: e.toString()));
    }
  }

  Future<void> _onCreateCandidate(
    CreateCandidate event,
    Emitter<CandidateState> emit,
  ) async {
    try {
      final created = await candidateRepository.createCandidate(event.candidate);
      if (state is CandidateLoaded) {
        final current = (state as CandidateLoaded).candidates;
        emit(CandidateLoaded(candidates: [created, ...current]));
      } else {
        add(const LoadCandidates());
      }
    } catch (e) {
      emit(CandidateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCandidate(
    UpdateCandidate event,
    Emitter<CandidateState> emit,
  ) async {
    try {
      final updated = await candidateRepository.updateCandidate(event.candidate);
      if (state is CandidateLoaded) {
        final current = (state as CandidateLoaded).candidates;
        final newList = current.map((c) => c.id == updated.id ? updated : c).toList();
        emit(CandidateLoaded(candidates: newList));
      } else {
        add(const LoadCandidates());
      }
    } catch (e) {
      emit(CandidateError(message: e.toString()));
    }
  }

  void _onUpdateCandidateLocally(
    UpdateCandidateLocally event,
    Emitter<CandidateState> emit,
  ) {
    if (state is CandidateLoaded) {
      final currentState = state as CandidateLoaded;
      final updatedCandidates = currentState.candidates.map((c) {
        return c.id == event.candidate.id ? event.candidate : c;
      }).toList();
      emit(CandidateLoaded(candidates: updatedCandidates));
    }
  }
}
