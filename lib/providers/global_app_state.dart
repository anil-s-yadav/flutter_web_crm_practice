import 'package:flutter/material.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/crm_user_model.dart';
import 'package:practice_app/models/executive_task_model.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/models/notification_model.dart';
import 'package:practice_app/models/invoice_model.dart';
import 'package:practice_app/models/replacement_request_model.dart';
import 'package:practice_app/auth/user_manager.dart';

class GlobalAppState extends ChangeNotifier {
  List<ClientModel> _clients = [];
  List<CandidateModel> _candidates = [];
  List<ContractModel> _contracts = [];
  final List<TicketModel> _tickets = [];
  List<ExecutiveTaskModel> _tasks = [];
  final List<AuditLogModel> _auditLogs = [];
  List<NotificationModel> _notifications = [];
  final List<InvoiceModel> _invoices = [];
  List<CrmUserModel> _crmUsers = [];
  List<ReplacementRequestModel> _replacementRequests = [];

  UserModel? _currentUser;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<ClientModel> get clients => _clients;
  List<CandidateModel> get candidates => _candidates;
  List<ContractModel> get contracts => _contracts;
  List<TicketModel> get tickets => _tickets;
  List<ExecutiveTaskModel> get tasks => _tasks;
  List<AuditLogModel> get auditLogs => _auditLogs;
  List<NotificationModel> get notifications => _notifications;
  List<InvoiceModel> get invoices => _invoices;
  List<CrmUserModel> get crmUsers => _crmUsers;
  List<ReplacementRequestModel> get replacementRequests => _replacementRequests;
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;
  UserModel? get currentUser => UserManager().currentUser ?? _currentUser;

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
    _candidates = List.generate(
      200,
      (i) => MockDataGenerator.generateCandidate(i),
    );
    _clients = List.generate(100, (i) => MockDataGenerator.generateClient(i));

    // Let's generate a few contracts
    _contracts = [];
    int contractCount = 0;

    for (int i = 0; i < 60; i++) {
      final client = _clients[i];
      final candidate = _candidates[i];

      // Distribute data across different statuses
      int daysLeft = 180 - (i * 5); // Goes down to -115 for expired
      DateTime placementDate = DateTime.now().subtract(
        Duration(days: 180 - daysLeft),
      );
      DateTime guaranteeEndDate = DateTime.now().add(Duration(days: daysLeft));

      ContractStatus status = ContractStatus.active;
      bool isReplacementUsed = false;

      // Make some replacements
      if (i % 8 == 0) {
        status = ContractStatus.rePlaced;
        isReplacementUsed = true;
      }

      // Update candidate and client status for realism
      final contract = ContractModel(
        id: 'C${(++contractCount).toString().padLeft(6, '0')}',
        clientId: client.id,
        candidateId: candidate.id,
        clientName: client.fullName,
        candidateName: candidate.fullName,
        placementDate: placementDate,
        guaranteeEndDate: guaranteeEndDate,
        serviceFee: 25000,
        amountPaid: i % 3 == 0 ? 15000 : 25000,
        balanceAmount: i % 3 == 0 ? 10000 : 0,
        paymentStatus: i % 3 == 0 ? PaymentStatus.partial : PaymentStatus.paid,
        contractStatus: status,
        isReplacementUsed: isReplacementUsed,
        replacementsUsed: isReplacementUsed ? 1 : 0,
        isRenewal: i % 4 == 0,
        renewedOn: i % 4 == 0 ? placementDate : null,
        createdBy: 'Priya Mehta',
      );

      _contracts.add(contract);

      _candidates[i] = candidate.copyWith(
        status: CandidateStatus.Placed,
        currentPlacementId: contract.id,
      );

      _clients[i] = client.copyWith(status: ClientStatus.converted);
    }
    
