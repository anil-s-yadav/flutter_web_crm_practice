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
      await candidateRepository.createCandidate(event.candidate);
      // Reload candidates after creating
      add(const LoadCandidates());
    } catch (e) {
      emit(CandidateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCandidate(
    UpdateCandidate event,
    Emitter<CandidateState> emit,
  ) async {
    try {
      await candidateRepository.updateCandidate(event.candidate);
      // Reload candidates after updating
      add(const LoadCandidates());
    } catch (e) {
      emit(CandidateError(message: e.toString()));
    }
  }
}
