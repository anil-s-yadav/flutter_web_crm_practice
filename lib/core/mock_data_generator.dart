import 'dart:math';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/executive_task_model.dart';
import 'package:practice_app/core/pagination.dart';

class MockDataGenerator {
  // Realistic Indian name pools
  static const _femaleFirstNames = [
    'Sunita', 'Lakshmi', 'Meena', 'Fatima', 'Radha', 'Priya', 'Kavita', 'Savita',
    'Rekha', 'Geeta', 'Asha', 'Pushpa', 'Kamla', 'Saroj', 'Renu', 'Suman',
    'Anita', 'Rita', 'Seema', 'Neelam', 'Parvati', 'Sarita', 'Kiran', 'Manju',
    'Usha', 'Lata', 'Shakuntala', 'Durga', 'Sita', 'Rukmini', 'Padma', 'Indira',
    'Nirmala', 'Kusum', 'Jyoti', 'Bhavna', 'Deepa', 'Hema', 'Manisha', 'Pooja',
    'Ranjana', 'Shobha', 'Vimla', 'Gayatri', 'Sneha', 'Komal', 'Pallavi', 'Swati',
    'Nalini', 'Chanda', 'Basanti', 'Laxmi', 'Tulsi', 'Malti', 'Janki', 'Devki',
    'Phoolmati', 'Ramkali', 'Sukhiya', 'Bhuri'
  ];

  static const _lastNames = [
    'Devi', 'Sharma', 'Patil', 'Sheikh', 'Kumari', 'Iyer', 'Nair', 'Gupta',
    'Yadav', 'Singh', 'Patel', 'Reddy', 'Chauhan', 'Verma', 'Joshi', 'Tiwari',
    'Mishra', 'Pandey', 'Das', 'Roy', 'Khan', 'Ansari', 'Bano', 'Bibi',
    'Kulkarni', 'Deshmukh', 'Jadhav', 'More', 'Pawar', 'Shinde', 'Kamble',
    'Gaikwad', 'Bhosale', 'Chavan', 'Solanki', 'Rathod', 'Thakur', 'Pillai',
    'Menon', 'Naidu', 'Choudhary', 'Rawat', 'Bhat', 'Kaur', 'Begum'
  ];

  static const _maleFirstNames = [
    'Rajesh', 'Amit', 'Vikram', 'Suresh', 'Mahesh', 'Ramesh', 'Anil', 'Sanjay',
    'Rohit', 'Deepak', 'Rahul', 'Ajay', 'Vijay', 'Prakash', 'Sunil', 'Manoj',
    'Nitin', 'Sachin', 'Ravi', 'Kiran', 'Arjun', 'Pradeep', 'Ashok', 'Gopal',
    'Mohan', 'Shyam', 'Dinesh', 'Mukesh', 'Naveen', 'Pankaj', 'Gaurav', 'Varun'
  ];

  static const _cities = [
    'Thane', 'Dadar', 'Andheri', 'Bandra', 'Borivali', 'Powai', 'Juhu', 'Worli',
    'Malad', 'Goregaon', 'Kandivali', 'Vikhroli', 'Mulund', 'Chembur', 'Kurla',
    'Ghatkopar', 'Vashi', 'Nerul', 'Panvel', 'Airoli', 'Kharghar', 'Dombivli',
    'Kalyan', 'Mira Road', 'Dahisar', 'Colaba', 'Lower Parel', 'Wadala',
    'Sion', 'Parel'
  ];

  static const _localities = [
    'Hiranandani Gardens', 'Lodha Palava', 'Raheja Vihar', 'Oberoi Splendor',
    'Godrej Prime', 'Kalpataru Aura', 'Runwal Forest', 'Rustomjee Seasons',
    'Dosti Vihar', 'Kanakia Zenworld', 'Sunteck City', 'Indiabulls Greens',
    'Marathon Nexzone', 'JP Infra', 'Shapoorji Pallonji', 'Birla Vanya',
    'Prestige Group', 'DLF Garden City', 'Hiranandani Meadows', 'Lodha Crown'
  ];

  static const _skills = [
    'Cooking', 'Cleaning', 'Childcare', 'Elderly Care', 'Laundry', 'Ironing',
    'Mopping', 'Dusting', 'Dishwashing', 'Gardening', 'Pet Care', 'Driving'
  ];

  static const _languages = [
    'Hindi', 'Marathi', 'English', 'Tamil', 'Telugu', 'Kannada',
    'Malayalam', 'Bengali', 'Gujarati', 'Urdu', 'Punjabi', 'Odia'
  ];

