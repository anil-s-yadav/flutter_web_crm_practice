import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/maid_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:practice_app/screens/maids/maid_data_source.dart';

enum MaidDirectoryType {
  newlyAdded,
  readyToPlace,
  verificationPending,
  medicalPending,
  hired,
  blacklisted,
}

class MaidDirectoryScreen extends StatefulWidget {
  final bool readOnly;
  final MaidDirectoryType type;

  const MaidDirectoryScreen({
    super.key,
    this.readOnly = false,
    required this.type,
  });

  @override
  State<MaidDirectoryScreen> createState() => _MaidDirectoryScreenState();
}

class _MaidDirectoryScreenState extends State<MaidDirectoryScreen> {
  final _searchController = TextEditingController();
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');
  String _searchQuery = '';
  String? _selectedLanguage;
  String? _selectedEducation;

  void _onRowTap(MaidModel maid) {
    if (!widget.readOnly) {
      final state = Provider.of<GlobalAppState>(context, listen: false);
      final routePrefix = state.currentUser?.role == UserRole.admin ? '/admin' : '/sourcing';
      context.go('$routePrefix/maids/${maid.id}');
    }
  }

  void _onActionTap(MaidModel maid, String action) {
    if (widget.readOnly) return;
    final state = Provider.of<GlobalAppState>(context, listen: false);
    
    switch (action) {
      case 'edit':
        final routePrefix = state.currentUser?.role == UserRole.admin ? '/admin' : '/sourcing';
        context.go('$routePrefix/maids/${maid.id}/edit');
        break;
      case 'promote_verification':
        state.advanceMaidPipeline(maid.id, MaidStatus.verificationPending);
        break;
      case 'promote_medical':
        state.updateMaid(
          maid.copyWith(
            status: MaidStatus.medicalPending,
            isPoliceVerified: true,
            isAadhaarVerified: true
          ),
          'Police & Aadhaar Verified. Moved to Medical Pending.'
        );
        break;
      case 'promote_ready':
        state.updateMaid(
          maid.copyWith(
            status: MaidStatus.readyToPlace,
            isPoliceVerified: true,
            isAadhaarVerified: true,
            isMedicalCleared: maid.status == MaidStatus.medicalPending ? true : false,
            availableFrom: DateTime.now(),
          ),
          maid.status == MaidStatus.medicalPending 
              ? 'Medical Test Cleared. Moved to Ready to Place.' 
              : 'Police & Aadhaar Verified. Medical bypassed. Moved to Ready to Place.'
        );
        break;
      case 'blacklist':
        _showBlacklistDialog(context, maid.id, state);
        break;
    }
  }

