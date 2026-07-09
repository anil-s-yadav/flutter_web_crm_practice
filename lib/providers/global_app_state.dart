import 'package:flutter/material.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/executive_task_model.dart';
import 'package:practice_app/models/maid_model.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/models/user_model.dart';

class GlobalAppState extends ChangeNotifier {
  List<ClientModel> _clients = [];
  List<MaidModel> _maids = [];
  List<ContractModel> _contracts = [];
  final List<TicketModel> _tickets = [];
  List<ExecutiveTaskModel> _tasks = [];
  final List<AuditLogModel> _auditLogs = [];

  UserModel? _currentUser;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<ClientModel> get clients => _clients;
  List<MaidModel> get maids => _maids;
  List<ContractModel> get contracts => _contracts;
  List<TicketModel> get tickets => _tickets;
  List<ExecutiveTaskModel> get tasks => _tasks;
  List<AuditLogModel> get auditLogs => _auditLogs;
  UserModel? get currentUser => _currentUser;

  Future<void> initializeData() async {
    if (_isInitialized) return;

    // Default current user to Sales if none set
    _currentUser ??= const UserModel(
      id: 2,
      name: 'Priya Mehta',
      email: 'priya@verifiedmaids.in',
      role: UserRole.sales,
    );

    // Seed in-memory data
    _maids = List.generate(200, (i) => MockDataGenerator.generateMaid(i));
    _clients = List.generate(100, (i) => MockDataGenerator.generateClient(i));

    // Let's generate a few contracts
    _contracts = [];
    int contractCount = 0;

    for (int i = 0; i < 40; i++) {
      final client = _clients[i];
      final maid = _maids[i];

      // Update maid and client status for realism
      final contract = ContractModel(
        id: 'C${(++contractCount).toString().padLeft(6, '0')}',
        clientId: client.id,
        maidId: maid.id,
        clientName: client.fullName,
        maidName: maid.fullName,
        placementDate: DateTime.now().subtract(Duration(days: i * 3)),
        guaranteeEndDate: DateTime.now().add(Duration(days: 180 - (i * 3))),
        serviceFee: 25000,
        amountPaid: 25000,
        balanceAmount: 0,
        paymentStatus: PaymentStatus.paid,
        contractStatus: ContractStatus.active,
        createdBy: 'Priya Mehta',
      );

      _contracts.add(contract);

      _maids[i] = maid.copyWith(
        status: MaidStatus.placed,
        currentPlacementId: contract.id,
      );

      _clients[i] = client.copyWith(status: ClientStatus.active);
    }

    // Generate Tasks
    _tasks = List.generate(20, (i) => MockDataGenerator.generateTask(i));

    // Generate some audit logs
    for (var contract in _contracts) {
      _auditLogs.add(
        AuditLogModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: contract.placementDate,
          userId: '2',
          userName: contract.createdBy,
          userRole: UserRole.sales,
          actionType: ActionType.create,
          targetId: contract.id,
          description:
              'Created contract ${contract.id} for ${contract.clientName} with maid ${contract.maidName}',
        ),
      );
    }