  static const _religions = ['Hindu', 'Muslim', 'Christian', 'Buddhist', 'Sikh', 'Jain'];
  static const _categories = ['Candidate', 'Cook', 'Nanny', 'Caretaker', 'Driver', 'Gardener'];
  static const _educationLevels = ['Below 10th', '10th Pass', '12th Pass', 'Graduate'];
  static const _houseTypes = ['1BHK', '2BHK', '3BHK', '4BHK', 'Villa', 'Bungalow', 'Penthouse', 'Duplex'];
  static const _sources = ['Website', 'Referral', 'JustDial', 'Walk-in', 'Google Ads', 'Instagram', 'Facebook', 'Sulekha', 'UrbanCompany'];

  static const int totalCandidates = 500000;
  static const int totalClients = 100000;
  static const int totalContracts = 80000;
  static const int totalTickets = 15000;

  /// Generate a deterministic candidate for a given index (0-based)
  static CandidateModel generateCandidate(int index) {
    final rng = Random(index * 31 + 7);
    final firstName = _femaleFirstNames[index % _femaleFirstNames.length];
    final lastName = _lastNames[(index ~/ _femaleFirstNames.length) % _lastNames.length];
    final fullName = '$firstName $lastName';
    final city = _cities[rng.nextInt(_cities.length)];
    final age = 20 + rng.nextInt(35);
    final exp = rng.nextInt(age - 18).clamp(0, 20);
    final statusValues = CandidateStatus.values;
    // Weight distribution: newlyAdded, verificationPending, medicalPending, readyToPlace, placed, blacklisted
    final statusWeights = [0.10, 0.15, 0.10, 0.30, 0.30, 0.05];
    double roll = rng.nextDouble();
    CandidateStatus status = CandidateStatus.newlyAdded;
    double cumulative = 0;
    for (int i = 0; i < statusWeights.length; i++) {
      cumulative += statusWeights[i];
      if (roll <= cumulative) {
        status = statusValues[i];
        break;
      }
    }
    
    final numLangs = 1 + rng.nextInt(3);
    final shuffledLangs = List<String>.from(_languages)..shuffle(rng);
    final salaryBase = 8000 + rng.nextInt(25000);
    final salaryEnd = salaryBase + 3000 + rng.nextInt(5000);
    final category = _categories[rng.nextInt(_categories.length)];
    final education = _educationLevels[rng.nextInt(_educationLevels.length)];
    
    // Determine boolean flags based on status pipeline
    bool isPoliceVerified = false;
    bool isAadhaarVerified = false;
    bool isMedicalCleared = false;
    
    if (status == CandidateStatus.readyToPlace || status == CandidateStatus.placed) {
      isPoliceVerified = true;
      isAadhaarVerified = true;
      isMedicalCleared = rng.nextDouble() > 0.5; // Some ready to place are not medically cleared
    } else if (status == CandidateStatus.medicalPending) {
      isPoliceVerified = true;
      isAadhaarVerified = true;
    } else if (status == CandidateStatus.verificationPending) {
      isPoliceVerified = rng.nextDouble() > 0.5;
      isAadhaarVerified = rng.nextDouble() > 0.5;
    }
    
    final workTypes = ['Live-in', '12-hour', '24-hour', 'Part-time'];

    return CandidateModel(
      id: 'VMC${1001 + index}',
      fullName: fullName,
      age: age,
      phone: '98${(10000000 + index % 90000000).toString().padLeft(8, '0')}',
      altPhone: rng.nextBool() ? '91${(10000000 + rng.nextInt(90000000)).toString().padLeft(8, '0')}' : null,
      address: '${rng.nextInt(500) + 1}, ${_localities[rng.nextInt(_localities.length)]}',
      city: city,
      state: 'Maharashtra',
      languages: shuffledLangs.take(numLangs).toList(),
      religion: _religions[rng.nextInt(_religions.length)],
      category: category,
      education: education,
      experienceYears: exp,
      expectedSalary: '\u20B9${salaryBase ~/ 1000}K - \u20B9${salaryEnd ~/ 1000}K',
      workingHoursPerDay: 6 + rng.nextInt(7),
      status: status,
      isMedicalCleared: isMedicalCleared,
      isPoliceVerified: isPoliceVerified,
      isAadhaarVerified: isAadhaarVerified,
      currentPlacementId: status == CandidateStatus.placed ? 'CTX${3001 + rng.nextInt(totalContracts)}' : null,
      addedBy: '${_maleFirstNames[rng.nextInt(_maleFirstNames.length)]} ${_lastNames[rng.nextInt(_lastNames.length)]}',
      dateAdded: DateTime.now().subtract(Duration(days: rng.nextInt(730) + 30)),
      dateVerificationSent: status.index >= CandidateStatus.verificationPending.index ? DateTime.now().subtract(Duration(days: rng.nextInt(30) + 20)) : null,
      dateMedicalSent: status.index >= CandidateStatus.medicalPending.index ? DateTime.now().subtract(Duration(days: rng.nextInt(20) + 10)) : null,
      dateReadyToHire: status.index >= CandidateStatus.readyToPlace.index ? DateTime.now().subtract(Duration(days: rng.nextInt(10) + 5)) : null,
      datePlaced: status == CandidateStatus.placed ? DateTime.now().subtract(Duration(days: rng.nextInt(5))) : null,
      availableFrom: status == CandidateStatus.readyToPlace ? DateTime.now().add(Duration(days: rng.nextInt(30))) : null,
      preferredWorkType: workTypes[rng.nextInt(workTypes.length)],
    );
  }