    // Generate some replacement requests
    _replacementRequests = [];
    int reqCount = 0;
    for (int i = 0; i < 5; i++) {
      final contract = _contracts[i * 10]; // Pick every 10th contract
      _replacementRequests.add(
        ReplacementRequestModel(
          id: 'REQ${(++reqCount).toString().padLeft(4, '0')}',
          contractId: contract.id,
          clientId: contract.clientId,
          clientName: contract.clientName,
          oldCandidateId: contract.candidateId,
          oldCandidateName: contract.candidateName,
          reason: 'Candidate absconded without notice',
          requestDate: DateTime.now().subtract(Duration(days: i + 1)),
          status: ReplacementStatus.pending,
          createdBy: contract.createdBy,
        )
      );
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

    // Simulate Cron Job: Check for 30-Day pending payments and trigger tasks
    _checkAndTrigger30DayPayments();

    // Generate some dummy notifications
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'New Client Inquiry',
        message: 'The Sharma Family submitted a new inquiry for a Cook.',
        type: NotificationType.info,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        title: 'SLA Breach Warning',
        message: 'Ticket #T-102 (Replacement) is 2 days away from SLA breach.',
        type: NotificationType.warning,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '3',
        title: 'Candidate Medical Cleared',
        message: 'Candidate Sunita Devi\'s medical check is now complete.',
        type: NotificationType.success,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: '4',
        title: 'Urgent: Candidate Absconded',
        message: 'Client reported candidate Radha Patil absconded today.',
        type: NotificationType.urgent,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Seed CRM team members
    _crmUsers = [
      CrmUserModel(
        id: 'USR001',
        name: 'Anil Yadav',
        email: 'anil@verifiedmaids.com',
        phone: '+91 98765 43210',
        role: UserRole.admin,
        joinedDate: DateTime(2023, 1, 15),
        lastLogin: DateTime.now().subtract(const Duration(minutes: 10)),
        candidatesAdded: 0,
        clientsConverted: 0,
        contractsClosed: 0,
      ),
      CrmUserModel(
        id: 'USR002',
        name: 'Priya Mehta',
        email: 'priya@verifiedmaids.com',
        phone: '+91 87654 32109',
        role: UserRole.sales,
        joinedDate: DateTime(2023, 6, 10),
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
        candidatesAdded: 12,
        clientsConverted: 45,
        contractsClosed: 38,
      ),
      CrmUserModel(
        id: 'USR003',
        name: 'Rahul Sharma',
        email: 'rahul@verifiedmaids.com',
        phone: '+91 76543 21098',
        role: UserRole.sales,
        joinedDate: DateTime(2024, 2, 1),
        lastLogin: DateTime.now().subtract(const Duration(days: 2)),
        candidatesAdded: 8,
        clientsConverted: 22,
        contractsClosed: 15,
      ),
      CrmUserModel(
        id: 'USR004',
        name: 'Sunita Devi',
        email: 'sunita@verifiedmaids.com',
        phone: '+91 65432 10987',
        role: UserRole.sourcing,
        joinedDate: DateTime(2023, 9, 20),
        lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
        candidatesAdded: 320,
        clientsConverted: 0,
        contractsClosed: 0,
      ),
      CrmUserModel(
        id: 'USR005',
        name: 'Deepak Patel',
        email: 'deepak@verifiedmaids.com',
        phone: '+91 54321 09876',
        role: UserRole.sourcing,
        joinedDate: DateTime(2024, 5, 12),
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        candidatesAdded: 180,
        clientsConverted: 0,
        contractsClosed: 0,
      ),
      CrmUserModel(
        id: 'USR006',
        name: 'Kavita Joshi',
        email: 'kavita@verifiedmaids.com',
        phone: '+91 43210 98765',
        role: UserRole.executive,
        joinedDate: DateTime(2024, 8, 1),
        lastLogin: DateTime.now().subtract(const Duration(hours: 12)),
        candidatesAdded: 0,
        clientsConverted: 0,
        contractsClosed: 0,
      ),
      CrmUserModel(
        id: 'USR007',
        name: 'Manish Gupta',
        email: 'manish@verifiedmaids.com',
        phone: '+91 32109 87654',
        role: UserRole.executive,
        joinedDate: DateTime(2025, 1, 10),
        lastLogin: DateTime.now().subtract(const Duration(days: 5)),
        candidatesAdded: 0,
        clientsConverted: 0,
        contractsClosed: 0,
      ),
      CrmUserModel(
        id: 'USR008',
        name: 'Neha Verma',
        email: 'neha@verifiedmaids.com',
        phone: '+91 21098 76543',
        role: UserRole.sales,
        status: CrmUserStatus.inactive,
        joinedDate: DateTime(2024, 3, 15),
        lastLogin: DateTime(2025, 6, 1),
        candidatesAdded: 5,
        clientsConverted: 10,
        contractsClosed: 6,
      ),
    ];

    notifyListeners();
  }

