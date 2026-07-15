import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  TicketDataSource? _ticketDataSource;
  String _searchQuery = '';
  TicketStatus? _selectedStatus;
  TicketPriority? _selectedPriority;

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
        onRowTap: (ticket) {},
      );
    } else {
      _ticketDataSource!.isDark = isDark;
      _ticketDataSource!.updateData(filteredTickets);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (_ticketDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceLight,
      body: Column(
        children: [
          // Header
          // Container(
          //   padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         'Support Tickets',
          //         style: GoogleFonts.poppins(
          //           fontSize: 24,
          //           fontWeight: FontWeight.bold,
          //           color: isDark ? AppColors.white : AppColors.navyBlue,
          //         ),
          //       ),

          //     ],
          //   ),
          // ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
              border: Border(
                bottom: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  height: 38,
                  child: DropdownButtonFormField<TicketPriority?>(
                    initialValue: _selectedPriority,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Priorities')),
                      ...TicketPriority.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedPriority = val);
                      _initializeDataSource();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  height: 38,
                  child: DropdownButtonFormField<TicketStatus?>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Statuses')),
                      ...TicketStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedStatus = val);
                      _initializeDataSource();
                    },
                  ),
                ),
              ],
            ),
          ),

          // DataGrid
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SfDataGridTheme(
                  data: SfDataGridThemeData(
                    headerColor: isDark ? AppColors.darkSurface : AppColors.grey50,
                    gridLineColor: isDark ? AppColors.dividerDark : AppColors.grey200,
                    gridLineStrokeWidth: 1,
                    rowHoverColor:
                        isDark
                            ? AppColors.navyBlue.withValues(alpha: 0.1)
                            : AppColors.navyBlue.withValues(alpha: 0.04),
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
                    headerGridLinesVisibility: GridLinesVisibility.both,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Ticket ID', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'date',
                        width: 130,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Created At', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'details',
                        maximumWidth: 300,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Details', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'priority',
                        width: 120,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Priority', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'status',
                        width: 120,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Status', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'assigned',
                        width: 140,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Assigned To', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'actions',
                        width: 90,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Text('Action', style: _headerStyle(isDark)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Pagination
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.criticalRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_indianFormat.format(_ticketDataSource!.rows.length)} Tickets',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
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
                    ),
                    Text(
                      'Page 1 of 1',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const IconButton(
                      icon: Icon(Icons.chevron_right, size: 20),
                      onPressed: null, // Stubbed for mock data
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

  TextStyle _headerStyle(bool isDark) => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.goldLight : AppColors.grey600,
  );
}
