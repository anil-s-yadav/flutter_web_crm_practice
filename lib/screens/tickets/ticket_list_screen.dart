import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/core/debouncer.dart';
import 'package:practice_app/core/mock_data_generator.dart';
import 'package:practice_app/core/paginated_state.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');

  PaginatedState<TicketModel> _state = const PaginatedState<TicketModel>();

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
    final result = MockDataGenerator.getTickets(_state.toPaginationParams());
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

  Color _priorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.critical: return AppColors.criticalRed;
      case TicketPriority.urgent: return AppColors.urgentAmber;
      case TicketPriority.standard: return AppColors.standardBlue;
    }
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
                decoration: BoxDecoration(color: AppColors.criticalRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: Text('${_indianFormat.format(_state.totalCount)} Tickets',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.criticalRed))
              ),
              SizedBox(
                width: 260,
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search tickets...',
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
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final ticket = _state.items[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(width: 6, decoration: BoxDecoration(color: _priorityColor(ticket.priority), borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('${ticket.id} • ${DateFormat('MMM dd, yyyy').format(ticket.createdAt)}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500)),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: _priorityColor(ticket.priority).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Text(ticket.priority.displayName, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: _priorityColor(ticket.priority)))
                                        ),
                                      ]
                                    ),
                                    const SizedBox(height: 8),
                                    Text(ticket.title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Client: ${ticket.clientName} | Candidate: ${ticket.candidateName ?? "None"}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey600)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 16, color: AppColors.grey500),
                                        const SizedBox(width: 4),
                                        Text(ticket.assignedTo, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey600)),
                                        const Spacer(),
                                        Text(ticket.status.displayName, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ]
                                    ),
                                  ]
                                )
                              )
                            )
                          ]
                        )
                      )
                    );
                  }
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