  void _showBlacklistDialog(BuildContext context, String maidId, GlobalAppState state) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          title: Text('Blacklist Candidate', style: GoogleFonts.poppins(color: AppColors.criticalRed, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please provide a reason for blacklisting this candidate. This action will log a permanent note.', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter blacklist reason...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                )
              )
            ]
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.grey500))
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a note before blacklisting.')));
                  return;
                }
                state.blacklistMaid(maidId, noteController.text.trim());
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed, foregroundColor: AppColors.white),
              child: Text('Confirm Blacklist', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // 1. Search Filter
    final baseMaids = state.maids.where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesQuery = m.fullName.toLowerCase().contains(q) ||
               m.id.toLowerCase().contains(q) ||
               m.category.toLowerCase().contains(q) ||
               m.languages.any((l) => l.toLowerCase().contains(q)) ||
               m.education.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }
      if (_selectedLanguage != null && _selectedLanguage != 'All') {
        if (!m.languages.contains(_selectedLanguage)) return false;
      }
      if (_selectedEducation != null && _selectedEducation != 'All') {
        if (m.education != _selectedEducation) return false;
      }
      return true;
    }).toList();

    // 2. Routing Logic based on Directory Type
    if (widget.type == MaidDirectoryType.readyToPlace) {
      final policeAndAadhaar = baseMaids.where((m) => m.status == MaidStatus.readyToPlace).toList();
      final medicalCleared = baseMaids.where((m) => m.status == MaidStatus.readyToPlace && m.isMedicalCleared).toList();
      
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              child: TabBar(
                indicatorColor: AppColors.navyBlue,
                labelColor: isDark ? AppColors.white : AppColors.navyBlue,
                unselectedLabelColor: AppColors.grey500,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Police & Aadhaar Verified (${policeAndAadhaar.length})'),
                  Tab(text: 'Medical Cleared (${medicalCleared.length})'),
                ],
              ),
            ),
            _buildToolbar(isDark, policeAndAadhaar.length),
            Expanded(
              child: TabBarView(
                children: [
                  _MaidGridView(maids: policeAndAadhaar, isDark: isDark, onRowTap: _onRowTap, onActionTap: _onActionTap),
                  _MaidGridView(maids: medicalCleared, isDark: isDark, onRowTap: _onRowTap, onActionTap: _onActionTap),
                ],
              ),
            ),
          ]
        ),
      );
    } 
    
    if (widget.type == MaidDirectoryType.verificationPending) {
      final allPending = baseMaids.where((m) => m.status == MaidStatus.verificationPending).toList();
      final policePending = allPending.where((m) => !m.isPoliceVerified).toList();
      final aadhaarPending = allPending.where((m) => !m.isAadhaarVerified).toList();

      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              child: TabBar(
                indicatorColor: AppColors.navyBlue,
                labelColor: isDark ? AppColors.white : AppColors.navyBlue,
                unselectedLabelColor: AppColors.grey500,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Police Verification Pending (${policePending.length})'),
                  Tab(text: 'Aadhaar Verification Pending (${aadhaarPending.length})'),
                ],
              ),
            ),
            _buildToolbar(isDark, allPending.length),
            Expanded(
              child: TabBarView(
                children: [
                  _MaidGridView(maids: policePending, isDark: isDark, onRowTap: _onRowTap, onActionTap: _onActionTap),
                  _MaidGridView(maids: aadhaarPending, isDark: isDark, onRowTap: _onRowTap, onActionTap: _onActionTap),
                ],
              ),
            ),
          ]
        ),
      );
    }

    // For single view lists
    List<MaidModel> displayMaids = [];
    switch (widget.type) {
      case MaidDirectoryType.newlyAdded:
        displayMaids = baseMaids.where((m) => m.status == MaidStatus.newlyAdded).toList();
        break;
      case MaidDirectoryType.medicalPending:
        displayMaids = baseMaids.where((m) => m.status == MaidStatus.medicalPending).toList();
        break;
      case MaidDirectoryType.hired:
        displayMaids = baseMaids.where((m) => m.status == MaidStatus.placed).toList();
        break;
      case MaidDirectoryType.blacklisted:
        displayMaids = baseMaids.where((m) => m.status == MaidStatus.blacklisted).toList();
        break;
      default:
        break;
    }

    return Column(
      children: [
        _buildToolbar(isDark, displayMaids.length),
        Expanded(
          child: _MaidGridView(maids: displayMaids, isDark: isDark, onRowTap: _onRowTap, onActionTap: _onActionTap),
        ),
      ]
    );
  }

  Widget _buildToolbar(bool isDark, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200))
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.navyBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text(
              '${_indianFormat.format(count)} Candidates found',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue
              )
            )
          ),
          const Spacer(),
          _buildFilterDropdown(
            value: _selectedLanguage,
            hint: 'Language',
            items: ['All', 'Hindi', 'Marathi', 'English', 'Tamil', 'Telugu', 'Gujarati', 'Bengali'],
            onChanged: (val) => setState(() => _selectedLanguage = val),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterDropdown(
            value: _selectedEducation,
            hint: 'Education',
            items: ['All', 'Below 10th', '10th Pass', '12th Pass', 'Graduate'],
            onChanged: (val) => setState(() => _selectedEducation = val),
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search maids...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey500),
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey300)
                )
              )
            )
          ),
        ]
      )
    );
  }

  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.grey300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey500)),
          icon: Icon(Icons.arrow_drop_down, color: isDark ? AppColors.grey400 : AppColors.grey600),
          style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.white : AppColors.textPrimaryLight),
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MaidGridView extends StatelessWidget {
  final List<MaidModel> maids;
  final bool isDark;
  final Function(MaidModel) onRowTap;
  final Function(MaidModel, String) onActionTap;

  const _MaidGridView({required this.maids, required this.isDark, required this.onRowTap, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    if (maids.isEmpty) {
      return Center(
        child: Text('No candidates found.', style: GoogleFonts.poppins(color: isDark ? AppColors.grey400 : AppColors.grey600)),
      );
    }

    final isDesktop = context.media.width > 900;
    if (!isDesktop) {
      return _buildMobileList(isDark, maids);
    }

    final dataSource = MaidDataSource(
      context: context,
      isDark: isDark,
      maids: maids,
      onRowTap: onRowTap,
      onActionTap: onActionTap,
    );

    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        rowHoverColor: isDark ? AppColors.navyBlue.withValues(alpha: 0.1) : AppColors.navyBlue.withValues(alpha: 0.04),
        sortIconColor: isDark ? AppColors.gold : AppColors.navyBlue,
      ),
      child: SfDataGrid(
        source: dataSource,
        allowSorting: true,
        allowMultiColumnSorting: false,
        columnWidthMode: ColumnWidthMode.fill,
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.none,
        columns: <GridColumn>[
          GridColumn(columnName: 'id', visible: false, label: const SizedBox.shrink()),
          GridColumn(
            columnName: 'maid',
            minimumWidth: 250,
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Profile', style: _headerStyle))
          ),
          GridColumn(
            columnName: 'category',
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Category', style: _headerStyle))
          ),
          GridColumn(
            columnName: 'experience',
            width: 100,
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Exp (Yrs)', style: _headerStyle))
          ),
          GridColumn(
            columnName: 'salary',
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Expected Salary', style: _headerStyle))
          ),
          GridColumn(
            columnName: 'education',
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Education', style: _headerStyle))
          ),
          GridColumn(
            columnName: 'languages',
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Lang', style: _headerStyle))
          ),
          GridColumn(
            columnName: 'status',
            width: 150,
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, child: Text('Status', style: _headerStyle))
          ),
          GridColumn(
            columnName: 'actions',
            width: 80,
            label: Container(padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.center, child: Text('Actions', style: _headerStyle))
          ),
        ],
      )
    );
  }

  Widget _buildMobileList(bool isDark, List<MaidModel> maids) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: maids.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final maid = maids[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)
          ),
          color: isDark ? AppColors.darkSurface : AppColors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onRowTap(maid),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
                        child: Text(maid.fullName[0], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.navyBlue))
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(maid.fullName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.textPrimaryLight)),
                            Text(maid.category, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.grey400 : AppColors.grey600)),
                          ]
                        )
                      ),
                      _buildStatusBadge(maid.status.displayName, _maidStatusColor(maid.status)),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, size: 20, color: isDark ? AppColors.grey400 : AppColors.grey600),
                        onSelected: (action) => onActionTap(maid, action),
                        itemBuilder: (context) {
                          final items = <PopupMenuEntry<String>>[];
                          if (maid.status == MaidStatus.newlyAdded) {
                            items.add(const PopupMenuItem(value: 'edit', child: Text('Edit Profile')));
                            items.add(const PopupMenuItem(value: 'promote_verification', child: Text('Move to Verification')));
                          } else if (maid.status == MaidStatus.verificationPending) {
                            items.add(const PopupMenuItem(value: 'promote_medical', child: Text('Promote to Medical')));
                            items.add(const PopupMenuItem(value: 'promote_ready', child: Text('Promote to Ready (Skip Medical)')));
                          } else if (maid.status == MaidStatus.medicalPending) {
                            items.add(const PopupMenuItem(value: 'promote_ready', child: Text('Promote to Ready')));
                          }
                          if (maid.status != MaidStatus.blacklisted && maid.status != MaidStatus.placed) {
                            items.add(const PopupMenuItem(value: 'blacklist', child: Text('Blacklist', style: TextStyle(color: AppColors.criticalRed))));
                          }
                          return items;
                        },
                      ),
                    ]
                  ),
                ]
              )
            )
          )
        );
      }
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: color))
    );
  }

  Color _maidStatusColor(MaidStatus status) {
    switch (status) {
      case MaidStatus.newlyAdded: return AppColors.statusInterviewed;
      case MaidStatus.verificationPending: return AppColors.stagePoliceVerification;
      case MaidStatus.medicalPending: return AppColors.stageMedicalCheck;
      case MaidStatus.readyToPlace: return AppColors.statusVerified;
      case MaidStatus.placed: return AppColors.statusPlaced;
      case MaidStatus.blacklisted: return AppColors.statusBlacklisted;
    }
  }

  TextStyle get _headerStyle => GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey600);
}
