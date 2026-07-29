import 'package:equatable/equatable.dart';
import 'package:practice_app/models/ticket_model.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class LoadTickets extends TicketEvent {
  final String? query;
  final TicketStatus? status;
  final TicketPriority? priority;
  final int page;
  final int limit;
  final bool refresh;

  const LoadTickets({
    this.query,
    this.status,
    this.priority,
    this.page = 1,
    this.limit = 10,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [query, status, priority, page, limit, refresh];
}

class CreateTicket extends TicketEvent {
  final TicketModel ticket;

  const CreateTicket(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class UpdateTicket extends TicketEvent {
  final String id;
  final TicketStatus? status;
  final String? resolution;
  final String? assignedTo;

  const UpdateTicket({
    required this.id,
    this.status,
    this.resolution,
    this.assignedTo,
  });

  @override
  List<Object?> get props => [id, status, resolution, assignedTo];
}

class DeleteTicket extends TicketEvent {
  final String id;

  const DeleteTicket(this.id);

  @override
  List<Object> get props => [id];
}
