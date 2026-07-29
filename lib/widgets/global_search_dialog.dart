import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/repositories/search_repository.dart';
import 'package:practice_app/theme/app_colors.dart';

class GlobalSearchDialog extends StatefulWidget {
  const GlobalSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const GlobalSearchDialog(),
    );
  }

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final SearchRepository _searchRepository = SearchRepository();
  Timer? _debounceTimer;

  bool _isLoading = false;
  SearchResultGroup _results = const SearchResultGroup(
    candidates: [],
    clients: [],
    contracts: [],
    users: [],
    tickets: [],
  );

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _results = const SearchResultGroup(
          candidates: [],
          clients: [],
          contracts: [],
          users: [],
          tickets: [],
        );
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await _searchRepository.search(query);
        if (mounted) {
          setState(() {
            _results = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    });
  }

  void _navigateToTarget(String type, Map<String, dynamic> item) {
    Navigator.pop(context);
    final routePrefix = '/admin'; // default prefix

    switch (type) {
      case 'candidate':
        context.push('$routePrefix/candidates/${item['id']}');
        break;
      case 'client':
        context.push('$routePrefix/clients/${item['id']}');
        break;
      case 'contract':
        context.push('$routePrefix/contracts/${item['id']}');
        break;
      case 'user':
        context.push('$routePrefix/team');
        break;
      case 'ticket':
        context.push('$routePrefix/tickets/${item['id']}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Header
              Row(
                children: [
                  Icon(Icons.search, color: AppColors.gold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search candidates, clients, contracts, phone, IDs...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
              Divider(
                color: isDark ? AppColors.dividerDark : AppColors.grey200,
                height: 24,
              ),

              // Search Results List
              Expanded(
                child: _searchController.text.trim().isEmpty
                    ? _buildHintState(isDark)
                    : _results.isEmpty && !_isLoading
                        ? _buildEmptyState(isDark)
                        : ListView(
                            children: [
                              if (_results.candidates.isNotEmpty)
                                _buildCategorySection(
                                  'Candidates',
                                  Icons.people,
                                  AppColors.navyBlue,
                                  _results.candidates,
                                  (item) => _buildCandidateTile(item, isDark),
                                ),
                              if (_results.clients.isNotEmpty)
                                _buildCategorySection(
                                  'Clients',
                                  Icons.business,
                                  AppColors.gold,
                                  _results.clients,
                                  (item) => _buildClientTile(item, isDark),
                                ),
                              if (_results.contracts.isNotEmpty)
                                _buildCategorySection(
                                  'Contracts',
                                  Icons.description,
                                  AppColors.successGreen,
                                  _results.contracts,
                                  (item) => _buildContractTile(item, isDark),
                                ),
                              if (_results.users.isNotEmpty)
                                _buildCategorySection(
                                  'Team Members',
                                  Icons.badge,
                                  Colors.purple,
                                  _results.users,
                                  (item) => _buildUserTile(item, isDark),
                                ),
                              if (_results.tickets.isNotEmpty)
                                _buildCategorySection(
                                  'Tickets',
                                  Icons.support_agent,
                                  AppColors.criticalRed,
                                  _results.tickets,
                                  (item) => _buildTicketTile(item, isDark),
                                ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: AppColors.grey400),
          const SizedBox(height: 12),
          Text(
            'Type to search across CRM',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search by name, phone number, alternate phone, IDs, category, or email',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 44, color: AppColors.grey400),
          const SizedBox(height: 12),
          Text(
            'No matching records found',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching with a different name, mobile number, or ID',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    IconData icon,
    Color color,
    List<dynamic> items,
    Widget Function(Map<String, dynamic>) tileBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  items.length.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => tileBuilder(item as Map<String, dynamic>)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCandidateTile(Map<String, dynamic> c, bool isDark) {
    final alt = c['alternate_phone'];
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        '${c['full_name']} (${c['id']})',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        'Phone: ${c['phone']}${alt != null && alt.toString().isNotEmpty ? ' | Alt: $alt' : ''} • Category: ${c['category'] ?? 'N/A'}',
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _navigateToTarget('candidate', c),
    );
  }

  Widget _buildClientTile(Map<String, dynamic> cl, bool isDark) {
    final alt = cl['alternate_phone'];
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        '${cl['name']} (${cl['id']})',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        'Phone: ${cl['phone']}${alt != null && alt.toString().isNotEmpty ? ' | Alt: $alt' : ''} • Email: ${cl['email'] ?? 'N/A'}',
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _navigateToTarget('client', cl),
    );
  }

  Widget _buildContractTile(Map<String, dynamic> cnt, bool isDark) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        'Contract #${cnt['id']}',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        'Client: ${cnt['client_name'] ?? cnt['client_id']} • Candidate: ${cnt['candidate_name'] ?? cnt['candidate_id']}',
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _navigateToTarget('contract', cnt),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> u, bool isDark) {
    final alt = u['alternate_phone'];
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        '${u['name']} [${u['role']?.toString().toUpperCase()}]',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        'Email: ${u['email']} • Phone: ${u['phone'] ?? 'N/A'}${alt != null && alt.toString().isNotEmpty ? ' | Alt: $alt' : ''}',
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _navigateToTarget('user', u),
    );
  }

  Widget _buildTicketTile(Map<String, dynamic> t, bool isDark) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        '${t['title']} (${t['id']})',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        'Priority: ${t['priority']} • Status: ${t['status']}',
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _navigateToTarget('ticket', t),
    );
  }
}