    _auditLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _isInitialized = true;
    notifyListeners();
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logAction(ActionType type, String targetId, String description) {
    if (_currentUser == null) return;

    _auditLogs.insert(
      0,
      AuditLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        userId: _currentUser!.id.toString(),
        userName: _currentUser!.name,
        userRole: _currentUser!.role,
        actionType: type,
        targetId: targetId,
        description: description,
      ),
    );
    notifyListeners();
  }

  // --- Contract Modifications ---
  void extendContractGuarantee(String contractId, int extraDays) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx != -1) {
      final contract = _contracts[idx];
      _contracts[idx] = contract.copyWith(
        guaranteeEndDate: contract.guaranteeEndDate.add(
          Duration(days: extraDays),
        ),
      );
      logAction(
        ActionType.update,
        contract.id,
        'Extended guarantee by $extraDays days',
      );
      notifyListeners();
    }
  }

  void updateContractPayment(String contractId, double amountPaid) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx != -1) {
      final contract = _contracts[idx];
      final newAmountPaid = contract.amountPaid + amountPaid;
      final newBalance = contract.serviceFee - newAmountPaid;
      _contracts[idx] = contract.copyWith(
        amountPaid: newAmountPaid,
        balanceAmount: newBalance,
        paymentStatus:
            newBalance <= 0 ? PaymentStatus.paid : PaymentStatus.partial,
      );
      logAction(
        ActionType.paymentLogged,
        contract.id,
        'Logged payment of ₹$amountPaid',
      );
      notifyListeners();
    }
  }

  void initiateReplacement(String contractId, String reason) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx != -1) {
      final contract = _contracts[idx];

      // Create an SLA Ticket for Sourcing
      final ticket = TicketModel(
        id: 'T${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        title: 'Replacement Request: ${contract.clientName}',
        description: reason,
        priority: TicketPriority.urgent,
        status: TicketStatus.open,
        clientId: contract.clientId,
        clientName: contract.clientName,
        maidId: contract.maidId,
        maidName: contract.maidName,
        contractId: contract.id,
        assignedTo: 'Sourcing Team',
        createdAt: DateTime.now(),
        slaDeadline: DateTime.now().add(const Duration(days: 15)),
      );

      _tickets.insert(0, ticket);
      logAction(
        ActionType.slaInitiated,
        contract.id,
        'Initiated replacement ticket ${ticket.id}',
      );
      notifyListeners();
    }
  }

  void markTaskCompleted(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      _tasks[idx] = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      logAction(
        ActionType.taskCompleted,
        task.id,
        'Completed task: ${task.title}',
      );
      notifyListeners();
    }
  }

  // --- Maid Modifications ---
  void addMaid(MaidModel maid) {
    _maids.insert(0, maid);
    logAction(
      ActionType.create,
      maid.id,
      'Added new candidate: ${maid.fullName} (${maid.category})',
    );
    notifyListeners();
  }

  void updateMaid(MaidModel updatedMaid, String changesSummary) {
    final idx = _maids.indexWhere((m) => m.id == updatedMaid.id);
    if (idx != -1) {
      _maids[idx] = updatedMaid;
      logAction(
        ActionType.update,
        updatedMaid.id,
        'Edited details: $changesSummary',
      );
      notifyListeners();
    }
  }

  void advanceMaidPipeline(String maidId, MaidStatus newStatus) {
    final idx = _maids.indexWhere((m) => m.id == maidId);
    if (idx != -1) {
      final maid = _maids[idx];
      final now = DateTime.now();
      _maids[idx] = maid.copyWith(
        status: newStatus,
        dateVerificationSent: newStatus == MaidStatus.verificationPending ? now : maid.dateVerificationSent,
        dateMedicalSent: newStatus == MaidStatus.medicalPending ? now : maid.dateMedicalSent,
        dateReadyToHire: newStatus == MaidStatus.readyToPlace ? now : maid.dateReadyToHire,
        datePlaced: newStatus == MaidStatus.placed ? now : maid.datePlaced,
      );
      logAction(
        ActionType.statusChange,
        maid.id,
        'Advanced pipeline stage to ${newStatus.name}',
      );
      notifyListeners();
    }
  }

  void blacklistMaid(String maidId, String reason) {
    final idx = _maids.indexWhere((m) => m.id == maidId);
    if (idx != -1) {
      final maid = _maids[idx];
      _maids[idx] = maid.copyWith(
        status: MaidStatus.blacklisted,
        remarks: 'BLACKLISTED: $reason\n${maid.remarks ?? ""}',
      );
      logAction(ActionType.statusChange, maid.id, 'Blacklisted maid: $reason');
      notifyListeners();
    }
  }

  // Helper queries
  ClientModel? getClient(String id) {
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  MaidModel? getMaid(String id) {
    try {
      return _maids.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  ContractModel? getContractForClient(String clientId) {
    try {
      return _contracts.firstWhere(
        (c) =>
            c.clientId == clientId && c.contractStatus == ContractStatus.active,
      );
    } catch (_) {
      return null;
    }
  }
}
