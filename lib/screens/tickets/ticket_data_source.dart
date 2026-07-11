import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TicketDataSource extends DataGridSource {
  final BuildContext context;
  bool isDark;
  final Function(TicketModel) onRowTap;
  List<DataGridRow> _dataGridRows = [];
  List<TicketModel> _tickets = [];

  TicketDataSource({
    required this.context,
    required this.isDark,
    required List<TicketModel> tickets,
    required this.onRowTap,
  }) {
    _tickets = tickets;
    _buildDataGridRows();
  }

  void _buildDataGridRows() {
    _dataGridRows = _tickets.map<DataGridRow>((ticket) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'id', value: ticket.id),
          DataGridCell<String>(columnName: 'sr_no', value: ticket.id),
          DataGridCell<String>(
            columnName: 'date',
            value: DateFormat('MMM dd, yyyy').format(ticket.createdAt),
          ),
          DataGridCell<TicketModel>(columnName: 'details', value: ticket),
          DataGridCell<TicketPriority>(
            columnName: 'priority',
            value: ticket.priority,
          ),
          DataGridCell<TicketStatus>(
            columnName: 'status',
            value: ticket.status,
          ),
          DataGridCell<String>(
            columnName: 'assigned',
            value: ticket.assignedTo,
          ),
          DataGridCell<TicketModel>(columnName: 'actions', value: ticket),
        ],
      );
    }).toList();
  }

  void updateData(List<TicketModel> newTickets) {
    _tickets = newTickets;
    _buildDataGridRows();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    if (sortColumn.name == 'details' || sortColumn.name == 'actions') {
      final value1 = a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as TicketModel?;
      final value2 = b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as TicketModel?;
      if (value1 == null || value2 == null) return 0;
      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return value1.title.compareTo(value2.title);
      } else {
        return value2.title.compareTo(value1.title);
      }
    } else if (sortColumn.name == 'status') {
      final value1 = a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as TicketStatus?;
      final value2 = b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as TicketStatus?;
      if (value1 == null || value2 == null) return 0;
      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return value1.name.compareTo(value2.name);
      } else {
        return value2.name.compareTo(value1.name);
      }
    } else if (sortColumn.name == 'priority') {
      final value1 = a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as TicketPriority?;
      final value2 = b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value as TicketPriority?;
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
    final ticket = row.getCells().firstWhere((c) => c.columnName == 'details').value as TicketModel;

    return DataGridRowAdapter(
      color: isDark ? AppColors.darkSurface : AppColors.white,
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'id') {
          return const SizedBox.shrink(); // Hidden column
        }

        if (dataGridCell.columnName == 'details') {
          return InkWell(
            onTap: () => onRowTap(ticket),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ticket.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Client: ${ticket.clientName}',
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
          );
        }

        if (dataGridCell.columnName == 'priority') {
          final priority = dataGridCell.value as TicketPriority;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: _buildPriorityBadge(priority),
          );
        }

        if (dataGridCell.columnName == 'status') {
          final status = dataGridCell.value as TicketStatus;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: _buildStatusBadge(status),
          );
        }

        if (dataGridCell.columnName == 'actions') {
          return Container(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                color: isDark ? AppColors.gold : AppColors.navyBlue,
                size: 20,
              ),
              onPressed: () => onRowTap(ticket),
              tooltip: 'View Details',
            ),
          );
        }

        // Default cell (sr_no, date, assigned)
        return InkWell(
          onTap: () => onRowTap(ticket),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              dataGridCell.value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.grey300 : AppColors.grey700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color color;
    switch (priority) {
      case TicketPriority.critical: color = AppColors.criticalRed; break;
      case TicketPriority.urgent: color = AppColors.urgentAmber; break;
      case TicketPriority.standard: color = AppColors.standardBlue; break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        priority.displayName,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    switch (status) {
      case TicketStatus.open: color = AppColors.errorRed; break;
      case TicketStatus.inProgress: color = AppColors.urgentAmber; break;
      case TicketStatus.resolved: color = AppColors.successGreen; break;
      case TicketStatus.closed: color = AppColors.grey500; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
