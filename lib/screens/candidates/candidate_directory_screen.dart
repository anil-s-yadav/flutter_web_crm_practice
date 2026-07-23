import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:practice_app/screens/candidates/candidate_data_source.dart';

enum CandidateDirectoryType {
  newlyAdded,
  readyToPlace,
  verificationPending,
  medicalPending,
  placed,
  blacklisted,
}

class CandidateDirectoryScreen extends StatefulWidget {
  final bool readOnly;
  final CandidateDirectoryType type;

  const CandidateDirectoryScreen({
    super.key,
    this.readOnly = false,
    required this.type,
  });

  @override
  State<CandidateDirectoryScreen> createState() =>
      _CandidateDirectoryScreenState();
}

class _CandidateDirectoryScreenState extends State<CandidateDirectoryScreen> {
  final _searchController = TextEditingController();
  final _indianFormat = NumberFormat('#,##,###', 'en_IN');
  String _searchQuery = '';
  String? _selectedLanguage;
  String? _selectedExperience;
  String? _selectedLocation;
  String? _selectedCategory;
  bool _showFilters = false;

  int _activeReadyTabIndex = 0;
  int _activeVerifyTabIndex = 0;

  bool get _isNewStyle =>
      widget.type == CandidateDirectoryType.readyToPlace ||
      widget.type == CandidateDirectoryType.verificationPending;

  void _onRowTap(CandidateModel candidate) {
    final state = Provider.of<GlobalAppState>(context, listen: false);
    final role = state.currentUser?.role;
    String routePrefix = '/sourcing';
    if (role == UserRole.admin) routePrefix = '/admin';
    if (role == UserRole.sales) routePrefix = '/sales';

    context.push(
      '$routePrefix/candidates/${candidate.id}?from=${widget.type.name}',
    );
  }

  void _onActionTap(CandidateModel candidate, String action) {
    if (widget.readOnly) return;
    final state = Provider.of<GlobalAppState>(context, listen: false);

    switch (action) {
      case 'edit':
        final routePrefix =
            state.currentUser?.role == UserRole.admin ? '/admin' : '/sourcing';
        context.push('$routePrefix/candidates/${candidate.id}/edit');
        break;
      case 'promote_verification':
        state.advanceCandidatePipeline(
          candidate.id,
          CandidateStatus.verificationPending,
        );
        break;
      case 'promote_medical':
        state.updateCandidate(
          candidate.copyWith(
            status: CandidateStatus.medicalPending,
            isPoliceVerified: true,
            isAadhaarVerified: true,
          ),
          'Police & Aadhaar Verified. Moved to Medical Pending.',
        );
        break;
      case 'promote_ready':
        state.updateCandidate(
          candidate.copyWith(
            status: CandidateStatus.readyToPlace,
            isPoliceVerified: true,
            isAadhaarVerified: true,
            isMedicalCleared:
                candidate.status == CandidateStatus.medicalPending
                    ? true
                    : false,
            availableFrom: DateTime.now(),
          ),
          candidate.status == CandidateStatus.medicalPending
              ? 'Medical Test Cleared. Moved to Ready to Place.'
              : 'Police & Aadhaar Verified. Medical bypassed. Moved to Ready to Place.',
        );
        break;
      case 'blacklist':
        _showBlacklistDialog(context, candidate.id, state);
        break;
    }
  }

