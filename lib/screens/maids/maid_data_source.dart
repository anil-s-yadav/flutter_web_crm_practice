import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:practice_app/models/maid_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MaidDataSource extends DataGridSource {
  final BuildContext context;
  final bool isDark;
  final Function(MaidModel) onRowTap;
  final Function(MaidModel, String) onActionTap;
  List<DataGridRow> _dataGridRows = [];
  List<MaidModel> _maids = [];

  MaidDataSource({
    required this.context,
    required this.isDark,
    required List<MaidModel> maids,
    required this.onRowTap,
    required this.onActionTap,
  }) {
    _maids = maids;
    _buildDataGridRows();
  }

  String _getMostRelevantDate(MaidModel maid) {
    if (maid.status == MaidStatus.placed && maid.datePlaced != null) {
      return DateFormat('MMM dd, yyyy').format(maid.datePlaced!);
    } else if (maid.status == MaidStatus.readyToPlace && maid.dateReadyToHire != null) {
      return DateFormat('MMM dd, yyyy').format(maid.dateReadyToHire!);
    } else if (maid.status == MaidStatus.medicalPending && maid.dateMedicalSent != null) {
      return DateFormat('MMM dd, yyyy').format(maid.dateMedicalSent!);
    } else if (maid.status == MaidStatus.verificationPending && maid.dateVerificationSent != null) {
      return DateFormat('MMM dd, yyyy').format(maid.dateVerificationSent!);
    }
    return DateFormat('MMM dd, yyyy').format(maid.dateAdded);
  }

  void _buildDataGridRows() {
    _dataGridRows =
        _maids.map<DataGridRow>((MaidModel maid) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'id', value: maid.id),
              DataGridCell<String>(
                columnName: 'date',
                value: _getMostRelevantDate(maid),
              ),
              DataGridCell<MaidModel>(columnName: 'maid', value: maid),
              DataGridCell<String>(
                columnName: 'category',
                value: maid.category,
              ),
              DataGridCell<int>(
                columnName: 'experience',
                value: maid.experienceYears,
              ),
              DataGridCell<String>(
                columnName: 'salary',
                value: maid.expectedSalary,
              ),
              DataGridCell<String>(
                columnName: 'education',
                value: maid.education,
              ),
              DataGridCell<String>(
                columnName: 'languages',
                value: maid.languages
                    .map((l) => l.substring(0, 2).toLowerCase())
                    .join(', '),
              ),
              DataGridCell<MaidStatus>(
                columnName: 'status',
                value: maid.status,
              ),
              DataGridCell<MaidModel>(columnName: 'actions', value: maid),
            ],
          );
        }).toList();
  }

  void updateData(List<MaidModel> newMaids) {
    _maids = newMaids;
    _buildDataGridRows();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final MaidModel maid = row.getCells().firstWhere((c) => c.columnName == 'maid').value as MaidModel;
    final isEven = _dataGridRows.indexOf(row) % 2 == 0;

    return DataGridRowAdapter(
      color:
          isEven
              ? (isDark ? AppColors.darkSurface : AppColors.white)
              : (isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                  : AppColors.grey50),
      cells:
          row.getCells().map<Widget>((DataGridCell cell) {
            if (cell.columnName == 'maid') {
              return InkWell(
                onTap: () => onRowTap(maid),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.navyBlue.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          maid.fullName[0],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              maid.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${maid.age} yrs • ${maid.city}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color:
                                    isDark
                                        ? AppColors.grey500
                                        : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (cell.columnName == 'status') {
              final status = cell.value as MaidStatus;
              return Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _maidStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _maidStatusColor(status),
                    ),
                  ),
                ),
              );
            } else if (cell.columnName == 'actions') {
              return Container(
                alignment: Alignment.center,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                  tooltip: 'Actions',
                  onSelected: (action) => onActionTap(maid, action),
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[];
                    if (maid.status == MaidStatus.newlyAdded) {
                      items.add(
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Profile'),
                        ),
                      );
                      items.add(
                        const PopupMenuItem(
                          value: 'promote_verification',
                          child: Text('Move to Verification'),
                        ),
                      );
                    } else if (maid.status == MaidStatus.verificationPending) {
                      items.add(
                        const PopupMenuItem(
                          value: 'promote_medical',
                          child: Text('Promote to Medical'),
                        ),
                      );
                      items.add(
                        const PopupMenuItem(
                          value: 'promote_ready',
                          child: Text('Promote to Ready (Skip Medical)'),
                        ),
                      );
                    } else if (maid.status == MaidStatus.medicalPending) {
                      items.add(
                        const PopupMenuItem(
                          value: 'promote_ready',
                          child: Text('Promote to Ready'),
                        ),
                      );
                    }

                    if (maid.status != MaidStatus.blacklisted &&
                        maid.status != MaidStatus.placed) {
                      items.add(
                        const PopupMenuItem(
                          value: 'blacklist',
                          child: Text(
                            'Blacklist',
                            style: TextStyle(color: AppColors.criticalRed),
                          ),
                        ),
                      );
                    }
                    return items;
                  },
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Text(
                cell.value.toString(),
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

  Color _maidStatusColor(MaidStatus status) {
    switch (status) {
      case MaidStatus.newlyAdded:
        return AppColors.statusInterviewed; // using existing color
      case MaidStatus.verificationPending:
        return AppColors.stagePoliceVerification;
      case MaidStatus.medicalPending:
        return AppColors.stageMedicalCheck;
      case MaidStatus.readyToPlace:
        return AppColors.statusVerified;
      case MaidStatus.placed:
        return AppColors.statusPlaced;
      case MaidStatus.blacklisted:
        return AppColors.statusBlacklisted;
    }
  }
}
