import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/contract/contract_event.dart';
import 'package:practice_app/blocs/contract/contract_state.dart';
import 'package:practice_app/repositories/contract_repository.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final ContractRepository contractRepository;

  ContractBloc({required this.contractRepository}) : super(ContractInitial()) {
    on<LoadContracts>(_onLoadContracts);
    on<CreateContract>(_onCreateContract);
    on<UpdateContract>(_onUpdateContract);
    on<RenewContract>(_onRenewContract);
  }

  Future<void> _onLoadContracts(
    LoadContracts event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractLoading());
    try {
      final contracts = await contractRepository.getContracts(status: event.status);
      emit(ContractLoaded(contracts: contracts));
    } catch (e) {
      emit(ContractError(message: e.toString()));
    }
  }

  Future<void> _onCreateContract(
    CreateContract event,
    Emitter<ContractState> emit,
  ) async {
    try {
      final created = await contractRepository.createContract(event.contract);
      if (state is ContractLoaded) {
        final current = (state as ContractLoaded).contracts;
        emit(ContractLoaded(contracts: [created, ...current]));
      } else {
        add(const LoadContracts());
      }
    } catch (e) {
      emit(ContractError(message: e.toString()));
    }
  }

  Future<void> _onUpdateContract(
    UpdateContract event,
    Emitter<ContractState> emit,
  ) async {
    try {
      final updated = await contractRepository.updateContract(event.contract);
      if (state is ContractLoaded) {
        final current = (state as ContractLoaded).contracts;
        final newList = current.map((c) => c.id == updated.id ? updated : c).toList();
        emit(ContractLoaded(contracts: newList));
      } else {
        add(const LoadContracts());
      }
    } catch (e) {
      emit(ContractError(message: e.toString()));
    }
  }

  Future<void> _onRenewContract(
    RenewContract event,
    Emitter<ContractState> emit,
  ) async {
    try {
      final renewed = await contractRepository.renewContract(
        event.contractId,
        newCandidateId: event.newCandidateId,
        newCandidateName: event.newCandidateName,
      );
      if (state is ContractLoaded) {
        final current = (state as ContractLoaded).contracts;
        emit(ContractLoaded(contracts: [renewed, ...current]));
      } else {
        add(const LoadContracts());
      }
    } catch (e) {
      emit(ContractError(message: e.toString()));
    }
  }
}