  void _showBlacklistDialog(
    BuildContext context,
    String candidateId,
    GlobalAppState state,
  ) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          title: Text(
            'Blacklist Candidate',
            style: GoogleFonts.poppins(
              color: AppColors.criticalRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please provide a reason for blacklisting this candidate. This action will log a permanent note.',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter blacklist reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppColors.grey500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a note before blacklisting.'),
                    ),
                  );
                  return;
                }
                state.blacklistCandidate(
                  candidateId,
                  noteController.text.trim(),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.criticalRed,
                foregroundColor: AppColors.white,
              ),
              child: Text(
                'Confirm Blacklist',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
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
    final baseCandidates =
        state.candidates.where((m) {
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            final matchesQuery =
                m.fullName.toLowerCase().contains(q) ||
                m.id.toLowerCase().contains(q) ||
                m.category.toLowerCase().contains(q) ||
                m.languages.any((l) => l.toLowerCase().contains(q)) ||
                m.education.toLowerCase().contains(q);
            if (!matchesQuery) return false;
          }
          if (_selectedLanguage != null && _selectedLanguage != 'All') {
            if (!m.languages.contains(_selectedLanguage)) return false;
          }
          if (_selectedExperience != null && _selectedExperience != 'All') {
            final exp = m.experienceYears;
            if (_selectedExperience == '0-1 Years' && exp > 1) return false;
            if (_selectedExperience == '1-3 Years' && (exp <= 1 || exp > 3)) {
              return false;
            }
            if (_selectedExperience == '3-5 Years' && (exp <= 3 || exp > 5)) {
              return false;
            }
            if (_selectedExperience == '5+ Years' && exp <= 5) return false;
          }
          if (_selectedLocation != null && _selectedLocation != 'All') {
            if (m.city.toLowerCase() != _selectedLocation!.toLowerCase()) {
              return false;
            }
          }
          if (_selectedCategory != null && _selectedCategory != 'All') {
            if (m.category.toLowerCase() != _selectedCategory!.toLowerCase()) {
              return false;
            }
          }
          return true;
        }).toList();

    // 2. Routing Logic based on Directory Type
    if (widget.type == CandidateDirectoryType.readyToPlace) {
      final policeAndAadhaar =
          baseCandidates
              .where((m) => m.status == CandidateStatus.readyToPlace)
              .toList();
      final medicalCleared =
          baseCandidates
              .where(
                (m) =>
                    m.status == CandidateStatus.readyToPlace &&
                    m.isMedicalCleared,
              )
              .toList();

      final tabs = [
        'Police & Aadhaar Verified (${policeAndAadhaar.length})',
        'Medical Cleared (${medicalCleared.length})',
      ];

      return Column(
        children: [
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final isSelected = _activeReadyTabIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              tabs[index],
                              style: GoogleFonts.poppins(
                                color:
                                    isSelected
                                        ? AppColors.navyBlue
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.gold,
                            backgroundColor:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _activeReadyTabIndex = index;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                  tooltip: 'Toggle Filters',
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_showFilters)
            _buildToolbar(context, isDark, policeAndAadhaar.length),
          Expanded(
            child:
                _activeReadyTabIndex == 0
                    ? _CandidateGridView(
                      candidates: policeAndAadhaar,
                      isDark: isDark,
                      isNewStyle: _isNewStyle,
                      onRowTap: _onRowTap,
                      onActionTap: _onActionTap,
                    )
                    : _CandidateGridView(
                      candidates: medicalCleared,
                      isDark: isDark,
                      isNewStyle: _isNewStyle,
                      onRowTap: _onRowTap,
                      onActionTap: _onActionTap,
                    ),
          ),
        ],
      );
    }

    if (widget.type == CandidateDirectoryType.verificationPending) {
      final allPending =
          baseCandidates
              .where((m) => m.status == CandidateStatus.verificationPending)
              .toList();
      final policePending =
          allPending.where((m) => !m.isPoliceVerified).toList();
      final aadhaarPending =
          allPending.where((m) => !m.isAadhaarVerified).toList();

      final tabs = [
        'Police Verification Pending (${policePending.length})',
        'Aadhaar Verification Pending (${aadhaarPending.length})',
      ];

      return Column(
        children: [
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final isSelected = _activeVerifyTabIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              tabs[index],
                              style: GoogleFonts.poppins(
                                color:
                                    isSelected
                                        ? AppColors.navyBlue
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.gold,
                            backgroundColor:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _activeVerifyTabIndex = index;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                  tooltip: 'Toggle Filters',
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_showFilters) _buildToolbar(context, isDark, allPending.length),
          Expanded(
            child:
                _activeVerifyTabIndex == 0
                    ? _CandidateGridView(
                      candidates: policePending,
                      isDark: isDark,
                      onRowTap: _onRowTap,
                      onActionTap: _onActionTap,
                      isNewStyle: true,
                    )
                    : _CandidateGridView(
                      candidates: aadhaarPending,
                      isDark: isDark,
                      onRowTap: _onRowTap,
                      onActionTap: _onActionTap,
                      isNewStyle: true,
                    ),
          ),
        ],
      );
    }

    // For single view lists
    List<CandidateModel> displayCandidates = [];
    switch (widget.type) {
      case CandidateDirectoryType.newlyAdded:
        displayCandidates =
            baseCandidates
                .where((m) => m.status == CandidateStatus.newlyAdded)
                .toList();
        break;
      case CandidateDirectoryType.medicalPending:
        displayCandidates =
            baseCandidates
                .where((m) => m.status == CandidateStatus.medicalPending)
                .toList();
        break;
      case CandidateDirectoryType.placed:
        displayCandidates =
            baseCandidates
                .where((m) => m.status == CandidateStatus.Placed)
                .toList();
        break;
      case CandidateDirectoryType.blacklisted:
        displayCandidates =
            baseCandidates
                .where((m) => m.status == CandidateStatus.blacklisted)
                .toList();
        break;
      default:
        break;
    }

    return Column(
      children: [
        _buildToolbar(context, isDark, displayCandidates.length),
        Expanded(
          child: _CandidateGridView(
            candidates: displayCandidates,
            isDark: isDark,
            isNewStyle: _isNewStyle,
            onRowTap: _onRowTap,
            onActionTap: _onActionTap,
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, bool isDark, int count) {
    final isMobile = context.media.width < 900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
          ),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          isMobile
              ? _buildMobileToolbar(isDark, count)
              : _buildDesktopToolbar(isDark, count),
    );
  }

  Widget _buildMobileToolbar(bool isDark, int count) {
    // If old style, we conditionally hide the filters part using the mobile toggle
    bool showFiltersArea = _isNewStyle ? true : _showFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isNewStyle) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_indianFormat.format(count)} Candidates found',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.dividerDark : AppColors.grey300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color:
                        _showFilters
                            ? (isDark ? AppColors.navyBlue : AppColors.grey200)
                            : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        if (showFiltersArea || _isNewStyle) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search candidates...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.grey500,
                ),
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey300,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterDropdown(
                value: _selectedCategory,
                hint: 'Category',
                items: ['All', 'Maid', 'Cook', 'Nanny', 'Caretaker'],
                onChanged: (val) => setState(() => _selectedCategory = val),
                isDark: isDark,
              ),
              _buildFilterDropdown(
                value: _selectedLanguage,
                hint: 'Language',
                items: [
                  'All',
                  'Hindi',
                  'Marathi',
                  'English',
                  'Tamil',
                  'Telugu',
                  'Gujarati',
                  'Bengali',
                ],
                onChanged: (val) => setState(() => _selectedLanguage = val),
                isDark: isDark,
              ),
              _buildFilterDropdown(
                value: _selectedExperience,
                hint: 'Experience',
                items: [
                  'All',
                  '0-1 Years',
                  '1-3 Years',
                  '3-5 Years',
                  '5+ Years',
                ],
                onChanged: (val) => setState(() => _selectedExperience = val),
                isDark: isDark,
              ),
              _buildFilterDropdown(
                value: _selectedLocation,
                hint: 'Location',
                items: [
                  'All',
                  'Andheri',
                  'Bandra',
                  'Borivali',
                  'Dadar',
                  'Ghatkopar',
                  'Juhu',
                  'Kurla',
                  'Powai',
                  'Thane',
                  'Worli',
                ],
                onChanged: (val) => setState(() => _selectedLocation = val),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopToolbar(bool isDark, int count) {
    return Row(
      children: [
        if (!_isNewStyle) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_indianFormat.format(count)} Candidates found',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
          ),
          const Spacer(),
        ],
        const Spacer(),
        _buildFilterDropdown(
          value: _selectedCategory,
          hint: 'Category',
          items: ['All', 'Maid', 'Cook', 'Nanny', 'Caretaker'],
          onChanged: (val) => setState(() => _selectedCategory = val),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildFilterDropdown(
          value: _selectedLanguage,
          hint: 'Language',
          items: [
            'All',
            'Hindi',
            'Marathi',
            'English',
            'Tamil',
            'Telugu',
            'Gujarati',
            'Bengali',
          ],
          onChanged: (val) => setState(() => _selectedLanguage = val),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildFilterDropdown(
          value: _selectedExperience,
          hint: 'Experience',
          items: ['All', '0-1 Years', '1-3 Years', '3-5 Years', '5+ Years'],
          onChanged: (val) => setState(() => _selectedExperience = val),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildFilterDropdown(
          value: _selectedLocation,
          hint: 'Location',
          items: [
            'All',
            'Andheri',
            'Bandra',
            'Borivali',
            'Dadar',
            'Ghatkopar',
            'Juhu',
            'Kurla',
            'Powai',
            'Thane',
            'Worli',
          ],
          onChanged: (val) => setState(() => _selectedLocation = val),
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
              hintText: 'Search candidates...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.grey500,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey300,
                ),
              ),
            ),
          ),
        ),
      ],
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
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey500),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? AppColors.white : AppColors.textPrimaryLight,
          ),
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CandidateGridView extends StatelessWidget {
  final List<CandidateModel> candidates;
  final bool isDark;
  final bool isNewStyle;
  final Function(CandidateModel) onRowTap;
  final Function(CandidateModel, String) onActionTap;

  const _CandidateGridView({
    required this.candidates,
    required this.isDark,
    required this.isNewStyle,
    required this.onRowTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return Center(
        child: Text(
          'No candidates found.',
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
      );
    }

    final isDesktop = context.media.width > 900;
    if (!isDesktop) {
      return _buildMobileList(isDark, candidates);
    }

    final dataSource = CandidateDataSource(
      context: context,
      isDark: isDark,
      candidates: candidates,
      onRowTap: onRowTap,
      onActionTap: onActionTap,
    );

    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              // margin: const EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SfDataGridTheme(
                  data: SfDataGridThemeData(
                    headerColor:
                        isDark ? AppColors.darkSurface : AppColors.grey50,
                    gridLineColor:
                        isDark ? AppColors.dividerDark : AppColors.grey200,
                    gridLineStrokeWidth: 1,
                    rowHoverColor:
                        isDark
                            ? AppColors.navyBlue.withValues(alpha: 0.1)
                            : AppColors.navyBlue.withValues(alpha: 0.04),
                    sortIconColor: AppColors.gold,
                  ),
                  child: SfDataGrid(
                    source: dataSource,
                    allowSorting: true,
                    allowMultiColumnSorting: false,
                    columnWidthMode: ColumnWidthMode.auto,
                    gridLinesVisibility: GridLinesVisibility.both,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    columns: <GridColumn>[
                      GridColumn(
                        columnName: 'id',
                        visible: false,
                        label: const SizedBox.shrink(),
                      ),
                      GridColumn(
                        columnName: 'sr_no',
                        columnWidthMode: ColumnWidthMode.auto,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ID',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'date',
                        width: 120,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Date',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'candidate',
                        width: 220,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Profile',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'category',
                        minimumWidth: 120,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Category',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'experience',
                        width: 100,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Exp (Yrs)',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'salary',
                        minimumWidth: 140,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Expected Salary',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'education',
                        minimumWidth: 120,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Education',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'languages',
                        minimumWidth: 120,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Lang',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'status',
                        width: 150,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Status',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'actions',
                        width: 80,
                        label: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Text(
                            'Actions',
                            style: _headerStyle(isDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Pagination
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey200,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment:
                isNewStyle
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
            children: [
              if (isNewStyle)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${NumberFormat('#,##,###', 'en_IN').format(candidates.length)} Candidates found',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IconButton(
                    icon: Icon(Icons.chevron_left, size: 20),
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Page 1 of 1',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const IconButton(
                    icon: Icon(Icons.chevron_right, size: 20),
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(bool isDark, List<CandidateModel> candidates) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: candidates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _MobileCandidateCard(
          candidate: candidates[index],
          isDark: isDark,
          onRowTap: onRowTap,
          onActionTap: onActionTap,
          statusBadgeBuilder: _buildStatusBadge,
          statusColorBuilder: _candidateStatusColor,
        );
      },
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _candidateStatusColor(CandidateStatus status) {
    switch (status) {
      case CandidateStatus.newlyAdded:
        return AppColors.statusInterviewed;
      case CandidateStatus.verificationPending:
        return AppColors.stagePoliceVerification;
      case CandidateStatus.medicalPending:
        return AppColors.stageMedicalCheck;
      case CandidateStatus.readyToPlace:
        return AppColors.statusVerified;
      case CandidateStatus.Placed:
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

  TextStyle _headerStyle(bool isDark) => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.goldLight : AppColors.grey600,
  );
}

class _MobileCandidateCard extends StatefulWidget {
  final CandidateModel candidate;
  final bool isDark;
  final Function(CandidateModel) onRowTap;
  final Function(CandidateModel, String) onActionTap;
  final Widget Function(String, Color) statusBadgeBuilder;
  final Color Function(CandidateStatus) statusColorBuilder;

  const _MobileCandidateCard({
    required this.candidate,
    required this.isDark,
    required this.onRowTap,
    required this.onActionTap,
    required this.statusBadgeBuilder,
    required this.statusColorBuilder,
  });

  @override
  State<_MobileCandidateCard> createState() => _MobileCandidateCardState();
}

class _MobileCandidateCardState extends State<_MobileCandidateCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    final isDark = widget.isDark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row (Always visible)
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        isDark
                            ? AppColors.white.withValues(alpha: 0.1)
                            : AppColors.navyBlue.withValues(alpha: 0.1),
                    child: Text(
                      candidate.fullName[0],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? AppColors.white
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          candidate.category,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.statusBadgeBuilder(
                    candidate.status.displayName,
                    widget.statusColorBuilder(candidate.status),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                    onSelected:
                        (action) => widget.onActionTap(candidate, action),
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
                      } else if (candidate.status ==
                          CandidateStatus.verificationPending) {
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
                      } else if (candidate.status ==
                          CandidateStatus.medicalPending) {
                        items.add(
                          const PopupMenuItem(
                            value: 'promote_ready',
                            child: Text('Promote to Ready'),
                          ),
                        );
                      }
                      if (candidate.status != CandidateStatus.blacklisted &&
                          candidate.status != CandidateStatus.Placed) {
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
                ],
              ),
              // Expanded Area
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      'Experience',
                      '${candidate.experienceYears} Yrs',
                      isDark,
                    ),
                    _buildDetailItem(
                      'Expected Salary',
                      '₹${candidate.expectedSalary}',
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem('Education', candidate.education, isDark),
                    _buildDetailItem(
                      'Languages',
                      candidate.languages.join(', '),
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassmorphismButton(
                        icon: Icons.call,
                        label: 'Call',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Calling +91 9876543210... (Dummy Number)',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGlassmorphismButton(
                        icon: Icons.visibility,
                        label: 'View',
                        isDark: isDark,
                        baseColor: AppColors.gold,
                        onTap: () => widget.onRowTap(candidate),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? AppColors.grey400 : AppColors.grey500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    Color? baseColor,
  }) {
    final effectiveColor =
        baseColor ?? (isDark ? AppColors.white : AppColors.gold);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: isDark ? 0.1 : 0.08),
              border: Border.all(
                color: effectiveColor.withValues(alpha: isDark ? 0.2 : 0.15),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: effectiveColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