  /// Generate a deterministic client for a given index
  static ClientModel generateClient(int index) {
    final rng = Random(index * 43 + 13);
    final isMale = rng.nextBool();
    final prefix = isMale ? 'Mr.' : 'Mrs.';
    final firstName = isMale
        ? _maleFirstNames[index % _maleFirstNames.length]
        : _femaleFirstNames[index % _femaleFirstNames.length];
    final lastName = _lastNames[(index ~/ (isMale ? _maleFirstNames.length : _femaleFirstNames.length)) % _lastNames.length];
    final fullName = '$prefix $firstName $lastName';
    final city = _cities[rng.nextInt(_cities.length)];
    final locality = _localities[rng.nextInt(_localities.length)];
    final statusValues = ClientStatus.values;
    final statusWeights = [0.20, 0.15, 0.10, 0.05, 0.10, 0.30, 0.10];
    double roll = rng.nextDouble();
    ClientStatus status = ClientStatus.newInquiry;
    double cumulative = 0;
    for (int i = 0; i < statusWeights.length; i++) {
      cumulative += statusWeights[i];
      if (roll <= cumulative) {
        status = statusValues[i];
        break;
      }
    }
    final familySize = 2 + rng.nextInt(6);
    final hasPets = rng.nextDouble() < 0.15;
    final hasChildren = rng.nextDouble() < 0.5;
    final hasElderly = rng.nextDouble() < 0.25;
    final numSkills = 1 + rng.nextInt(3);
    final shuffledSkills = List<String>.from(_skills)..shuffle(rng);
    final budgetBase = 10000 + rng.nextInt(30000);
    final budgetEnd = budgetBase + 5000 + rng.nextInt(10000);

    return ClientModel(
      id: 'CLI${2001 + index}',
      fullName: fullName,
      phone: '98${(20000000 + index % 80000000).toString().padLeft(8, '0')}',
      altPhone: rng.nextBool() ? '91${(30000000 + rng.nextInt(70000000)).toString().padLeft(8, '0')}' : null,
      email: '${firstName.toLowerCase()}.${lastName.toLowerCase()}$index@gmail.com',
      address: '${rng.nextInt(200) + 1}, $locality, $city',
      city: city,
      locality: locality,
      houseType: _houseTypes[rng.nextInt(_houseTypes.length)],
      familySize: familySize,
      hasPets: hasPets,
      petDetails: hasPets ? (rng.nextBool() ? 'Dog' : 'Cat') : null,
      hasElderlyMembers: hasElderly,
      hasChildren: hasChildren,
      childrenCount: hasChildren ? 1 + rng.nextInt(3) : null,
      preferredCandidateCategory: _categories[rng.nextInt(_categories.length)],
      requiredSkills: shuffledSkills.take(numSkills).toList(),
      budgetRange: '\u20B9${budgetBase ~/ 1000}K - \u20B9${budgetEnd ~/ 1000}K',
      status: status,
      assignedEmployeeId: 'EMP${5001 + rng.nextInt(20)}',
      source: _sources[rng.nextInt(_sources.length)],
      inquiryDate: DateTime.now().subtract(Duration(days: rng.nextInt(365))),
      remarks: rng.nextDouble() < 0.3 ? 'Follow up needed' : null
    );
  }

