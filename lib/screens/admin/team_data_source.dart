import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/crm_user_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:timeago/timeago.dart' as timeago;

class TeamDataSource extends DataGridSource {
  final BuildContext context;
  final bool isDark;
  final GlobalAppState state;
  final List<CrmUserModel> teamMembers;
  final Function(CrmUserModel) onViewDetails;
  
  List<DataGridRow> _dataGridRows = [];

  TeamDataSource({
    required this.context,
    required this.isDark,
    required this.state,
    required this.teamMembers,
    required this.onViewDetails,
  }) {
    _buildDataGridRows();
  }

  void _buildDataGridRows() {
    _dataGridRows = teamMembers.map<DataGridRow>((user) {
      return DataGridRow(cells: [
        DataGridCell<CrmUserModel>(columnName: 'user', value: user),
        DataGridCell<UserRole>(columnName: 'role', value: user.role),
        DataGridCell<CrmUserStatus>(columnName: 'status', value: user.status),
        DataGridCell<DateTime>(columnName: 'joined', value: user.joinedDate),
        DataGridCell<DateTime?>(columnName: 'lastLogin', value: user.lastLogin),
        DataGridCell<CrmUserModel>(columnName: 'performance', value: user),
        DataGridCell<CrmUserModel>(columnName: 'actions', value: user),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final user = row.getCells()[0].value as CrmUserModel;
    final dateFormat = DateFormat('dd MMM yyyy');

    Color roleColor = AppColors.navyBlue;
    switch (user.role) {
      case UserRole.admin:
        roleColor = AppColors.gold;
        break;
      case UserRole.sales:
        roleColor = AppColors.stageInterviewed;
        break;
      case UserRole.sourcing:
        roleColor = AppColors.stageMedicalCheck;
        break;
      case UserRole.executive:
        roleColor = AppColors.stageDocuments;
        break;
    }

    Color statusColor = AppColors.grey500;
    switch (user.status) {
      case CrmUserStatus.active:
        statusColor = AppColors.successGreen;
        break;
      case CrmUserStatus.inactive:
        statusColor = AppColors.grey500;
        break;
      case CrmUserStatus.suspended:
        statusColor = AppColors.criticalRed;
        break;
    }

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final columnName = dataGridCell.columnName;

        if (columnName == 'user') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: roleColor.withValues(alpha: 0.15),
                  child: Text(
                    user.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? AppColors.grey400 : AppColors.grey500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (columnName == 'role') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.role.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: roleColor,
                ),
              ),
            ),
          );
        } else if (columnName == 'status') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.status.displayName,
                  style: GoogleFonts.poppins(fontSize: 12, color: statusColor),
                ),
              ],
            ),
          );
        } else if (columnName == 'joined') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              dateFormat.format(user.joinedDate),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          );
        } else if (columnName == 'lastLogin') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              user.lastLogin != null ? timeago.format(user.lastLogin!) : 'Never',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          );
        } else if (columnName == 'performance') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.role == UserRole.sales) ...[
                  _buildMiniStat('Clients', user.clientsConverted, isDark),
                  const SizedBox(width: 12),
                  _buildMiniStat('Contracts', user.contractsClosed, isDark),
                ] else if (user.role == UserRole.sourcing) ...[
                  _buildMiniStat('Added', user.candidatesAdded, isDark),
                ] else ...[
                  Text(
                    '—',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? AppColors.grey500 : AppColors.grey400,
                    ),
                  ),
                ],
              ],
            ),
          );
        } else if (columnName == 'actions') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => onViewDetails(user),
                  icon: const Icon(Icons.visibility, size: 18),
                  tooltip: 'View Details',
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => context.push('/admin/team/${user.id}/edit'),
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Edit',
                  color: AppColors.gold,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => state.toggleCrmUserStatus(user.id),
                  icon: Icon(
                    user.status == CrmUserStatus.active
                        ? Icons.person_off
                        : Icons.person,
                    size: 18,
                  ),
                  tooltip: user.status == CrmUserStatus.active ? 'Deactivate' : 'Activate',
                  color: user.status == CrmUserStatus.active
                      ? AppColors.criticalRed
                      : AppColors.successGreen,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildMiniStat(String label, int value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.navyBlue,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? AppColors.grey400 : AppColors.grey500,
          ),
        ),
      ],
    );
  }
}
