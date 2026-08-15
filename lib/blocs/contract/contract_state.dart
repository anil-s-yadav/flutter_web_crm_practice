import 'package:equatable/equatable.dart';
import 'package:practice_app/models/contract_model.dart';

abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object> get props => [];
}

class ContractInitial extends ContractState {}

class ContractLoading extends ContractState {}

class ContractLoaded extends ContractState {
  final List<ContractModel> contracts;
  final DateTime timestamp;

  ContractLoaded({required this.contracts, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object> get props => [contracts, timestamp];
}

class ContractError extends ContractState {
  final String message;

  const ContractError({required this.message});

  @override
  List<Object> get props => [message];
}
