import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:practice_app/screens/clients/client_data_source.dart';

class ClientListScreen extends StatefulWidget {
  final ClientStatus? initialStatus;

  const ClientListScreen({super.key, this.initialStatus});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final String _searchQuery = '';
  ClientStatus? _selectedStatus;
  ClientDataSource? _clientDataSource;

  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  @override
  void didUpdateWidget(covariant ClientListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      setState(() {
        _selectedStatus = widget.initialStatus;
      });
      _initializeDataSource();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeDataSource();
  }

  void _initializeDataSource() {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isInitialized) return;

    final allMyClients = state.clients;

    final filteredClients =
        allMyClients.where((c) {
          if (_selectedStatus != null && c.status != _selectedStatus) {
            return false;
          }
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            return c.fullName.toLowerCase().contains(query) ||
                c.phone.contains(query) ||
                c.city.toLowerCase().contains(query) ||
                c.id.toLowerCase().contains(query);
          }
          return true;
        }).toList();

    if (_clientDataSource == null) {
      _clientDataSource = ClientDataSource(
        context: context,
        isDark: isDark,
        clients: filteredClients,
        onRowTap: (client) {
          final routePrefix =
              state.currentUser?.role == UserRole.admin ? '/admin' : '/sales';
          var path = '$routePrefix/clients/${client.id}';
          if (widget.initialStatus != null) {
            path += '?from=${widget.initialStatus!.name}';
          }
          context.push(path);
        },
        showStatus: widget.initialStatus == null,
      );
    } else {
      _clientDataSource!.isDark = isDark;
      _clientDataSource!.updateData(filteredClients);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (!state.isInitialized || _clientDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceLight,
      body: Column(
        children: [
          if (widget.initialStatus == null)
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
                  const Text(
                    'Filter by Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 200,
                    height: 38,
                    child: DropdownButtonFormField<ClientStatus?>(
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
                        ...ClientStatus.values.map(
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
                        isDark ? AppColors.darkSurface : AppColors.grey50,
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
                    source: _clientDataSource!,
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
                          child: Text('Sr No', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'date',
                        width: 130,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Date', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'client',
                        maximumWidth: 300,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Client', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'phone',
                        width: 140,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Mobile', style: _headerStyle(isDark)),
                        ),
                      ),
                      GridColumn(
                        columnName: 'requirement',
                        width: 150,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Looking For',
                            style: _headerStyle(isDark),
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'budget',
                        minimumWidth: 160,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Budget', style: _headerStyle(isDark)),
                        ),
                      ),
                      if (widget.initialStatus == null)
                        GridColumn(
                          columnName: 'status',
                          minimumWidth: 160,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Text('Status', style: _headerStyle(isDark)),
                          ),
                        ),
                      GridColumn(
                        columnName: 'notes',
                        width: 200,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Notes', style: _headerStyle(isDark)),
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
                    color:
                        isDark
                            ? AppColors.white.withValues(alpha: 0.1)
                            : AppColors.navyBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_indianFormat.format(_clientDataSource!.rows.length)} Clients found',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
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
                const SizedBox(width: 100), // Balance the flex space
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
