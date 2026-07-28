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
      await contractRepository.createContract(event.contract);
      // Reload contracts after creating
      add(const LoadContracts());
    } catch (e) {
      emit(ContractError(message: e.toString()));
    }
  }

  Future<void> _onUpdateContract(
    UpdateContract event,
    Emitter<ContractState> emit,
  ) async {
    try {
      await contractRepository.updateContract(event.contract);
      // Reload contracts after updating
      add(const LoadContracts());
    } catch (e) {
      emit(ContractError(message: e.toString()));
    }
  }
}