  void _checkAndTrigger30DayPayments() {
    final now = DateTime.now();
    for (var contract in _contracts) {
      if (contract.paymentStatus == PaymentStatus.partial && contract.contractStatus == ContractStatus.active) {
        final daysSincePlacement = now.difference(contract.placementDate).inDays;
        
        // If 30 days have passed and balance is remaining
        if (daysSincePlacement >= 30 && contract.balanceAmount > 0) {
          // Check if a task already exists for this contract
          final hasTask = _tasks.any((t) => t.type == TaskType.paymentCollection && t.clientName == contract.clientName && t.status != TaskStatus.cancelled);
          
          if (!hasTask) {
            final taskId = 'TSK${now.millisecondsSinceEpoch.toString().substring(6)}${contract.id.substring(3)}';
            final executives = _crmUsers.where((u) => u.role == UserRole.executive).toList();
            final assignedTo = executives.isNotEmpty ? executives.first.id : 'USR006';

            final paymentTask = ExecutiveTaskModel(
              id: taskId,
              title: '30-Day Balance Payment',
              description: 'Collect remaining 50% balance (₹${contract.balanceAmount}) for candidate ${contract.candidateName}.',
              type: TaskType.paymentCollection,
              status: TaskStatus.pending,
              assignedTo: assignedTo,
              clientName: contract.clientName,
              clientAddress: 'Address on file',
              clientPhone: 'Phone on file',
              candidateName: contract.candidateName,
              candidatePhone: 'Phone on file',
              scheduledDate: now.add(const Duration(hours: 48)),
            );
            
            // Note: Not using addTask directly here to avoid recursive notifyListeners during initialization, 
            // but we can insert to list
            _tasks.insert(0, paymentTask);
            logAction(ActionType.create, paymentTask.id, 'Auto-created 30-Day Payment Task: ${paymentTask.title}');
          }
        }
      }
    }
  }

  // --- CRM User Methods ---
  void addCrmUser(CrmUserModel user) {
    _crmUsers.add(user);
    notifyListeners();
  }

  void updateCrmUser(CrmUserModel updated) {
    final index = _crmUsers.indexWhere((u) => u.id == updated.id);
    if (index != -1) {
      _crmUsers[index] = updated;
      notifyListeners();
    }
  }

