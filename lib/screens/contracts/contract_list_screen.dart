import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:practice_app/screens/contracts/contract_data_source.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({super.key});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  String _searchQuery = '';
  ContractStatus? _selectedStatus;
  ContractDataSource? _contractDataSource;

  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeDataSource();
  }

  void _initializeDataSource() {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isInitialized) return;

    final allContracts = state.contracts;

    final filteredContracts =
        allContracts.where((c) {
          if (_selectedStatus != null && c.contractStatus != _selectedStatus) {
            return false;
          }
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            return c.clientName.toLowerCase().contains(query) ||
                c.candidateName.toLowerCase().contains(query) ||
                c.id.toLowerCase().contains(query);
          }
          return true;
        }).toList();

    if (_contractDataSource == null) {
      _contractDataSource = ContractDataSource(
        context: context,
        isDark: isDark,
        contracts: filteredContracts,
        onRowTap: (contract) {
          final routePrefix =
              state.currentUser?.role == UserRole.admin ? '/admin' : '/sales';
          context.push('$routePrefix/clients/${contract.clientId}');
        },
      );
    } else {
      _contractDataSource!.isDark = isDark;
      _contractDataSource!.updateData(filteredContracts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (!state.isInitialized || _contractDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceLight,
      body: Column(
        children: [
          // Toolbar (Search & Filters)
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_indianFormat.format(_contractDataSource!.rows.length)} Contracts',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  height: 38,
                  child: TextField(
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _initializeDataSource();
                    },
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by ID, client or candidate...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.grey500,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkSurface : AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey300,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 200,
                  height: 38,
                  child: DropdownButtonFormField<ContractStatus?>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkSurface : AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.dividerDark
                                  : AppColors.grey300,
                        ),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...ContractStatus.values.map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ),
                      ),
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
                    headerColor:
                        isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.grey50,
                    gridLineColor:
                        isDark ? AppColors.dividerDark : AppColors.grey200,
                    gridLineStrokeWidth: 1,
                    rowHoverColor:
                        isDark
                            ? AppColors.navyBlue.withValues(alpha: 0.1)
                            : AppColors.navyBlue.withValues(alpha: 0.04),
                    sortIconColor: AppColors.gold,
                  ),
                  child: SfDataGrid(
                    source: _contractDataSource!,
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
                          child: Text('Sr No', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'date',
                        width: 130,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Placed On', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'duration',
                        width: 110,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Duration', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'expires_on',
                        width: 130,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Expires On', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'details',
                        maximumWidth: 300,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Contract Details', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'financials',
                        width: 160,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Financials', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'paymentStatus',
                        width: 130,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Payment', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'contractStatus',
                        width: 130,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Status', style: _headerStyle),
                        ),
                      ),
                      GridColumn(
                        columnName: 'actions',
                        width: 90,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Text('Action', style: _headerStyle),
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
              mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        ],
      ),
    );
  }

  TextStyle get _headerStyle => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.grey600,
  );
}