  /// Generate a deterministic contract for a given index
  static ContractModel generateContract(int index) {
    final rng = Random(index * 53 + 19);
    final clientIdx = index % totalClients;
    final candidateIdx = index % totalCandidates;
    final client = generateClient(clientIdx);
    final candidate = generateCandidate(candidateIdx);
    final placementDate = DateTime.now().subtract(Duration(days: rng.nextInt(365)));
    final guaranteeEnd = placementDate.add(const Duration(days: 180));
    final fee = (15000 + rng.nextInt(35000)).toDouble();
    final paid = rng.nextDouble() < 0.7 ? fee : (fee * (0.3 + rng.nextDouble() * 0.5));
    final paymentStatus = paid >= fee
        ? PaymentStatus.paid
        : paid > 0
            ? PaymentStatus.partial
            : rng.nextBool()
                ? PaymentStatus.pending
                : PaymentStatus.overdue;
    final contractStatus = DateTime.now().isAfter(guaranteeEnd)
        ? ContractStatus.completed
        : ContractStatus.active;

    return ContractModel(
      id: 'CTX${3001 + index}',
      clientId: client.id,
      candidateId: candidate.id,
      clientName: client.fullName,
      candidateName: candidate.fullName,
      placementDate: placementDate,
      guaranteeEndDate: guaranteeEnd,
      serviceFee: fee,
      amountPaid: paid,
      balanceAmount: fee - paid,
      paymentStatus: paymentStatus,
      contractStatus: contractStatus,
      createdBy: 'Priya Mehta'
    );
  }

  /// Generate a deterministic ticket for a given index
  static TicketModel generateTicket(int index) {
    final rng = Random(index * 67 + 23);
    final priorityValues = TicketPriority.values;
    final priority = priorityValues[rng.nextInt(priorityValues.length)];
    final statusValues = TicketStatus.values;
    final status = statusValues[rng.nextInt(statusValues.length)];
    final clientIdx = rng.nextInt(totalClients);
    final client = generateClient(clientIdx);
    final candidateIdx = rng.nextInt(totalCandidates);
    final candidate = generateCandidate(candidateIdx);
    final createdAt = DateTime.now().subtract(Duration(days: rng.nextInt(60)));
    final titles = {
      TicketPriority.critical: [
        'Candidate Not Reporting',
        'Security Concern - Theft Reported',
        'Candidate Absconded',
        'Unauthorized Person Sent',
        'Violent Behavior Reported'
      ],
      TicketPriority.urgent: [
        'Replacement Requested',
        'Salary Dispute',
        'Contract Termination Request',
        'Immediate Replacement Needed',
        'Service Quality Complaint'
      ],
      TicketPriority.standard: [
        'Late Arrivals',
        'Minor Behavioral Feedback',
        'Schedule Change Request',
        'Cooking Quality Feedback',
        'Cleaning Standard Below Expectation'
      ]
    };
    final titleList = titles[priority]!;
    final title = titleList[rng.nextInt(titleList.length)];

    return TicketModel(
      id: 'TKT${4001 + index}',
      title: title,
      description: 'Ticket raised by ${client.fullName} regarding ${candidate.fullName}. $title.',
      priority: priority,
      status: status,
      clientId: client.id,
      clientName: client.fullName,
      candidateId: candidate.id,
      candidateName: candidate.fullName,
      assignedTo: '${_maleFirstNames[rng.nextInt(_maleFirstNames.length)]} ${_lastNames[rng.nextInt(_lastNames.length)]}',
      createdAt: createdAt,
      slaDeadline: priority == TicketPriority.urgent ? createdAt.add(const Duration(days: 15)) : null,
      resolvedAt: status == TicketStatus.resolved || status == TicketStatus.closed ? createdAt.add(Duration(days: 1 + rng.nextInt(10))) : null,
      resolution: status == TicketStatus.resolved ? 'Issue resolved after discussion with both parties.' : null
    );
  }

