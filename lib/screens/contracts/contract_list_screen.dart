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
  final String? initialViewMode;

  const ContractListScreen({super.key, this.initialViewMode});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String? _currentViewMode;
  ContractStatus? _selectedStatus;
  PaymentStatus? _selectedPaymentStatus;
  bool? _hasBalanceDue;
  String? _selectedDateRange;
  ContractDataSource? _contractDataSource;
  List<ContractModel> _filteredContracts = [];

  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  void initState() {
    super.initState();
    _currentViewMode = widget.initialViewMode;
  }

  @override
  void didUpdateWidget(covariant ContractListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialViewMode != widget.initialViewMode) {
      setState(() {
        _currentViewMode = widget.initialViewMode;
      });
      _initializeDataSource();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeDataSource();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDataSource() {
    final state = Provider.of<GlobalAppState>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isInitialized) return;

    final allContracts = state.contracts;

    final filteredContracts =
        allContracts.where((c) {
          if (_currentViewMode != null) {
            if (_currentViewMode == 'active' &&
                c.contractStatus != ContractStatus.active) {
              return false;
            }
            if (_currentViewMode == 'expired' && c.isGuaranteeActive) {
              return false;
            }
            if (_currentViewMode == 'renewals' &&
                (!c.isGuaranteeActive || c.daysRemainingInGuarantee > 30)) {
              return false;
            }
            if (_currentViewMode == 'replacements' &&
                !c.isReplacementUsed &&
                c.contractStatus != ContractStatus.rePlaced) {
              return false;
            }
          } else {
            if (_selectedStatus != null &&
                c.contractStatus != _selectedStatus) {
              return false;
            }
            if (_selectedPaymentStatus != null &&
                c.paymentStatus != _selectedPaymentStatus) {
              return false;
            }
            if (_hasBalanceDue != null) {
              final hasBalance = c.balanceAmount > 0;
              if (hasBalance != _hasBalanceDue) {
                return false;
              }
            }
            if (_selectedDateRange != null) {
              final now = DateTime.now();
              final diff = now.difference(c.placementDate).inDays;
              if (_selectedDateRange == 'Last 30 Days' && diff > 30) {
                return false;
              } else if (_selectedDateRange == 'Last 6 Months' && diff > 180) {
                return false;
              } else if (_selectedDateRange == 'This Year' &&
                  c.placementDate.year != now.year) {
                return false;
              }
            }
          }
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            return c.clientName.toLowerCase().contains(query) ||
                c.candidateName.toLowerCase().contains(query) ||
                c.id.toLowerCase().contains(query);
          }
          return true;
        }).toList();

    _filteredContracts = filteredContracts;

    if (_contractDataSource == null) {
      _contractDataSource = ContractDataSource(
        context: context,
        isDark: isDark,
        contracts: filteredContracts,
        viewMode: _currentViewMode,
        onRowTap: (contract) {
          final routePrefix =
              state.currentUser?.role == UserRole.admin ? '/admin' : '/sales';
          var path = '$routePrefix/clients/${contract.clientId}';
          if (_currentViewMode != null) {
            path += '?fromContractMode=$_currentViewMode';
          }
          context.push(path);
        },
      );
    } else {
      _contractDataSource!.isDark = isDark;
      _contractDataSource!.updateData(filteredContracts);
    }
  }

  // Widget _buildMobileToolbar(bool isDark, int count) {
  //   return ;
  // }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (!state.isInitialized || _contractDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (isMobile) _buildMobileToolbar(isDark, _filteredContracts.length),
          if (!isMobile || _showFilters)
            Container(
              width: double.maxFinite,
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
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_filteredContracts.length} Contracts found',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ),

                  if (_currentViewMode == null) ...[
                    SizedBox(
                      width: 130,
                      height: 38,
                      child: DropdownButtonFormField<ContractStatus?>(
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
                          fillColor:
                              isDark ? AppColors.darkSurface : AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey600,
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

                    SizedBox(
                      width: 110,
                      height: 38,
                      child: DropdownButtonFormField<PaymentStatus?>(
                        isExpanded: true,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                        initialValue: _selectedPaymentStatus,
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
                            child: Text('All'),
                          ),
                          ...PaymentStatus.values.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.displayName),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedPaymentStatus = val);
                          _initializeDataSource();
                        },
                      ),
                    ),

                    SizedBox(
                      width: 90,
                      height: 38,
                      child: DropdownButtonFormField<bool?>(
                        isExpanded: true,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                        initialValue: _hasBalanceDue,
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
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: true, child: Text('Yes')),
                          DropdownMenuItem(value: false, child: Text('No')),
                        ],
                        onChanged: (val) {
                          setState(() => _hasBalanceDue = val);
                          _initializeDataSource();
                        },
                      ),
                    ),

                    SizedBox(
                      width: 120,
                      height: 38,
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                        initialValue: _selectedDateRange,
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
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Time'),
                          ),
                          DropdownMenuItem(
                            value: 'Last 30 Days',
                            child: Text('Last 30 Days'),
                          ),
                          DropdownMenuItem(
                            value: 'Last 6 Months',
                            child: Text('Last 6 Months'),
                          ),
                          DropdownMenuItem(
                            value: 'This Year',
                            child: Text('This Year'),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedDateRange = val);
                          _initializeDataSource();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                          _initializeDataSource();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by client, candidate, ID...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color:
                                isDark ? AppColors.grey500 : AppColors.grey400,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor:
                              isDark ? AppColors.cardDark : AppColors.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // DataGrid
          Expanded(
            child:
                isMobile
                    ? _buildMobileListView(_filteredContracts, isDark, state)
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
                              source: _contractDataSource!,
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
                                  // width: 90,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Sr No',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'details',
                                  width: 240,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Contract Details',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                if (_currentViewMode != 'renewals')
                                  GridColumn(
                                    columnName: 'date',
                                    width: 120,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Placed On',
                                        style: _headerStyle(isDark),
                                      ),
                                    ),
                                  ),
                                GridColumn(
                                  columnName: 'expires_on',
                                  width: 120,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Expires On',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                if (_currentViewMode != 'renewals' &&
                                    _currentViewMode != 'replacements')
                                  GridColumn(
                                    columnName: 'duration',
                                    width: 100,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Duration',
                                        style: _headerStyle(isDark),
                                      ),
                                    ),
                                  ),
                                if (_currentViewMode != 'replacements')
                                  GridColumn(
                                    columnName: 'financials',
                                    width: 130,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Financials',
                                        style: _headerStyle(isDark),
                                      ),
                                    ),
                                  ),
                                if (_currentViewMode != 'replacements' &&
                                    _currentViewMode != 'renewals')
                                  GridColumn(
                                    columnName: 'paymentStatus',
                                    width: 130,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Payment',
                                        style: _headerStyle(isDark),
                                      ),
                                    ),
                                  ),
                                if (_currentViewMode != 'active')
                                  GridColumn(
                                    columnName: 'contractStatus',
                                    width: 130,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Status',
                                        style: _headerStyle(isDark),
                                      ),
                                    ),
                                  ),
                                if (_currentViewMode != 'active')
                                  GridColumn(
                                    columnName: 'actions',
                                    width: 90,
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            : AppColors.successGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '80 Found',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
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
                const SizedBox(width: 100),
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

  Widget _buildMobileListView(
    List<ContractModel> contracts,
    bool isDark,
    GlobalAppState state,
  ) {
    if (contracts.isEmpty) {
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
              'No contracts match your filters.',
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
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: contracts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final contract = contracts[index];

        Color getContractStatusColor(ContractStatus status) {
          switch (status) {
            case ContractStatus.pending:
              return AppColors.standardBlue;
            case ContractStatus.active:
              return AppColors.successGreen;
            case ContractStatus.completed:
              return AppColors.grey500;
            case ContractStatus.rePlaced:
              return AppColors.urgentAmber;
            case ContractStatus.cancelled:
              return AppColors.criticalRed;
          }
        }

        Color getPaymentStatusColor(PaymentStatus status) {
          switch (status) {
            case PaymentStatus.pending:
              return AppColors.standardBlue;
            case PaymentStatus.partial:
              return AppColors.urgentAmber;
            case PaymentStatus.paid:
              return AppColors.successGreen;
            case PaymentStatus.overdue:
              return AppColors.criticalRed;
          }
        }

        final contractColor = getContractStatusColor(contract.contractStatus);
        final paymentColor = getPaymentStatusColor(contract.paymentStatus);

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
              final routePrefix =
                  state.currentUser?.role == UserRole.admin
                      ? '/admin'
                      : '/sales';
              var path = '$routePrefix/clients/${contract.clientId}';
              if (_currentViewMode != null) {
                path += '?fromContractMode=$_currentViewMode';
              }
              context.push(path);
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
                        '#${contract.id.substring(contract.id.length > 5 ? contract.id.length - 5 : 0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.grey400 : AppColors.grey500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: contractColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              contract.contractStatus.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: contractColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: paymentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              contract.paymentStatus.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: paymentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Client: ${contract.clientName}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Candidate: ${contract.candidateName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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
                            'Placement Date',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          Text(
                            dateFormat.format(contract.placementDate),
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
                            'Service Fee',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          Text(
                            currencyFormat.format(contract.serviceFee),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.successGreen,
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
}
