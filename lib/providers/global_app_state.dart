import 'package:flutter/material.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/executive_task_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/models/user_model.dart';

class GlobalAppState extends ChangeNotifier {
  List<ClientModel> _clients = [];
  List<CandidateModel> _candidates = [];
  List<ContractModel> _contracts = [];
  final List<TicketModel> _tickets = [];
  List<ExecutiveTaskModel> _tasks = [];
  final List<AuditLogModel> _auditLogs = [];

  UserModel? _currentUser;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<ClientModel> get clients => _clients;
  List<CandidateModel> get candidates => _candidates;
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
      email: 'priya@verifiedcandidates.in',
      role: UserRole.sales,
    );

    // Seed in-memory data
    _candidates = List.generate(200, (i) => MockDataGenerator.generateCandidate(i));
    _clients = List.generate(100, (i) => MockDataGenerator.generateClient(i));

    // Let's generate a few contracts
    _contracts = [];
    int contractCount = 0;

    for (int i = 0; i < 40; i++) {
      final client = _clients[i];
      final candidate = _candidates[i];

      // Update candidate and client status for realism
      final contract = ContractModel(
        id: 'C${(++contractCount).toString().padLeft(6, '0')}',
        clientId: client.id,
        candidateId: candidate.id,
        clientName: client.fullName,
        candidateName: candidate.fullName,
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

      _candidates[i] = candidate.copyWith(
        status: CandidateStatus.placed,
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
              'Created contract ${contract.id} for ${contract.clientName} with candidate ${contract.candidateName}',
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
        candidateId: contract.candidateId,
        candidateName: contract.candidateName,
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

  void releaseCandidateToPool(String contractId) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx != -1) {
      final contract = _contracts[idx];
      _contracts[idx] = contract.copyWith(contractStatus: ContractStatus.completed);
      
      final candidateIdx = _candidates.indexWhere((m) => m.id == contract.candidateId);
      if (candidateIdx != -1) {
        _candidates[candidateIdx] = _candidates[candidateIdx].clearPlacement().copyWith(status: CandidateStatus.readyToPlace); 
      }
      logAction(ActionType.update, contract.id, 'Contract completed. Candidate released to pool.');
      notifyListeners();
    }
  }

  void markCandidateLeft(String contractId) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx != -1) {
      final contract = _contracts[idx];
      _contracts[idx] = contract.copyWith(contractStatus: ContractStatus.completed);
      
      final candidateIdx = _candidates.indexWhere((m) => m.id == contract.candidateId);
      if (candidateIdx != -1) {
        _candidates[candidateIdx] = _candidates[candidateIdx].clearPlacement().copyWith(status: CandidateStatus.jobLeft); 
      }
      logAction(ActionType.update, contract.id, 'Contract completed. Candidate left job.');
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

  void updateTask(ExecutiveTaskModel updatedTask) {
    final idx = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (idx != -1) {
      _tasks[idx] = updatedTask;
      notifyListeners();
    }
  }

  // --- Candidate Modifications ---
  void addCandidate(CandidateModel candidate) {
    _candidates.insert(0, candidate);
    logAction(
      ActionType.create,
      candidate.id,
      'Added new candidate: ${candidate.fullName} (${candidate.category})',
    );
    notifyListeners();
  }

  void updateCandidate(CandidateModel updatedCandidate, String changesSummary) {
    final idx = _candidates.indexWhere((m) => m.id == updatedCandidate.id);
    if (idx != -1) {
      _candidates[idx] = updatedCandidate;
      logAction(
        ActionType.update,
        updatedCandidate.id,
        'Edited details: $changesSummary',
      );
      notifyListeners();
    }
  }

  void advanceCandidatePipeline(String candidateId, CandidateStatus newStatus) {
    final idx = _candidates.indexWhere((m) => m.id == candidateId);
    if (idx != -1) {
      final candidate = _candidates[idx];
      final now = DateTime.now();
      _candidates[idx] = candidate.copyWith(
        status: newStatus,
        dateVerificationSent: newStatus == CandidateStatus.verificationPending ? now : candidate.dateVerificationSent,
        dateMedicalSent: newStatus == CandidateStatus.medicalPending ? now : candidate.dateMedicalSent,
        dateReadyToHire: newStatus == CandidateStatus.readyToPlace ? now : candidate.dateReadyToHire,
        datePlaced: newStatus == CandidateStatus.placed ? now : candidate.datePlaced,
      );
      logAction(
        ActionType.statusChange,
        candidate.id,
        'Advanced pipeline stage to ${newStatus.name}',
      );
      notifyListeners();
    }
  }

  void blacklistCandidate(String candidateId, String reason) {
    final idx = _candidates.indexWhere((m) => m.id == candidateId);
    if (idx != -1) {
      final candidate = _candidates[idx];
      _candidates[idx] = candidate.copyWith(
        status: CandidateStatus.blacklisted,
        remarks: 'BLACKLISTED: $reason\n${candidate.remarks ?? ""}',
      );
      logAction(ActionType.statusChange, candidate.id, 'Blacklisted candidate: $reason');
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

  CandidateModel? getCandidate(String id) {
    try {
      return _candidates.firstWhere((m) => m.id == id);
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