  /// Generate a deterministic executive task for a given index
  static ExecutiveTaskModel generateTask(int index) {
    final rng = Random(index * 79 + 29);
    final typeValues = TaskType.values;
    final type = typeValues[rng.nextInt(typeValues.length)];
    final statusValues = TaskStatus.values;
    final status = statusValues[rng.nextInt(statusValues.length)];
    final clientIdx = rng.nextInt(totalClients);
    final client = generateClient(clientIdx);
    final city = _cities[rng.nextInt(_cities.length)];
    final titleMap = {
      TaskType.candidateDrop: 'Drop Candidate to ${client.fullName}',
      TaskType.paymentCollection: 'Collect Payment from ${client.fullName}',
      TaskType.documentPickup: 'Pick Documents from $city',
      TaskType.clientVisit: 'Visit ${client.fullName} for Verification'
    };

    return ExecutiveTaskModel(
      id: 'TASK${(index + 1).toString().padLeft(6, '0')}',
      title: titleMap[type]!,
      description: 'Scheduled task for ${type.displayName} at ${client.fullName}, $city.',
      type: type,
      status: status,
      assignedTo: 'Vikram Singh',
      clientName: client.fullName,
      clientAddress: '${rng.nextInt(500) + 1}, ${_localities[rng.nextInt(_localities.length)]}, $city',
      clientPhone: client.phone,
      candidateName: type == TaskType.candidateDrop ? '${_femaleFirstNames[rng.nextInt(_femaleFirstNames.length)]} ${_lastNames[rng.nextInt(_lastNames.length)]}' : null,
      gpsLink: 'https://maps.google.com/?q=19.${rng.nextInt(200)},72.${rng.nextInt(200)}',
      scheduledDate: DateTime.now().add(Duration(days: rng.nextInt(7) - 1)),
      isPaymentCollected: type == TaskType.paymentCollection && status == TaskStatus.completed,
      paymentAmount: type == TaskType.paymentCollection ? (15000 + rng.nextInt(30000)).toDouble() : null
    );
  }

  // ============ PAGINATED QUERIES (simulate server-side pagination) ============

  static PaginatedResult<CandidateModel> getCandidates(PaginationParams params) {
    int filteredTotal = totalCandidates;
    final query = params.searchQuery?.toLowerCase();
    // For search: simulate reduced result count
    if (query != null && query.isNotEmpty) {
      filteredTotal = (totalCandidates * 0.05).round().clamp(0, totalCandidates);
    }
    // For status filter
    if (params.filters.containsKey('status')) {
      filteredTotal = (filteredTotal * 0.15).round();
    }
    if (params.filters.containsKey('category')) {
      filteredTotal = (filteredTotal * 0.18).round();
    }
    if (params.filters.containsKey('city')) {
      filteredTotal = (filteredTotal * 0.05).round();
    }
    filteredTotal = filteredTotal.clamp(0, totalCandidates);

    final startIndex = (params.page - 1) * params.pageSize;
    if (startIndex >= filteredTotal) {
      return PaginatedResult(
        items: [],
        totalCount: filteredTotal,
        currentPage: params.page,
        pageSize: params.pageSize,
        hasMore: false
      );
    }
    final endIndex = (startIndex + params.pageSize).clamp(0, filteredTotal);
    final items = <CandidateModel>[];
    // Use a different seed offset for search/filter to give different results
    final seedOffset = query != null ? query.length * 1000 : 0;
    for (int i = startIndex; i < endIndex; i++) {
      items.add(generateCandidate(i + seedOffset));
    }
    return PaginatedResult(
      items: items,
      totalCount: filteredTotal,
      currentPage: params.page,
      pageSize: params.pageSize,
      hasMore: endIndex < filteredTotal
    );
  }

  static PaginatedResult<ClientModel> getClients(PaginationParams params) {
    int filteredTotal = totalClients;
    final query = params.searchQuery?.toLowerCase();
    if (query != null && query.isNotEmpty) {
      filteredTotal = (totalClients * 0.05).round().clamp(0, totalClients);
    }
    if (params.filters.containsKey('status')) {
      filteredTotal = (filteredTotal * 0.15).round();
    }
    if (params.filters.containsKey('city')) {
      filteredTotal = (filteredTotal * 0.05).round();
    }
    filteredTotal = filteredTotal.clamp(0, totalClients);

    final startIndex = (params.page - 1) * params.pageSize;
    if (startIndex >= filteredTotal) {
      return PaginatedResult(
        items: [],
        totalCount: filteredTotal,
        currentPage: params.page,
        pageSize: params.pageSize,
        hasMore: false
      );
    }
    final endIndex = (startIndex + params.pageSize).clamp(0, filteredTotal);
    final items = <ClientModel>[];
    final seedOffset = query != null ? query.length * 2000 : 0;
    for (int i = startIndex; i < endIndex; i++) {
      items.add(generateClient(i + seedOffset));
    }
    return PaginatedResult(
      items: items,
      totalCount: filteredTotal,
      currentPage: params.page,
      pageSize: params.pageSize,
      hasMore: endIndex < filteredTotal
    );
  }

