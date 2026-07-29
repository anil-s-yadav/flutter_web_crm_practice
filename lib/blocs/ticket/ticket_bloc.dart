import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/repositories/ticket_repository.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepository ticketRepository;

  TicketBloc({required this.ticketRepository}) : super(const TicketState()) {
    on<LoadTickets>(_onLoadTickets);
    on<CreateTicket>(_onCreateTicket);
    on<UpdateTicket>(_onUpdateTicket);
    on<DeleteTicket>(_onDeleteTicket);
  }

  Future<void> _onLoadTickets(LoadTickets event, Emitter<TicketState> emit) async {
    try {
      if (event.refresh || state.status == TicketStatusState.initial) {
        emit(state.copyWith(status: TicketStatusState.loading));
      }

      final tickets = await ticketRepository.getTickets(
        q: event.query,
        status: event.status,
        priority: event.priority,
        page: event.page,
        limit: event.limit,
      );

      emit(state.copyWith(
        status: TicketStatusState.loaded,
        tickets: tickets,
        // In a real app we'd parse pagination metadata, but for now we'll just set it
        currentPage: event.page,
        totalPages: 1, 
        totalItems: tickets.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TicketStatusState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateTicket(CreateTicket event, Emitter<TicketState> emit) async {
    try {
      await ticketRepository.createTicket(event.ticket);
      add(const LoadTickets(refresh: true));
    } catch (e) {
      emit(state.copyWith(
        status: TicketStatusState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTicket(UpdateTicket event, Emitter<TicketState> emit) async {
    try {
      await ticketRepository.updateTicket(
        event.id,
        status: event.status,
        resolution: event.resolution,
        assignedTo: event.assignedTo,
      );
      add(const LoadTickets(refresh: true));
    } catch (e) {
      emit(state.copyWith(
        status: TicketStatusState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteTicket(DeleteTicket event, Emitter<TicketState> emit) async {
    try {
      await ticketRepository.deleteTicket(event.id);
      add(const LoadTickets(refresh: true));
    } catch (e) {
      emit(state.copyWith(
        status: TicketStatusState.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
