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
}