  static PaginatedResult<ContractModel> getContracts(PaginationParams params) {
    int filteredTotal = totalContracts;
    if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
      filteredTotal = (totalContracts * 0.05).round();
    }
    filteredTotal = filteredTotal.clamp(0, totalContracts);
    final startIndex = (params.page - 1) * params.pageSize;
    if (startIndex >= filteredTotal) {
      return PaginatedResult(
        items: [],
        totalCount: filteredTotal,
        currentPage: params.page,
        pageSize: params.pageSize,
        hasMore: false
      );
    }
    final endIndex = (startIndex + params.pageSize).clamp(0, filteredTotal);
    final items = <ContractModel>[];
    for (int i = startIndex; i < endIndex; i++) {
      items.add(generateContract(i));
    }
    return PaginatedResult(
      items: items,
      totalCount: filteredTotal,
      currentPage: params.page,
      pageSize: params.pageSize,
      hasMore: endIndex < filteredTotal
    );
  }

  static PaginatedResult<TicketModel> getTickets(PaginationParams params) {
    int filteredTotal = totalTickets;
    if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
      filteredTotal = (totalTickets * 0.1).round();
    }
    if (params.filters.containsKey('priority')) {
      filteredTotal = (filteredTotal * 0.33).round();
    }
    filteredTotal = filteredTotal.clamp(0, totalTickets);
    final startIndex = (params.page - 1) * params.pageSize;
    if (startIndex >= filteredTotal) {
      return PaginatedResult(
        items: [],
        totalCount: filteredTotal,
        currentPage: params.page,
        pageSize: params.pageSize,
        hasMore: false
      );
    }
    final endIndex = (startIndex + params.pageSize).clamp(0, filteredTotal);
    final items = <TicketModel>[];
    for (int i = startIndex; i < endIndex; i++) {
      items.add(generateTicket(i));
    }
    return PaginatedResult(
      items: items,
      totalCount: filteredTotal,
      currentPage: params.page,
      pageSize: params.pageSize,
      hasMore: endIndex < filteredTotal
    );
  }

  static PaginatedResult<ExecutiveTaskModel> getTasks(PaginationParams params) {
    const total = 500;
    final startIndex = (params.page - 1) * params.pageSize;
    if (startIndex >= total) {
      return PaginatedResult(
        items: [],
        totalCount: total,
        currentPage: params.page,
        pageSize: params.pageSize,
        hasMore: false
      );
    }
    final endIndex = (startIndex + params.pageSize).clamp(0, total);
    final items = <ExecutiveTaskModel>[];
    for (int i = startIndex; i < endIndex; i++) {
      items.add(generateTask(i));
    }
    return PaginatedResult(
      items: items,
      totalCount: total,
      currentPage: params.page,
      pageSize: params.pageSize,
      hasMore: endIndex < total
    );
  }

  // ============ DASHBOARD STATS ============
  static Map<String, dynamic> getAdminStats() => {
    'totalRevenue': 42500000,
    'activePlacements': 32450,
    'candidateAttritionRate': 8.5,
    'urgentTickets': 234,
    'totalCandidates': totalCandidates,
    'totalClients': totalClients,
    'totalContracts': totalContracts,
    'openTickets': 1580
  };

  static Map<String, dynamic> getSalesStats() => {
    'newInquiries': 1250,
    'activeContracts': 32450,
    'slaCountdowns': 45,
    'totalLeads': 8500,
    'followUps': 3200,
    'urgentFollowUps': 18,
    'noResponse': 1800,
    'converted': 2100,
    'monthlyRevenue': 3850000,
    'targetRevenue': 5000000
  };

  static Map<String, dynamic> getSourcingStats() => {
    'newlyAdded': 4500,
    'verificationPending': 1900,
    'medicalPending': 2800,
    'readyToPlace': 150000,
    'readyToPlaceNoMedical': 90000,
    'readyToPlaceMedical': 60000,
    'placed': 150000,
    'blacklisted': 1200,
    'addedLastMonth': 850,
    'addedThisMonth': 680,
    'targetThisMonth': 1000,
    'totalCandidates': 500000,
  };

  static Map<String, dynamic> getExecutiveStats() => {
    'dropsLastMonth': 42,
    'dropsLastWeek': 15,
    'dropsThisWeek': 12,
    'dropsThisMonth': 38,
    'totalDrops': 345,
    'todaysPendingDrops': 5,
    'todaysAssignedDrops': 8,
  };
}
