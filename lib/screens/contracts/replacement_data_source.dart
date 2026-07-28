import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:practice_app/models/replacement_request_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReplacementDataSource extends DataGridSource {
  final BuildContext context;
  bool isDark;
  final Function(ReplacementRequestModel) onRowTap;
  List<DataGridRow> _dataGridRows = [];
  List<ReplacementRequestModel> _requests = [];

  ReplacementDataSource({
    required this.context,
    required this.isDark,
    required List<ReplacementRequestModel> requests,
    required this.onRowTap,
  }) {
    _requests = requests;
    _buildDataGridRows();
  }

  void _buildDataGridRows() {
    _dataGridRows = _requests.map<DataGridRow>((request) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: request.id),
        DataGridCell<String>(columnName: 'sr_no', value: request.id),
        DataGridCell<ReplacementRequestModel>(columnName: 'client', value: request),
        DataGridCell<String>(columnName: 'old_candidate', value: request.oldCandidateName),
        DataGridCell<String>(columnName: 'reason', value: request.reason),
        DataGridCell<String>(
          columnName: 'request_date',
          value: DateFormat('MMM dd, yyyy').format(request.requestDate),
        ),
        DataGridCell<ReplacementStatus>(columnName: 'status', value: request.status),
      ]);
    }).toList();
  }

  void updateData(List<ReplacementRequestModel> requests) {
    _requests = requests;
    _buildDataGridRows();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final request = row.getCells().firstWhere((c) => c.columnName == 'client').value as ReplacementRequestModel;
    final isEven = _dataGridRows.indexOf(row) % 2 == 0;

    return DataGridRowAdapter(
      color:
          isEven
              ? (isDark ? AppColors.darkSurface : AppColors.white)
              : (isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                  : AppColors.grey100),
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'id') {
          return const SizedBox.shrink();
        }

        if (dataGridCell.columnName == 'client') {
          return InkWell(
            onTap: () => onRowTap(request),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                request.clientName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
        
        if (dataGridCell.columnName == 'status') {
          final status = dataGridCell.value as ReplacementStatus;
          Color color;
          switch (status) {
            case ReplacementStatus.pending:
              color = AppColors.urgentAmber;
              break;
            case ReplacementStatus.inProgress:
              color = AppColors.infoBlue;
              break;
            case ReplacementStatus.resolved:
              color = AppColors.successGreen;
              break;
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            dataGridCell.value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppColors.grey300 : AppColors.grey700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}
