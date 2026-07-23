import 'dart:ui';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  ClientStatus? _selectedStatus;
  ClientDataSource? _clientDataSource;
  bool _showFilters = false;
  List<ClientModel> _filteredClients = [];

  String? _selectedCity;
  String? _selectedCategory;
  String? _selectedDateRange;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDataSource() {
    final state = Provider.of<GlobalAppState>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isInitialized) return;

    final allMyClients = state.clients;

    _filteredClients =
        allMyClients.where((c) {
          if (_selectedStatus != null && c.status != _selectedStatus) {
            return false;
          }
          if (_selectedCity != null && c.city != _selectedCity) {
            return false;
          }
          if (_selectedCategory != null &&
              c.preferredCandidateCategory != _selectedCategory) {
            return false;
          }
          if (_selectedDateRange != null) {
            final now = DateTime.now();
            final diff = now.difference(c.inquiryDate).inDays;
            if (_selectedDateRange == 'Last 30 Days' && diff > 30) {
              return false;
            } else if (_selectedDateRange == 'Last 6 Months' && diff > 180) {
              return false;
            } else if (_selectedDateRange == 'This Year' &&
                c.inquiryDate.year != now.year) {
              return false;
            }
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
        clients: _filteredClients,
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
      _clientDataSource!.updateData(_filteredClients);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (!state.isInitialized || _clientDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = context.media.width < 900;

    // Create the tabs for ClientStatus
    final tabs = [
      'All Statuses',
      ...ClientStatus.values.map((s) => s.displayName),
    ];
    final statuses = [null, ...ClientStatus.values];

    return Scaffold(
      body: Column(
        children: [
          // 1. Horizontal ChoiceChip Tabs
          if (widget.initialStatus == null)
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(tabs.length, (index) {
                          final isSelected = _selectedStatus == statuses[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                tabs[index],
                                style: GoogleFonts.poppins(
                                  color:
                                      isSelected
                                          ? AppColors.navyBlue
                                          : (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight),
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.gold,
                              backgroundColor:
                                  isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.white,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedStatus = statuses[index];
                                });
                                _initializeDataSource();
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                    tooltip: 'Toggle Filters',
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                ],
              ),
            ),

          // 2. Toolbar
          _buildToolbar(isDark, _filteredClients.length, isMobile),

          // 3. Grid / Mobile List
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    isMobile
                        ? _buildMobileList(isDark, state)
                        : Align(
                          alignment: Alignment.topCenter,
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
                              source: _clientDataSource!,
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
                                      'Sr No',
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
                                      'Date',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'client',
                                  maximumWidth: 300,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Client',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'phone',
                                  width: 140,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Mobile',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'requirement',
                                  width: 150,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Budget',
                                      style: _headerStyle(isDark),
                                    ),
                                  ),
                                ),
                                if (widget.initialStatus == null)
                                  GridColumn(
                                    columnName: 'status',
                                    minimumWidth: 160,
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
                                  columnName: 'notes',
                                  width: 200,
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Notes',
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

          // 4. Pagination
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
                    color: AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_indianFormat.format(_filteredClients.length)} Clients found',
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
                // const SizedBox(width: 100), // Balance the flex space
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isDark, int count, bool isMobile) {
    return Container(
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
              ? _buildMobileToolbar(isDark, count)
              : _buildDesktopToolbar(isDark, count),
    );
  }

  List<Widget> _buildFilters(bool isDark) {
    final state = Provider.of<GlobalAppState>(context, listen: false);
    final cities = state.clients.map((c) => c.city).toSet().toList()..sort();
    final categories =
        state.clients.map((c) => c.preferredCandidateCategory).toSet().toList()
          ..sort();

    return [
      SizedBox(
        width: 140,
        height: 38,
        child: DropdownButtonFormField<String?>(
          isExpanded: true,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
          value: _selectedCity,
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
            const DropdownMenuItem(value: null, child: Text('City')),
            ...cities.map((c) => DropdownMenuItem(value: c, child: Text(c))),
          ],
          onChanged: (val) {
            setState(() => _selectedCity = val);
            _initializeDataSource();
          },
        ),
      ),

      SizedBox(
        width: 150,
        height: 38,
        child: DropdownButtonFormField<String?>(
          isExpanded: true,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
          value: _selectedCategory,
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
                color: isDark ? AppColors.dividerDark : AppColors.grey500,
              ),
            ),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Category')),
            ...categories.map(
              (c) => DropdownMenuItem(value: c, child: Text(c)),
            ),
          ],
          onChanged: (val) {
            setState(() => _selectedCategory = val);
            _initializeDataSource();
          },
        ),
      ),

      SizedBox(
        width: 140,
        height: 38,
        child: DropdownButtonFormField<String?>(
          isExpanded: true,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
          value: _selectedDateRange,
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
          items: const [
            DropdownMenuItem(value: null, child: Text('Date Range')),
            DropdownMenuItem(
              value: 'Last 30 Days',
              child: Text('Last 30 Days'),
            ),
            DropdownMenuItem(
              value: 'Last 6 Months',
              child: Text('Last 6 Months'),
            ),
            DropdownMenuItem(value: 'This Year', child: Text('This Year')),
          ],
          onChanged: (val) {
            setState(() => _selectedDateRange = val);
            _initializeDataSource();
          },
        ),
      ),
    ];
  }

  Widget _buildMobileToolbar(bool isDark, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  _initializeDataSource();
                },
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
              tooltip: 'Toggle Filters',
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ],
        ),
        if (_showFilters) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: _buildFilters(isDark)),
        ],
      ],
    );
  }

  Widget _buildDesktopToolbar(bool isDark, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${NumberFormat('#,##,###', 'en_IN').format(count)} Clients found',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
        ),
        const Spacer(),
        ..._buildFilters(isDark).map(
          (w) => Padding(padding: const EdgeInsets.only(right: 8), child: w),
        ),
        SizedBox(
          width: 250,
          height: 38,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() => _searchQuery = val);
              _initializeDataSource();
            },
            decoration: InputDecoration(
              hintText: 'Search clients...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey500 : AppColors.grey400,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(bool isDark, GlobalAppState state) {
    final clients = _filteredClients;
    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 48,
              color: isDark ? AppColors.grey700 : AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No clients found.',
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
      padding: const EdgeInsets.all(16),
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final client = clients[index];
        Color statusColor = AppColors.grey500;
        switch (client.status) {
          case ClientStatus.followUp:
            statusColor = AppColors.stageMedicalCheck;
            break;
          case ClientStatus.interested:
            statusColor = AppColors.stageInterviewed;
            break;
          case ClientStatus.notInterested:
            statusColor = AppColors.grey500;
            break;
          case ClientStatus.converted:
            statusColor = AppColors.successGreen;
            break;
          case ClientStatus.inactive:
            statusColor = AppColors.criticalRed;
            break;
        }

        final routePrefix =
            state.currentUser?.role == UserRole.admin ? '/admin' : '/sales';

        return _MobileClientCard(
          client: client,
          statusColor: statusColor,
          isDark: isDark,
          routePrefix: routePrefix,
          initialStatusName: widget.initialStatus?.name,
        );
      },
    );
  }

  TextStyle _headerStyle(bool isDark) => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.goldLight : AppColors.grey600,
  );
}

