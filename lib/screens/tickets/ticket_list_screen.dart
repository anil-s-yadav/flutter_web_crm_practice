import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:practice_app/core/debouncer.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/core/pagination.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/screens/tickets/ticket_data_source.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  List<TicketModel> _allTickets = [];
  List<TicketModel> _filteredTickets = [];
  TicketDataSource? _ticketDataSource;
  String _searchQuery = '';
  TicketStatus? _selectedStatus;
  TicketPriority? _selectedPriority;

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeDataSource();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _loadData() {
    // Generate some mock tickets
    final result = MockDataGenerator.getTickets(
      const PaginationParams(page: 1, pageSize: 1000),
    );
    _allTickets = result.items;
  }

  void _initializeDataSource() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var filteredTickets = _allTickets;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredTickets =
          filteredTickets.where((t) {
            return t.id.toLowerCase().contains(q) ||
                t.title.toLowerCase().contains(q) ||
                t.clientName.toLowerCase().contains(q) ||
                t.assignedTo.toLowerCase().contains(q);
          }).toList();
    }

    if (_selectedStatus != null) {
      filteredTickets =
          filteredTickets.where((t) => t.status == _selectedStatus).toList();
    }

    if (_selectedPriority != null) {
      filteredTickets =
          filteredTickets
              .where((t) => t.priority == _selectedPriority)
              .toList();
    }

    if (_ticketDataSource == null) {
      _ticketDataSource = TicketDataSource(
        context: context,
        isDark: isDark,
        tickets: filteredTickets,
        onRowTap: (ticket) {
          final basePath = GoRouterState.of(context).matchedLocation;
          context.push('$basePath/${ticket.id}');
        },
      );
    } else {
      _ticketDataSource!.isDark = isDark;
      _ticketDataSource!.updateData(filteredTickets);
    }

    _filteredTickets = filteredTickets;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (_ticketDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = context.media.width < 800;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile Toolbar
          if (isMobile) _buildMobileToolbar(isDark, _filteredTickets.length),

          if (!isMobile || _showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  isMobile
                      ? Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: _buildFilterWidgets(isDark, context),
                      )
                      : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_indianFormat.format(_filteredTickets.length)} Tickets found',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ..._buildFilterWidgetsDesktop(isDark, context),
                        ],
                      ),
            ),

          // DataGrid
          Expanded(
            child:
                MediaQuery.of(context).size.width < 800
                    ? _buildMobileListView(_filteredTickets, isDark)
                    : Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SfDataGridTheme(
                            data: SfDataGridThemeData(
                              headerColor:
                                  isDark
                                      ? AppColors.darkSurface
                                      : AppColors.grey50,
                              gridLineColor:
                                  isDark
                                      ? AppColors.dividerDark
                                      : AppColors.grey200,
                              gridLineStrokeWidth: 1,
                              rowHoverColor:
                                  isDark
                                      ? AppColors.navyBlue.withValues(
                                        alpha: 0.1,
                                      )
                                      : AppColors.navyBlue.withValues(
                                        alpha: 0.04,
                                      ),
                              sortIconColor: AppColors.gold,
                            ),
                            child: SfDataGrid(
                              source: _ticketDataSource!,

                              allowSorting: true,
                              allowMultiColumnSorting: false,
                              columnWidthMode: ColumnWidthMode.auto,
                              headerRowHeight: 48,
                              rowHeight: 56,
                              gridLinesVisibility: GridLinesVisibility.both,
                              headerGridLinesVisibility:
                                  GridLinesVisibility.both,
                              columns: [
                                GridColumn(
                                  columnName: 'id',
                                  visible: false,
                                  label: const SizedBox.shrink(),
                                ),
                                GridColumn(
                                  columnName: 'sr_no',
                                  width: 100,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Ticket ID',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'date',
                                  width: 130,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Created At',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'details',
                                  maximumWidth: 300,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Details',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'priority',
                                  width: 120,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Priority',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'status',
                                  width: 120,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Status',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'assigned',
                                  width: 140,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Assigned To',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'actions',
                                  width: 100,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Action',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
          ),

          // Pagination
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.white.withValues(alpha: 0.1)
                              : AppColors.criticalRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_indianFormat.format(_ticketDataSource!.rows.length)} Tickets',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.criticalRed,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconButton(
                        icon: Icon(Icons.chevron_left, size: 20),
                        onPressed: null, // Stubbed for mock data
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Page 1 of 1',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const IconButton(
                        icon: Icon(Icons.chevron_right, size: 20),
                        onPressed: null, // Stubbed for mock data
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(width: 100), // Balance space
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterWidgets(bool isDark, BuildContext context) {
    return [
      _buildSearchField(isDark),
      _buildPriorityDropdown(isDark),
      _buildStatusDropdown(isDark),
      _buildAddButton(context),
    ];
  }

  List<Widget> _buildFilterWidgetsDesktop(bool isDark, BuildContext context) {
    return [
      _buildPriorityDropdown(isDark),
      const SizedBox(width: 8),
      _buildStatusDropdown(isDark),
      const SizedBox(width: 8),
      _buildAddButton(context),
      const SizedBox(width: 12),
      _buildSearchField(isDark),
    ];
  }

  Widget _buildSearchField(bool isDark) {
    return SizedBox(
      width: 250,
      height: 38,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search by title, client...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? AppColors.grey500 : AppColors.grey400,
          ),
          prefixIcon: const Icon(Icons.search, size: 18),
          filled: true,
          fillColor: isDark ? AppColors.cardDark : AppColors.grey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }

  Widget _buildPriorityDropdown(bool isDark) {
    return SizedBox(
      width: 140,
      height: 38,
      child: DropdownButtonFormField<TicketPriority?>(
        isExpanded: true,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        initialValue: _selectedPriority,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.grey300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.grey300,
            ),
          ),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('All Priorities')),
          ...TicketPriority.values.map(
            (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
          ),
        ],
        onChanged: (val) {
          setState(() => _selectedPriority = val);
          _initializeDataSource();
        },
      ),
    );
  }

  Widget _buildStatusDropdown(bool isDark) {
    return SizedBox(
      width: 140,
      height: 38,
      child: DropdownButtonFormField<TicketStatus?>(
        isExpanded: true,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        initialValue: _selectedStatus,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.grey300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.grey300,
            ),
          ),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('All Statuses')),
          ...TicketStatus.values.map(
            (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
          ),
        ],
        onChanged: (val) {
          setState(() => _selectedStatus = val);
          _initializeDataSource();
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: () => _showAddTicketDialog(context),
        icon: const Icon(Icons.add, size: 16),
        label: Text('Add Ticket', style: GoogleFonts.poppins(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildMobileToolbar(bool isDark, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppColors.white.withValues(alpha: 0.1)
                      : AppColors.criticalRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_indianFormat.format(count)} Tickets found',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.criticalRed,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.navyBlue),
            onPressed: () => _showAddTicketDialog(context),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.grey300,
                ),
                borderRadius: BorderRadius.circular(8),
                color:
                    _showFilters
                        ? (isDark
                            ? AppColors.white.withValues(alpha: 0.1)
                            : AppColors.grey200)
                        : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color:
                        _showFilters
                            ? AppColors.navyBlue
                            : (isDark ? AppColors.grey400 : AppColors.grey600),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          _showFilters
                              ? AppColors.navyBlue
                              : (isDark
                                  ? AppColors.grey400
                                  : AppColors.grey600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTicketDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final clientController = TextEditingController();
    final assignedController = TextEditingController();
    TicketPriority selectedPriority = TicketPriority.standard;

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey300,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Create New Ticket',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: inputDecoration('Ticket Title'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? AppColors.white : AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        decoration: inputDecoration('Description'),
                        maxLines: 3,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? AppColors.white : AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TicketPriority>(
                        initialValue: selectedPriority,
                        decoration: inputDecoration('Priority'),
                        dropdownColor:
                            isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.white,
                        items:
                            TicketPriority.values
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p.displayName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color:
                                            isDark
                                                ? AppColors.white
                                                : AppColors.grey900,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedPriority = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: clientController,
                        decoration: inputDecoration('Client Name'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? AppColors.white : AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: assignedController,
                        decoration: inputDecoration('Assigned To'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? AppColors.white : AppColors.grey900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logic to create ticket (mock)
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ticket created successfully!',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: AppColors.successGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Create Ticket',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMobileListView(List<TicketModel> tickets, bool isDark) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: isDark ? AppColors.grey700 : AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No tickets match your filters.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final ticket = tickets[index];

        return Card(
          elevation: 0,
          color: isDark ? AppColors.darkSurface : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.grey200,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              final basePath = GoRouterState.of(context).matchedLocation;
              context.push('$basePath/${ticket.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${ticket.id.substring(ticket.id.length > 5 ? ticket.id.length - 5 : 0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.grey400 : AppColors.grey500,
                        ),
                      ),
                      Row(
                        children: [
                          _buildPriorityBadge(ticket.priority),
                          const SizedBox(width: 6),
                          _buildStatusBadge(ticket.status),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Client: ${ticket.clientName}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: isDark ? AppColors.dividerDark : AppColors.grey200,
                    height: 1,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created At',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          Text(
                            dateFormat.format(ticket.createdAt),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Assigned To',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          Text(
                            ticket.assignedTo,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color color;
    switch (priority) {
      case TicketPriority.critical:
        color = AppColors.criticalRed;
        break;
      case TicketPriority.urgent:
        color = AppColors.urgentAmber;
        break;
      case TicketPriority.standard:
        color = AppColors.standardBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        priority.displayName,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    switch (status) {
      case TicketStatus.open:
        color = AppColors.errorRed;
        break;
      case TicketStatus.inProgress:
        color = AppColors.urgentAmber;
        break;
      case TicketStatus.resolved:
        color = AppColors.successGreen;
        break;
      case TicketStatus.closed:
        color = AppColors.grey500;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  TextStyle _headerStyle(bool isDark) => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.goldLight : AppColors.grey600,
  );
}
