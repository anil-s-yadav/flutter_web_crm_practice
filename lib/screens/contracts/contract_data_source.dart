import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/blocs/client/client_bloc.dart';
import 'package:practice_app/blocs/client/client_state.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ContractDataSource extends DataGridSource {
  final BuildContext context;
  bool isDark;
  final Function(ContractModel) onRowTap;
  List<DataGridRow> _dataGridRows = [];
  List<ContractModel> _contracts = [];

  String? viewMode;

  final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  ContractDataSource({
    required this.context,
    required this.isDark,
    required List<ContractModel> contracts,
    this.viewMode,
    required this.onRowTap,
  }) {
    _contracts = contracts;
    _buildDataGridRows();
  }

  String _getDurationText(ContractModel contract) {
    final days =
        contract.contractEndDate.difference(contract.placementDate).inDays;
    if (days <= 100) return '3 Months';
    if (days <= 200) return '6 Months';
    if (days <= 366) return '1 Year';
    return '${(days / 365).toStringAsFixed(1)} Years';
  }

  void _buildDataGridRows() {
    ClientState? clientState;
    CandidateState? candidateState;
    try {
      clientState = BlocProvider.of<ClientBloc>(context, listen: false).state;
      candidateState = BlocProvider.of<CandidateBloc>(context, listen: false).state;
    } catch (_) {}

    final clientsMap = clientState is ClientLoaded
        ? {for (var c in clientState.clients) c.id: c.fullName}
        : <String, String>{};
    final candidatesMap = candidateState is CandidateLoaded
        ? {for (var c in candidateState.candidates) c.id: c.fullName}
        : <String, String>{};

    _dataGridRows =
        _contracts.map<DataGridRow>((contract) {
          final resolvedClientName = clientsMap[contract.clientId] ??
              (contract.clientName != 'Unknown Client' ? contract.clientName : (contract.clientId.isNotEmpty ? contract.clientId : 'N/A'));
          final resolvedCandidateName = candidatesMap[contract.candidateId] ??
              (contract.candidateName != 'Unknown Candidate' ? contract.candidateName : (contract.candidateId.isNotEmpty ? contract.candidateId : 'N/A'));

          final cells = <DataGridCell>[
            DataGridCell<String>(columnName: 'id', value: contract.id),
            DataGridCell<String>(
              columnName: 'sr_no',
              value: contract.id, // e.g. CTX3001
            ),
            DataGridCell<String>(
              columnName: 'client_name',
              value: resolvedClientName,
            ),
            DataGridCell<String>(
              columnName: 'candidate_name',
              value: resolvedCandidateName,
            ),
          ];

          if (viewMode == 'renewals') {
            cells.add(
              DataGridCell<String>(
                columnName: 'renewed_on',
                value: contract.renewedOn != null
                    ? DateFormat('MMM dd, yyyy').format(contract.renewedOn!)
                    : '-',
              ),
            );
          }

          if (viewMode != 'renewals') {
            cells.add(
              DataGridCell<String>(
                columnName: 'date',
                value: DateFormat(
                  'MMM dd, yyyy',
                ).format(contract.placementDate),
              ),
            );
          }

          cells.add(
            DataGridCell<ContractModel>(
              columnName: 'warranty',
              value: contract,
            ),
          );

          cells.add(
            DataGridCell<ContractModel>(
              columnName: 'contract_expiry',
              value: contract,
            ),
          );

          if (viewMode != 'renewals' && viewMode != 'replacements') {
            cells.add(
              DataGridCell<String>(
                columnName: 'duration',
                value: _getDurationText(contract),
              ),
            );
          }

          if (viewMode != 'replacements') {
            cells.add(
              DataGridCell<String>(
                columnName: 'financials',
                value: _currencyFormat.format(contract.serviceFee),
              ),
            );
          }

          if (viewMode != 'replacements' && viewMode != 'renewals') {
            cells.add(
              DataGridCell<PaymentStatus>(
                columnName: 'paymentStatus',
                value: contract.paymentStatus,
              ),
            );
          }

          cells.add(
            DataGridCell<ContractStatus>(
              columnName: 'contractStatus',
              value: contract.contractStatus,
            ),
          );
          cells.add(
            DataGridCell<ContractModel>(
              columnName: 'actions',
              value: contract,
            ),
          );

          return DataGridRow(cells: cells);
        }).toList();
  }

  void updateData(List<ContractModel> newContracts) {
    _contracts = newContracts;
    _buildDataGridRows();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    if (sortColumn.name == 'details' || sortColumn.name == 'actions') {
      final value1 =
          a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value
              as ContractModel?;
      final value2 =
          b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value
              as ContractModel?;
      if (value1 == null || value2 == null) return 0;
      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return value1.clientName.compareTo(value2.clientName);
      } else {
        return value2.clientName.compareTo(value1.clientName);
      }
    } else if (sortColumn.name == 'contractStatus') {
      final value1 =
          a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value
              as ContractStatus?;
      final value2 =
          b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value
              as ContractStatus?;
      if (value1 == null || value2 == null) return 0;
      if (sortColumn.sortDirection == DataGridSortDirection.ascending) {
        return value1.name.compareTo(value2.name);
      } else {
        return value2.name.compareTo(value1.name);
      }
    } else if (sortColumn.name == 'paymentStatus') {
      final value1 =
          a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value
              as PaymentStatus?;
      final value2 =
          b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value
              as PaymentStatus?;
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
    final contract =
        row.getCells().firstWhere((c) => c.columnName == 'actions').value
            as ContractModel;
    final isEven = _dataGridRows.indexOf(row) % 2 == 0;

    return DataGridRowAdapter(
      color:
          isEven
              ? (isDark ? AppColors.darkSurface : AppColors.white)
              : (isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                  : AppColors.grey100),
      cells:
          row.getCells().map<Widget>((dataGridCell) {
            if (dataGridCell.columnName == 'id') {
              return const SizedBox.shrink(); // Hidden column
            }

            if (dataGridCell.columnName == 'client_name') {
              return InkWell(
                onTap: () => onRowTap(contract),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dataGridCell.value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? AppColors.white
                              : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }

            if (dataGridCell.columnName == 'candidate_name') {
              return InkWell(
                onTap: () => onRowTap(contract),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dataGridCell.value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? AppColors.grey300 : AppColors.grey700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }
            
            if (dataGridCell.columnName == 'warranty') {
              final wContract = dataGridCell.value as ContractModel;
              final bool isActive = wContract.isGuaranteeActive;
              
              Color badgeColor;
              String badgeText;
              
              if (wContract.replacementsUsed >= 3) {
                badgeColor = AppColors.urgentAmber;
                badgeText = '3/3 Replacements Used';
              } else if (isActive) {
                badgeColor = AppColors.successGreen;
                badgeText = '${wContract.replacementsUsed}/3 Replacements Used';
              } else {
                badgeColor = AppColors.grey500;
                badgeText = 'Expired (${wContract.replacementsUsed}/3)';
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(wContract.guaranteeEndDate),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            if (dataGridCell.columnName == 'contract_expiry') {
              final wContract = dataGridCell.value as ContractModel;
              final int daysLeft = wContract.daysRemainingInContract;
              final bool isExpired = daysLeft <= 0;
              
              Color badgeColor = isExpired ? AppColors.criticalRed : AppColors.standardBlue;
              String badgeText = isExpired ? 'Expired' : 'Active ($daysLeft days left)';
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Expires: ${DateFormat('dd MMM yy').format(wContract.contractEndDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (dataGridCell.columnName == 'financials') {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currencyFormat.format(contract.serviceFee),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark
                                ? AppColors.white
                                : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (contract.balanceAmount > 0)
                      Text(
                        'Bal: ${_currencyFormat.format(contract.balanceAmount)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.criticalRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              );
            }

            if (dataGridCell.columnName == 'paymentStatus') {
              final pStatus = dataGridCell.value as PaymentStatus;
              final color = _getPaymentStatusColor(pStatus);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pStatus.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              );
            }

            if (dataGridCell.columnName == 'contractStatus') {
              final cStatus = dataGridCell.value as ContractStatus;
              final color = _getContractStatusColor(cStatus);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cStatus.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              );
            }

            if (dataGridCell.columnName == 'actions') {
              return Container(
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                  tooltip: 'View Client Profile',
                  color: AppColors.standardBlue,
                  onPressed: () => onRowTap(contract),
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

  Color _getPaymentStatusColor(PaymentStatus status) {
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

  Color _getContractStatusColor(ContractStatus status) {
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
}
