import 'package:equatable/equatable.dart';
import 'package:practice_app/models/client_model.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object> get props => [];
}

class LoadClients extends ClientEvent {
  final String? status;

  const LoadClients({this.status});

  @override
  List<Object> get props => status != null ? [status!] : [];
}

class CreateClient extends ClientEvent {
  final ClientModel client;

  const CreateClient(this.client);

  @override
  List<Object> get props => [client];
}

class UpdateClient extends ClientEvent {
  final ClientModel client;
  final String? reason;

  const UpdateClient(this.client, {this.reason});

  @override
  List<Object> get props => reason != null ? [client, reason!] : [client];
}
