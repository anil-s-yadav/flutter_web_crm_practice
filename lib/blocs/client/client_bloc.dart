import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/client/client_event.dart';
import 'package:practice_app/blocs/client/client_state.dart';
import 'package:practice_app/repositories/client_repository.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository clientRepository;

  ClientBloc({required this.clientRepository}) : super(ClientInitial()) {
    on<LoadClients>(_onLoadClients);
    on<CreateClient>(_onCreateClient);
    on<UpdateClient>(_onUpdateClient);
    on<UpdateClientLocally>(_onUpdateClientLocally);
  }

  Future<void> _onLoadClients(
    LoadClients event,
    Emitter<ClientState> emit,
  ) async {
    emit(ClientLoading());
    try {
      final clients = await clientRepository.getClients(status: event.status);
      emit(ClientLoaded(clients: clients));
    } catch (e) {
      emit(ClientError(message: e.toString()));
    }
  }

  Future<void> _onCreateClient(
    CreateClient event,
    Emitter<ClientState> emit,
  ) async {
    try {
      await clientRepository.createClient(event.client);
      // Reload clients after creating
      add(const LoadClients());
    } catch (e) {
      emit(ClientError(message: e.toString()));
    }
  }

  Future<void> _onUpdateClient(
    UpdateClient event,
    Emitter<ClientState> emit,
  ) async {
    try {
      await clientRepository.updateClient(event.client, reason: event.reason);
      // Reload clients after updating
      add(const LoadClients());
    } catch (e) {
      emit(ClientError(message: e.toString()));
    }
  }

  void _onUpdateClientLocally(
    UpdateClientLocally event,
    Emitter<ClientState> emit,
  ) {
    if (state is ClientLoaded) {
      final currentState = state as ClientLoaded;
      final updatedClients = currentState.clients.map((c) {
        return c.id == event.client.id ? event.client : c;
      }).toList();
      emit(ClientLoaded(clients: updatedClients));
    }
  }
}