  void toggleCrmUserStatus(String userId) {
    final index = _crmUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _crmUsers[index];
      _crmUsers[index] = user.copyWith(
        status: user.status == CrmUserStatus.active
            ? CrmUserStatus.inactive
            : CrmUserStatus.active,
      );
      notifyListeners();
    }
  }

  void resetCrmUserPassword(String userId, String newPassword) {
    final index = _crmUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _crmUsers[index] = _crmUsers[index].copyWith(password: newPassword);
      notifyListeners();
    }
  }

  // --- Notification Methods ---
  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
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
      _contracts[idx] = contract.copyWith(
        contractStatus: ContractStatus.completed,
      );

      final candidateIdx = _candidates.indexWhere(
        (m) => m.id == contract.candidateId,
      );
      if (candidateIdx != -1) {
        _candidates[candidateIdx] = _candidates[candidateIdx]
            .clearPlacement()
            .copyWith(status: CandidateStatus.readyToPlace);
      }
      logAction(
        ActionType.update,
        contract.id,
        'Contract completed. Candidate released to pool.',
      );
      notifyListeners();
    }
  }

  void markCandidateLeft(String contractId) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx != -1) {
      final contract = _contracts[idx];
      _contracts[idx] = contract.copyWith(
        contractStatus: ContractStatus.completed,
      );

      final candidateIdx = _candidates.indexWhere(
        (m) => m.id == contract.candidateId,
      );
      if (candidateIdx != -1) {
        _candidates[candidateIdx] = _candidates[candidateIdx]
            .clearPlacement()
            .copyWith(status: CandidateStatus.jobLeft);
      }
      logAction(
        ActionType.update,
        contract.id,
        'Contract completed. Candidate left job.',
      );
      notifyListeners();
    }
  }

  // --- Contract Renewal ---
  void renewContract(
    String contractId, {
    String? newCandidateId,
    String? newCandidateName,
  }) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx == -1) return;

    final oldContract = _contracts[idx];

    // Mark old contract as expired
    _contracts[idx] = oldContract.copyWith(
      contractStatus: ContractStatus.completed,
    );

    // Determine candidate for new contract
    final candidateId = newCandidateId ?? oldContract.candidateId;
    final candidateName = newCandidateName ?? oldContract.candidateName;

    // If new staff, release old candidate to pool
    if (newCandidateId != null && newCandidateId != oldContract.candidateId) {
      final oldCandidateIdx = _candidates.indexWhere(
        (m) => m.id == oldContract.candidateId,
      );
      if (oldCandidateIdx != -1) {
        _candidates[oldCandidateIdx] = _candidates[oldCandidateIdx]
            .clearPlacement()
            .copyWith(status: CandidateStatus.readyToPlace);
      }

      // Mark new candidate as placed
      final newCandidateIdx = _candidates.indexWhere(
        (m) => m.id == newCandidateId,
      );
      if (newCandidateIdx != -1) {
        _candidates[newCandidateIdx] = _candidates[newCandidateIdx].copyWith(
          status: CandidateStatus.Placed,
          datePlaced: DateTime.now(),
        );
      }
    }

    // Update client renewal count
    final clientIdx = _clients.indexWhere((c) => c.id == oldContract.clientId);
    if (clientIdx != -1) {
      final client = _clients[clientIdx];
      _clients[clientIdx] = client.copyWith(
        renewalCount: client.renewalCount + 1,
      );
    }

    // Create new renewed contract
    final now = DateTime.now();
    final newContract = ContractModel(
      id: 'CTX${now.millisecondsSinceEpoch.toString().substring(5)}',
      clientId: oldContract.clientId,
      clientName: oldContract.clientName,
      candidateId: candidateId,
      candidateName: candidateName,
      placementDate: now,
      guaranteeEndDate: now.add(const Duration(days: 90)),
      serviceFee: oldContract.serviceFee,
      amountPaid: 0,
      balanceAmount: oldContract.serviceFee,
      paymentStatus: PaymentStatus.pending,
      contractStatus: ContractStatus.active,
      isRenewal: true,
      renewedOn: now,
      createdBy: _currentUser?.name ?? 'System',
    );

    _contracts.insert(0, newContract);

    // Auto-create Candidate Drop & 50% Payment Task for Renewal
    final taskId = 'TSK${now.millisecondsSinceEpoch.toString().substring(6)}';
    
    // Find an executive to assign to
    final executives = _crmUsers.where((u) => u.role == UserRole.executive).toList();
    final assignedTo = executives.isNotEmpty ? executives.first.id : 'USR006';

    final dropTask = ExecutiveTaskModel(
      id: taskId,
      title: 'Renewal Drop & Payment',
      description: 'Drop replacement/renewed candidate $candidateName and collect 50% renewal payment from ${oldContract.clientName}.',
      type: TaskType.candidateDrop,
      status: TaskStatus.pending,
      assignedTo: assignedTo,
      clientName: oldContract.clientName,
      clientAddress: 'Address on file',
      clientPhone: 'Phone on file',
      candidateName: candidateName,
      candidatePhone: 'Phone on file',
      scheduledDate: now.add(const Duration(hours: 24)),
    );

    addTask(dropTask);

    notifyListeners();
  }

  // --- Replacement Request ---
  void requestReplacement(String contractId, String reason) {
    final idx = _contracts.indexWhere((c) => c.id == contractId);
    if (idx == -1) return;

    final contract = _contracts[idx];

    // Increment replacements used on the contract
    _contracts[idx] = contract.copyWith(
      replacementsUsed: contract.replacementsUsed + 1,
      contractStatus: ContractStatus.rePlaced,
    );

    // Create replacement request
    final now = DateTime.now();
    final request = ReplacementRequestModel(
      id: 'RPL${now.millisecondsSinceEpoch.toString().substring(5)}',
      contractId: contractId,
      clientId: contract.clientId,
      clientName: contract.clientName,
      oldCandidateId: contract.candidateId,
      oldCandidateName: contract.candidateName,
      reason: reason,
      requestDate: now,
      status: ReplacementStatus.pending,
      createdBy: _currentUser?.name ?? 'System',
    );

    _replacementRequests.insert(0, request);
    notifyListeners();
  }

  void escalateReplacementToSourcing(String requestId, String criteria) {
    final idx = _replacementRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;
    
    _replacementRequests[idx] = _replacementRequests[idx].copyWith(
      isEscalatedToSourcing: true,
      requiredCriteria: criteria,
    );
    notifyListeners();
  }

  void fulfillUrgentReplacement(String requestId, List<String> candidateIds) {
    final idx = _replacementRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;
    
    _replacementRequests[idx] = _replacementRequests[idx].copyWith(
      isEscalatedToSourcing: false, // Send back to sales
      suggestedCandidateIds: candidateIds,
    );
    
    logAction(ActionType.update, requestId, 'Sourcing provided ${candidateIds.length} candidate suggestions for replacement request.');
    notifyListeners();
  }

  // --- Assign Replacement Staff ---
  void assignReplacementStaff(
    String requestId,
    String newCandidateId,
    String newCandidateName,
  ) {
    final reqIdx = _replacementRequests.indexWhere((r) => r.id == requestId);
    if (reqIdx == -1) return;

    final request = _replacementRequests[reqIdx];

    // Update replacement request to resolved
    _replacementRequests[reqIdx] = request.copyWith(
      status: ReplacementStatus.resolved,
      newCandidateId: newCandidateId,
      resolvedDate: DateTime.now(),
    );

    // Update the contract with new candidate
    final contractIdx = _contracts.indexWhere(
      (c) => c.id == request.contractId,
    );
    if (contractIdx != -1) {
      final contract = _contracts[contractIdx];

      // Release old candidate
      final oldCandidateIdx = _candidates.indexWhere(
        (m) => m.id == contract.candidateId,
      );
      if (oldCandidateIdx != -1) {
        _candidates[oldCandidateIdx] = _candidates[oldCandidateIdx]
            .clearPlacement()
            .copyWith(status: CandidateStatus.readyToPlace);
      }

      // Place new candidate
      final newCandidateIdx = _candidates.indexWhere(
        (m) => m.id == newCandidateId,
      );
      if (newCandidateIdx != -1) {
        _candidates[newCandidateIdx] = _candidates[newCandidateIdx].copyWith(
          status: CandidateStatus.Placed,
          datePlaced: DateTime.now(),
          currentPlacementId: contract.id,
        );
      }

      // Update contract with new candidate and set back to active
      _contracts[contractIdx] = contract.copyWith(
        candidateId: newCandidateId,
        candidateName: newCandidateName,
        contractStatus: ContractStatus.active,
        isReplacementUsed: true,
        replacementDate: DateTime.now(),
        replacementCandidateId: newCandidateId,
      );
      // Auto-create Candidate Drop Task for Replacement
      final now = DateTime.now();
      final taskId = 'TSK${now.millisecondsSinceEpoch.toString().substring(6)}';
      
      // Find an executive to assign to
      final executives = _crmUsers.where((u) => u.role == UserRole.executive).toList();
      final assignedTo = executives.isNotEmpty ? executives.first.id : 'USR006';

      final dropTask = ExecutiveTaskModel(
        id: taskId,
        title: 'Replacement Drop',
        description: 'Drop replacement candidate $newCandidateName to client ${contract.clientName}.',
        type: TaskType.candidateDrop,
        status: TaskStatus.pending,
        assignedTo: assignedTo,
        clientName: contract.clientName,
        clientAddress: 'Address on file',
        clientPhone: 'Phone on file',
        candidateName: newCandidateName,
        candidatePhone: 'Phone on file',
        scheduledDate: now.add(const Duration(hours: 24)),
      );

      addTask(dropTask);
    }

    notifyListeners();
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

  void addTask(ExecutiveTaskModel task) {
    _tasks.insert(0, task);
    logAction(
      ActionType.create,
      task.id,
      'Created task: ${task.title}',
    );
    notifyListeners();
  }

  void createContract(ClientModel client, CandidateModel candidate) {
    final now = DateTime.now();
    final contractId = 'CTX${now.millisecondsSinceEpoch.toString().substring(5)}';

    final contract = ContractModel(
      id: contractId,
      clientId: client.id,
      clientName: client.fullName,
      candidateId: candidate.id,
      candidateName: candidate.fullName,
      placementDate: now,
      guaranteeEndDate: now.add(const Duration(days: 90)),
      serviceFee: 25000,
      amountPaid: 0,
      balanceAmount: 25000,
      paymentStatus: PaymentStatus.pending,
      contractStatus: ContractStatus.active,
      createdBy: _currentUser?.name ?? 'System',
    );

    _contracts.insert(0, contract);

    // Update Client
    updateClient(client.copyWith(status: ClientStatus.converted));

    // Update Candidate
    updateCandidate(
      candidate.copyWith(
        status: CandidateStatus.Placed,
        datePlaced: now,
        currentPlacementId: contract.id,
      ),
      'Assigned to client ${client.fullName}',
    );

    // Auto-create Candidate Drop & 50% Payment Task
    final taskId = 'TSK${now.millisecondsSinceEpoch.toString().substring(6)}';
    
    // Find an executive to assign to
    final executives = _crmUsers.where((u) => u.role == UserRole.executive).toList();
    final assignedTo = executives.isNotEmpty ? executives.first.id : 'USR006';

    final dropTask = ExecutiveTaskModel(
      id: taskId,
      title: 'Candidate Drop & Initial Payment',
      description: 'Drop candidate ${candidate.fullName} and collect 50% initial payment from ${client.fullName}.',
      type: TaskType.candidateDrop,
      status: TaskStatus.pending,
      assignedTo: assignedTo,
      clientName: client.fullName,
      clientAddress: '${client.address}, ${client.city}',
      clientPhone: client.phone,
      candidateName: candidate.fullName,
      candidatePhone: candidate.phone,
      scheduledDate: now.add(const Duration(hours: 24)),
    );

    addTask(dropTask);

    logAction(
      ActionType.create,
      contractId,
      'Created new contract and auto-assigned Drop Task ($taskId)',
    );
    
    notifyListeners();
  }

  // --- Client Modifications ---
  void addClient(ClientModel client) {
    _clients.insert(0, client);
    logAction(
      ActionType.create,
      client.id,
      'Added new client inquiry: ${client.fullName}',
    );
    notifyListeners();
  }

  void updateClient(ClientModel updatedClient) {
    final idx = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (idx != -1) {
      _clients[idx] = updatedClient;
      logAction(
        ActionType.update,
        updatedClient.id,
        'Updated client status to ${updatedClient.status.displayName}',
      );
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
        dateVerificationSent:
            newStatus == CandidateStatus.verificationPending
                ? now
                : candidate.dateVerificationSent,
        dateMedicalSent:
            newStatus == CandidateStatus.medicalPending
                ? now
                : candidate.dateMedicalSent,
        dateReadyToHire:
            newStatus == CandidateStatus.readyToPlace
                ? now
                : candidate.dateReadyToHire,
        datePlaced:
            newStatus == CandidateStatus.Placed ? now : candidate.datePlaced,
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
      logAction(
        ActionType.statusChange,
        candidate.id,
        'Blacklisted candidate: $reason',
      );
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

  void updateInvoiceStatus(String invoiceId, InvoiceStatus newStatus) {
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index != -1) {
      final old = _invoices[index];
      _invoices[index] = InvoiceModel(
        id: old.id,
        clientId: old.clientId,
        clientName: old.clientName,
        candidateName: old.candidateName,
        amount: old.amount,
        date: old.date,
        dueDate: old.dueDate,
        status: newStatus,
      );

      _auditLogs.insert(
        0,
        AuditLogModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          userId: _currentUser?.id.toString() ?? 'unknown',
          userName: _currentUser?.name ?? 'Unknown',
          userRole: _currentUser?.role ?? UserRole.sales,
          actionType: ActionType.statusChange,
          targetId: invoiceId,
          description: 'Invoice Status changed to ${newStatus.displayName}',
        ),
      );

      notifyListeners();
    }
  }
}