class _MobileClientCard extends StatefulWidget {
  final ClientModel client;
  final Color statusColor;
  final bool isDark;
  final String routePrefix;
  final String? initialStatusName;

  const _MobileClientCard({
    required this.client,
    required this.statusColor,
    required this.isDark,
    required this.routePrefix,
    this.initialStatusName,
  });

  @override
  State<_MobileClientCard> createState() => _MobileClientCardState();
}

class _MobileClientCardState extends State<_MobileClientCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final isDark = widget.isDark;
    final statusColor = widget.statusColor;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row (Always visible)
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    child: Text(
                      client.fullName
                          .split(' ')
                          .map((n) => n.isNotEmpty ? n[0] : '')
                          .take(2)
                          .join(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? AppColors.white
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          client.city,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      client.status.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              // Expanded Area
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            client.phone,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inquiry Date',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateFormat.format(client.inquiryDate),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requirement',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            client.preferredCandidateCategory,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppColors.grey400
                                      : AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            client.budgetRange,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassmorphismButton(
                        icon: Icons.call,
                        label: 'Call',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${client.phone}...'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGlassmorphismButton(
                        icon: Icons.visibility,
                        label: 'View',
                        isDark: isDark,
                        baseColor: AppColors.gold,
                        onTap: () {
                          var path =
                              '${widget.routePrefix}/clients/${client.id}';
                          if (widget.initialStatusName != null) {
                            path += '?from=${widget.initialStatusName}';
                          }
                          context.push(path);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphismButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    Color? baseColor,
  }) {
    final effectiveColor =
        baseColor ?? (isDark ? AppColors.white : AppColors.gold);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: isDark ? 0.1 : 0.08),
              border: Border.all(
                color: effectiveColor.withValues(alpha: isDark ? 0.2 : 0.15),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: effectiveColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
