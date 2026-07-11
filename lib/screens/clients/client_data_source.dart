import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ClientDataSource extends DataGridSource {
  final BuildContext context;
  bool isDark;
  final Function(ClientModel) onRowTap;
  List<DataGridRow> _dataGridRows = [];
  List<ClientModel> _clients = [];

  final bool showStatus;

  ClientDataSource({
    required this.context,
    required this.isDark,
    required List<ClientModel> clients,
    required this.onRowTap,
    this.showStatus = true,
  }) {
    _clients = clients;
    _buildDataGridRows();
  }

  void _buildDataGridRows() {
    _dataGridRows = _clients.map<DataGridRow>((client) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'id', value: client.id),
          DataGridCell<String>(
            columnName: 'sr_no',
            value: client.id, // e.g. CLI2001
          ),
          DataGridCell<String>(
            columnName: 'date',
            value: DateFormat('MMM dd, yyyy').format(client.inquiryDate),
          ),
          DataGridCell<ClientModel>(columnName: 'client', value: client),
          DataGridCell<String>(
            columnName: 'phone',
            value: client.phone,
          ),
          DataGridCell<String>(
            columnName: 'requirement',
            value: client.preferredCandidateCategory,
          ),
          DataGridCell<String>(
            columnName: 'budget',
            value: client.budgetRange,
          ),
          if (showStatus)
            DataGridCell<ClientStatus>(
              columnName: 'status',
              value: client.status,
            ),
          DataGridCell<ClientModel>(columnName: 'actions', value: client),
        ],
      );
    }).toList();
  }

  void updateData(List<ClientModel> newClients) {
    _clients = newClients;
    _buildDataGridRows();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    if (sortColumn.name == 'client' || sortColumn.name == 'actions') {
      final value1 = a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as ClientModel?;
      final value2 = b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as ClientModel?;
      if (value1 == null || value2 == null) return 0;
      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return value1.fullName.compareTo(value2.fullName);
      } else {
        return value2.fullName.compareTo(value1.fullName);
      }
    } else if (sortColumn.name == 'status') {
      final value1 = a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as ClientStatus?;
      final value2 = b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as ClientStatus?;
      if (value1 == null || value2 == null) return 0;
      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return value1.name.compareTo(value2.name);
      } else {
        return value2.name.compareTo(value1.name);
      }
    }
    return super.compare(a, b, sortColumn);
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final client = row.getCells().firstWhere((c) => c.columnName == 'client').value as ClientModel;

    return DataGridRowAdapter(
      color: isDark ? AppColors.darkSurface : AppColors.white,
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'id') {
          return const SizedBox.shrink(); // Hidden column
        }

        if (dataGridCell.columnName == 'client') {
          return InkWell(
            onTap: () => onRowTap(client),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark 
                        ? AppColors.white.withValues(alpha: 0.1) 
                        : AppColors.navyBlue.withValues(alpha: 0.1),
                    child: Text(
                      client.fullName[0],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
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
                          client.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${client.locality}, ${client.city}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (dataGridCell.columnName == 'phone') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              dataGridCell.value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.white : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        if (dataGridCell.columnName == 'status') {
          final status = dataGridCell.value as ClientStatus;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(status),
                ),
              ),
            ),
          );
        }

        if (dataGridCell.columnName == 'actions') {
          return Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                  tooltip: 'View Profile',
                  color: AppColors.standardBlue,
                  onPressed: () => onRowTap(client),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  tooltip: 'Call',
                  color: AppColors.successGreen,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${client.phone}...')),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            dataGridCell.value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.white : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.newInquiry: return AppColors.standardBlue;
      case ClientStatus.followUp: return AppColors.urgentAmber;
      case ClientStatus.noResponse: return AppColors.criticalRed;
      case ClientStatus.converted: return AppColors.successGreen;
      case ClientStatus.active: return AppColors.successGreen;
      case ClientStatus.notInterested: return AppColors.grey500;
      case ClientStatus.churned: return AppColors.statusBlacklisted;
    }
  }
}
