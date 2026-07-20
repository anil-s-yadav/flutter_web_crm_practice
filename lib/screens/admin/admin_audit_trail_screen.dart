import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class AdminAuditTrailScreen extends StatefulWidget {
  const AdminAuditTrailScreen({super.key});

  @override
  State<AdminAuditTrailScreen> createState() => _AdminAuditTrailScreenState();
}

class _AdminAuditTrailScreenState extends State<AdminAuditTrailScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filters
  ActionType? _selectedAction;
  UserRole? _selectedRole;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm');
    final DateFormat dateOnlyFormat = DateFormat('dd MMM yyyy');

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredLogs = state.auditLogs.where((l) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = l.userName.toLowerCase().contains(q) ||
            l.targetId.toLowerCase().contains(q) ||
            l.description.toLowerCase().contains(q) ||
            l.actionType.name.toLowerCase().contains(q);
        if (!matches) return false;
      }
      // Action type filter
      if (_selectedAction != null && l.actionType != _selectedAction) return false;
      // Role filter
      if (_selectedRole != null && l.userRole != _selectedRole) return false;
      // Date range filter
      if (_selectedDateRange != null) {
        if (l.timestamp.isBefore(_selectedDateRange!.start) ||
            l.timestamp.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();

    final hasActiveFilters = _selectedAction != null || _selectedRole != null || _selectedDateRange != null;

    return Scaffold(
      body: Column(
        children: [
          // --- Filter Bar ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search logs by user, action, target ID, or description...',
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.grey500 : AppColors.grey400),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 12),
                // Filter chips row
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Filters:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.grey400 : AppColors.grey600)),

                    // Action Type dropdown
                    _buildFilterDropdown<ActionType>(
                      label: 'Action Type',
                      value: _selectedAction,
                      items: ActionType.values,
                      itemLabel: (a) => _actionDisplayName(a),
                      onChanged: (v) => setState(() => _selectedAction = v),
                      isDark: isDark,
                    ),

                    // User Role dropdown
                    _buildFilterDropdown<UserRole>(
                      label: 'User Role',
                      value: _selectedRole,
                      items: UserRole.values,
                      itemLabel: (r) => r.name[0].toUpperCase() + r.name.substring(1),
                      onChanged: (v) => setState(() => _selectedRole = v),
                      isDark: isDark,
                    ),

                    // Date Range picker
                    InkWell(
                      onTap: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                          initialDateRange: _selectedDateRange,
                        );
                        if (range != null) setState(() => _selectedDateRange = range);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedDateRange != null
                              ? AppColors.gold.withValues(alpha: 0.1)
                              : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey50),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedDateRange != null
                                ? AppColors.gold
                                : (isDark ? AppColors.dividerDark : AppColors.grey300),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: _selectedDateRange != null ? AppColors.gold : (isDark ? AppColors.grey400 : AppColors.grey600)),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDateRange != null
                                  ? '${dateOnlyFormat.format(_selectedDateRange!.start)} - ${dateOnlyFormat.format(_selectedDateRange!.end)}'
                                  : 'Date Range',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: _selectedDateRange != null ? AppColors.gold : (isDark ? AppColors.grey400 : AppColors.grey600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Clear filters
                    if (hasActiveFilters)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _selectedAction = null;
                          _selectedRole = null;
                          _selectedDateRange = null;
                        }),
                        icon: const Icon(Icons.clear, size: 16),
                        label: Text('Clear All', style: GoogleFonts.poppins(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: AppColors.criticalRed),
                      ),

                    // Results count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filteredLogs.length} logs found',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.grey300 : AppColors.grey700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Table Header ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
            child: Row(
              children: [
                SizedBox(width: 160, child: Text('TIMESTAMP', style: _headerTextStyle(isDark))),
                SizedBox(width: 130, child: Text('ACTION', style: _headerTextStyle(isDark))),
                SizedBox(width: 140, child: Text('USER', style: _headerTextStyle(isDark))),
                const SizedBox(width: 16),
                Expanded(child: Text('DESCRIPTION', style: _headerTextStyle(isDark))),
                SizedBox(width: 100, child: Text('TARGET ID', style: _headerTextStyle(isDark))),
              ],
            ),
          ),

          // --- Logs List ---
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: isDark ? AppColors.grey700 : AppColors.grey300),
                        const SizedBox(height: 16),
                        Text('No audit logs match your filters.', style: GoogleFonts.poppins(fontSize: 16, color: isDark ? AppColors.grey400 : AppColors.grey600)),
                        const SizedBox(height: 8),
                        if (hasActiveFilters)
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedAction = null;
                              _selectedRole = null;
                              _selectedDateRange = null;
                              _searchController.clear();
                              _searchQuery = '';
                            }),
                            child: Text('Clear all filters', style: GoogleFonts.poppins(color: AppColors.gold)),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredLogs.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.grey200),
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogRow(log, formatter, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogRow(AuditLogModel log, DateFormat formatter, bool isDark) {
    final color = _actionColor(log.actionType);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              formatter.format(log.timestamp),
              style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.grey400 : AppColors.grey500),
            ),
          ),
          SizedBox(
            width: 130,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _actionDisplayName(log.actionType),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.userName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.white : AppColors.navyBlue)),
                Text(log.userRole.name[0].toUpperCase() + log.userRole.name.substring(1), style: GoogleFonts.poppins(color: AppColors.grey500, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              log.description,
              style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.white : AppColors.navyBlue),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              log.targetId,
              style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.grey400 : AppColors.grey500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    required bool isDark,
  }) {
    final isActive = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.gold : (isDark ? AppColors.dividerDark : AppColors.grey300),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          hint: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.grey400 : AppColors.grey600)),
          icon: Icon(Icons.arrow_drop_down, size: 18, color: isDark ? AppColors.grey400 : AppColors.grey600),
          isDense: true,
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.white : AppColors.navyBlue),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text('All', style: GoogleFonts.poppins(fontSize: 12)),
            ),
            ...items.map((item) => DropdownMenuItem<T?>(
              value: item,
              child: Text(itemLabel(item), style: GoogleFonts.poppins(fontSize: 12)),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  TextStyle _headerTextStyle(bool isDark) {
    return GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: isDark ? AppColors.grey400 : AppColors.grey600,
    );
  }

  String _actionDisplayName(ActionType type) {
    switch (type) {
      case ActionType.create: return 'Created';
      case ActionType.update: return 'Updated';
      case ActionType.delete: return 'Deleted';
      case ActionType.statusChange: return 'Status Change';
      case ActionType.paymentLogged: return 'Payment';
      case ActionType.contractRenewed: return 'Renewed';
      case ActionType.slaInitiated: return 'SLA Started';
      case ActionType.taskCompleted: return 'Task Done';
    }
  }

  Color _actionColor(ActionType type) {
    switch (type) {
      case ActionType.create: return AppColors.successGreen;
      case ActionType.update: return AppColors.statusInterviewed;
      case ActionType.delete: return AppColors.criticalRed;
      case ActionType.statusChange: return AppColors.navyBlue;
      case ActionType.paymentLogged: return AppColors.gold;
      case ActionType.contractRenewed: return AppColors.statusVerified;
      case ActionType.slaInitiated: return AppColors.urgentAmber;
      case ActionType.taskCompleted: return AppColors.stageMedicalCheck;
    }
  }
}
