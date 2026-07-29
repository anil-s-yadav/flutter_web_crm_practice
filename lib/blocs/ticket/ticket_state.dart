import 'package:equatable/equatable.dart';
import 'package:practice_app/models/ticket_model.dart';

enum TicketStatusState { initial, loading, loaded, error }

class TicketState extends Equatable {
  final TicketStatusState status;
  final List<TicketModel> tickets;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const TicketState({
    this.status = TicketStatusState.initial,
    this.tickets = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
  });

  TicketState copyWith({
    TicketStatusState? status,
    List<TicketModel>? tickets,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? totalItems,
  }) {
    return TicketState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tickets,
        errorMessage,
        currentPage,
        totalPages,
        totalItems,
      ];
}
