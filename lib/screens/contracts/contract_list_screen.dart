import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/core/debouncer.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/core/paginated_state.dart';
import 'package:practice_app/models/contract_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({super.key});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  PaginatedState<ContractModel> _state = const PaginatedState<ContractModel>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() => _state = _state.copyWith(isLoading: true));
    final result = MockDataGenerator.getContracts(_state.toPaginationParams());
    setState(() {
      _state = _state.copyWith(
        items: result.items,
        totalCount: result.totalCount,
        isLoading: false
      );
    });
  }

  void _onSearch(String query) {
    _debouncer.run(() {
      setState(() {
        _state = _state.copyWith(searchQuery: query, currentPage: 1);
      });
      _loadData();
    });
  }

  void _goToPage(int page) {
    setState(() => _state = _state.copyWith(currentPage: page));
    _loadData();
  }

  void _changePageSize(int size) {
    setState(() => _state = _state.copyWith(pageSize: size, currentPage: 1));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
            border: Border(bottom: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200))
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: Text('${_indianFormat.format(_state.totalCount)} Contracts',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.successGreen))
              ),
              SizedBox(
                width: 260,
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search contracts...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300))
                  )
                )
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Show: ', style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.grey400 : AppColors.grey600)),
                  DropdownButton<int>(
                    value: _state.pageSize,
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.white : AppColors.navyBlue),
                    items: [25, 50, 100].map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
                    onChanged: (v) { if (v != null) _changePageSize(v); }
                  ),
                ]
              ),
            ]
          )
        ),
        // Content
        Expanded(
          child: _state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(isDark ? AppColors.darkSurfaceVariant : AppColors.grey50),
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 60,
                      columnSpacing: 20,
                      columns: [
                        DataColumn(label: Text('Date', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600))),
                        DataColumn(label: Text('Contract ID', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600))),
                        DataColumn(label: Text('Client', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600))),
                        DataColumn(label: Text('Candidate', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600))),
                        DataColumn(label: Text('Fee', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600))),
                        DataColumn(label: Text('Status', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600))),
                        DataColumn(label: Text('Payment', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600))),
                      ],
                      rows: _state.items.map((contract) => DataRow(
                        cells: [
                          DataCell(Text(DateFormat('MMM dd, yyyy').format(contract.placementDate), style: GoogleFonts.poppins(fontSize: 13))),
                          DataCell(Text(contract.id, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500))),
                          DataCell(Text(contract.clientName, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.navyBlue))),
                          DataCell(Text(contract.candidateName, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.navyBlue))),
                          DataCell(Text('₹${_indianFormat.format(contract.serviceFee)}', style: GoogleFonts.poppins(fontSize: 13))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: contract.contractStatus == ContractStatus.active ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.grey500.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(contract.contractStatus.name, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: contract.contractStatus == ContractStatus.active ? AppColors.successGreen : AppColors.grey500))
                            )
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: contract.paymentStatus == PaymentStatus.paid ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.warningOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(contract.paymentStatus.name, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: contract.paymentStatus == PaymentStatus.paid ? AppColors.successGreen : AppColors.warningOrange))
                            )
                          ),
                        ]
                      )).toList()
                    )
                  )
                )
        ),
        // Pagination
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50, border: Border(top: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: _state.hasPrevious ? () => _goToPage(_state.currentPage - 1) : null),
              Text('Page ${_indianFormat.format(_state.currentPage)} of ${_indianFormat.format(_state.totalPages)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: _state.hasNext ? () => _goToPage(_state.currentPage + 1) : null),
            ]
          )
        ),
      ]
    );
  }
}
