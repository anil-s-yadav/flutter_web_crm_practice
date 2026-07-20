import 'package:practice_app/models/client_model.dart';

enum InvoiceStatus { paid, pending, overdue }

extension InvoiceStatusExtension on InvoiceStatus {
  String get displayName {
    switch (this) {
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.overdue:
        return 'Overdue';
    }
  }
}

class InvoiceModel {
  final String id;
  final String clientId;
  final String clientName;
  final String candidateName;
  final double amount;
  final DateTime date;
  final DateTime dueDate;
  final InvoiceStatus status;

  InvoiceModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.candidateName,
    required this.amount,
    required this.date,
    required this.dueDate,
    required this.status,
  });

  factory InvoiceModel.mock(
    String id,
    String clientName,
    String candidateName,
    double amount,
    int daysAgo,
    InvoiceStatus status,
  ) {
    final now = DateTime.now();
    return InvoiceModel(
      id: id,
      clientId: 'CLI001',
      clientName: clientName,
      candidateName: candidateName,
      amount: amount,
      date: now.subtract(Duration(days: daysAgo)),
      dueDate: now.subtract(Duration(days: daysAgo - 15)), // 15 day terms
      status: status,
    );
  }
}
