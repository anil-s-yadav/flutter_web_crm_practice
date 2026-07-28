import 'package:equatable/equatable.dart';
import 'package:practice_app/models/contract_model.dart';

abstract class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object> get props => [];
}

class LoadContracts extends ContractEvent {
  final String? status;

  const LoadContracts({this.status});

  @override
  List<Object> get props => status != null ? [status!] : [];
}

class CreateContract extends ContractEvent {
  final ContractModel contract;

  const CreateContract(this.contract);

  @override
  List<Object> get props => [contract];
}

class UpdateContract extends ContractEvent {
  final ContractModel contract;

  const UpdateContract(this.contract);

  @override
  List<Object> get props => [contract];
}
