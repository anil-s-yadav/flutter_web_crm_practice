import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CandidateDataSource extends DataGridSource {
  final BuildContext context;
  final bool isDark;
  final Function(CandidateModel) onRowTap;
  final Function(CandidateModel, String) onActionTap;
  List<DataGridRow> _dataGridRows = [];
  List<CandidateModel> _candidates = [];

  CandidateDataSource({
    required this.context,
    required this.isDark,
    required List<CandidateModel> candidates,
    required this.onRowTap,
    required this.onActionTap,
  }) {
    _candidates = candidates;
    _buildDataGridRows();
  }

  String _getMostRelevantDate(CandidateModel candidate) {
    if (candidate.status == CandidateStatus.placed && candidate.datePlaced != null) {
      return DateFormat('MMM dd, yyyy').format(candidate.datePlaced!);
    } else if (candidate.status == CandidateStatus.readyToPlace &&
        candidate.dateReadyToHire != null) {
      return DateFormat('MMM dd, yyyy').format(candidate.dateReadyToHire!);
    } else if (candidate.status == CandidateStatus.medicalPending &&
        candidate.dateMedicalSent != null) {
      return DateFormat('MMM dd, yyyy').format(candidate.dateMedicalSent!);
    } else if (candidate.status == CandidateStatus.verificationPending &&
        candidate.dateVerificationSent != null) {
      return DateFormat('MMM dd, yyyy').format(candidate.dateVerificationSent!);
    }
    return DateFormat('MMM dd, yyyy').format(candidate.dateAdded);
  }

  void _buildDataGridRows() {
    _dataGridRows =
        _candidates.asMap().entries.map<DataGridRow>((entry) {
          final int index = entry.key;
          final CandidateModel candidate = entry.value;
          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'id', value: candidate.id),
              DataGridCell<String>(
                columnName: 'sr_no',
                value: 'VMS${candidate.id.padLeft(3, '0')}',
              ),
              DataGridCell<String>(
                columnName: 'date',
                value: _getMostRelevantDate(candidate),
              ),
              DataGridCell<CandidateModel>(columnName: 'candidate', value: candidate),
              DataGridCell<String>(
                columnName: 'category',
                value: candidate.category,
              ),
              DataGridCell<int>(
                columnName: 'experience',
                value: candidate.experienceYears,
              ),
              DataGridCell<String>(
                columnName: 'salary',
                value: candidate.expectedSalary,
              ),
              DataGridCell<String>(
                columnName: 'education',
                value: candidate.education,
              ),
              DataGridCell<String>(
                columnName: 'languages',
                value: candidate.languages
                    .map((l) => l.substring(0, 2).toLowerCase())
                    .join(', '),
              ),
              DataGridCell<CandidateStatus>(
                columnName: 'status',
                value: candidate.status,
              ),
              DataGridCell<CandidateModel>(columnName: 'actions', value: candidate),
            ],
          );
        }).toList();
  }

  void updateData(List<CandidateModel> newCandidates) {
    _candidates = newCandidates;
    _buildDataGridRows();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final CandidateModel candidate =
        row.getCells().firstWhere((c) => c.columnName == 'candidate').value
            as CandidateModel;
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
            if (cell.columnName == 'candidate') {
              return InkWell(
                onTap: () => onRowTap(candidate),
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
                          candidate.fullName[0],
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
                              candidate.fullName,
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
                              '${candidate.age} yrs • ${candidate.city}',
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
              final status = cell.value as CandidateStatus;
              return Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _candidateStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _candidateStatusColor(status),
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
                  onSelected: (action) => onActionTap(candidate, action),
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[];
                    if (candidate.status == CandidateStatus.newlyAdded) {
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
                    } else if (candidate.status == CandidateStatus.verificationPending) {
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
                    } else if (candidate.status == CandidateStatus.medicalPending) {
                      items.add(
                        const PopupMenuItem(
                          value: 'promote_ready',
                          child: Text('Promote to Ready'),
                        ),
                      );
                    }

                    if (candidate.status != CandidateStatus.blacklisted &&
                        candidate.status != CandidateStatus.placed) {
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

  Color _candidateStatusColor(CandidateStatus status) {
    switch (status) {
      case CandidateStatus.newlyAdded:
        return AppColors.statusInterviewed; // using existing color
      case CandidateStatus.verificationPending:
        return AppColors.stagePoliceVerification;
      case CandidateStatus.medicalPending:
        return AppColors.stageMedicalCheck;
      case CandidateStatus.readyToPlace:
        return AppColors.statusVerified;
      case CandidateStatus.placed:
        return AppColors.statusPlaced;
      case CandidateStatus.blacklisted:
        return AppColors.statusBlacklisted;
      case CandidateStatus.renewalPending:
        // TODO: Handle this case.
        throw UnimplementedError();
      case CandidateStatus.jobLeft:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
