import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/maid_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/audit_log_widget.dart';
import 'package:provider/provider.dart';

class MaidProfileScreen extends StatelessWidget {
  final String maidId;

  const MaidProfileScreen({super.key, required this.maidId});

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

  int _pipelineProgress(MaidStatus status) {
    switch (status) {
      case MaidStatus.newlyAdded: return 1;
      case MaidStatus.verificationPending: return 2;
      case MaidStatus.medicalPending: return 3;
      case MaidStatus.readyToPlace:
      case MaidStatus.placed: return 4;
      case MaidStatus.blacklisted: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = context.media.width < 800;

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final maid = state.getMaid(maidId);
    if (maid == null) {
      return const Center(child: Text('Maid not found'));
    }

    final relevantLogs = state.auditLogs.where((l) => l.targetId == maid.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Candidate Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if ((state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin) && maid.status == MaidStatus.newlyAdded)
            TextButton.icon(
              onPressed: () {
                final routePrefix = state.currentUser?.role == UserRole.admin ? '/admin' : '/sourcing';
                context.go('$routePrefix/maids/${maid.id}/edit');
              },
              icon: const Icon(Icons.edit, size: 18),
              label: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: AppColors.navyBlue),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(maid, isDark),
            const SizedBox(height: 24),
            _buildPipelineIndicator(maid, isDark),
            const SizedBox(height: 24),
            if (isMobile)
              Column(
                children: [
                  _buildPersonalDetails(maid, isDark),
                  const SizedBox(height: 16),
                  _buildLanguages(maid, isDark),
                  const SizedBox(height: 16),
                  _buildVerificationStatus(maid, isDark),
                  const SizedBox(height: 16),
                  _buildDocuments(maid, isDark),
                  const SizedBox(height: 16),
                  if (maid.currentPlacementId != null) _buildCurrentPlacement(maid, isDark),
                  if (maid.remarks != null) ...[
                    const SizedBox(height: 16),
                    _buildRemarks(maid, isDark),
                  ],
                  const SizedBox(height: 24),
                  if (state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin)
                    _buildActionBar(context, maid, isDark),
                ]
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildPersonalDetails(maid, isDark),
                        const SizedBox(height: 16),
                        _buildLanguages(maid, isDark),
                        const SizedBox(height: 16),
                        if (maid.remarks != null) _buildRemarks(maid, isDark),
                      ]
                    )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildVerificationStatus(maid, isDark),
                        const SizedBox(height: 16),
                        _buildDocuments(maid, isDark),
                        const SizedBox(height: 16),
                        if (maid.currentPlacementId != null) _buildCurrentPlacement(maid, isDark),
                        const SizedBox(height: 24),
                        if (state.currentUser?.role == UserRole.sourcing || state.currentUser?.role == UserRole.admin)
                          _buildActionBar(context, maid, isDark),
                      ]
                    )
                  ),
                ]
              ),
            const SizedBox(height: 32),
            AuditLogWidget(logs: relevantLogs, title: 'Candidate Activity History'),
          ]
        )
      )
    );
  }

  Widget _buildProfileHeader(MaidModel maid, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
              child: Text(
                maid.fullName.isNotEmpty ? maid.fullName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join() : '?',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navyBlue)
              )
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(maid.fullName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? AppColors.white : AppColors.navyBlue)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildBadge(maid.category, AppColors.gold),
                      const SizedBox(width: 8),
                      _buildBadge(maid.status.displayName, _maidStatusColor(maid.status)),
                    ]
                  ),
                  const SizedBox(height: 6),
                  Text('ID: ${maid.id} • ${maid.city} • ${maid.experienceYears} yrs experience', style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.grey400 : AppColors.grey600)),
                ]
              )
            ),
          ]
        )
      )
    );
  }

  Widget _buildPipelineIndicator(MaidModel maid, bool isDark) {
    final progress = _pipelineProgress(maid.status);
    final steps = ['New', 'Verification', 'Medical', 'Ready'];
    final colors = [AppColors.stageInterviewed, AppColors.stagePoliceVerification, AppColors.stageMedicalCheck, AppColors.stageVerified];
    final dates = [
      maid.dateAdded,
      maid.dateVerificationSent,
      maid.dateMedicalSent,
      maid.dateReadyToHire,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pipeline Progress', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue)),
            const SizedBox(height: 16),
            Row(
              children: List.generate(steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final stepIndex = i ~/ 2;
                  return Expanded(child: Container(height: 3, color: stepIndex < progress ? colors[stepIndex] : (isDark ? AppColors.grey700 : AppColors.grey300)));
                }
                final stepIndex = i ~/ 2;
                final isComplete = stepIndex < progress;
                return Column(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: isComplete ? colors[stepIndex] : (isDark ? AppColors.grey700 : AppColors.grey300)),
                      child: Icon(isComplete ? Icons.check : Icons.circle, size: isComplete ? 18 : 8, color: AppColors.white)
                    ),
                    const SizedBox(height: 6),
                    Text(steps[stepIndex], style: GoogleFonts.poppins(fontSize: 10, fontWeight: isComplete ? FontWeight.w600 : FontWeight.w400, color: isComplete ? colors[stepIndex] : (isDark ? AppColors.grey500 : AppColors.grey600))),
                    if (dates[stepIndex] != null) ...[
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM dd').format(dates[stepIndex]!), style: GoogleFonts.poppins(fontSize: 9, color: isDark ? AppColors.grey500 : AppColors.grey600)),
                    ]
                  ]
                );
              })
            ),
          ]
        )
      )
    );
  }

  Widget _buildPersonalDetails(MaidModel maid, bool isDark) {
    return _buildSection('Personal Details', isDark, [
      _infoRow('Age', '${maid.age} years', isDark),
      _infoRow('Phone', maid.phone, isDark),
      if (maid.altPhone != null) _infoRow('Alt Phone', maid.altPhone!, isDark),
      _infoRow('Address', maid.address, isDark),
      _infoRow('City', '${maid.city}, ${maid.state}', isDark),
      _infoRow('Religion', maid.religion, isDark),
      _infoRow('Expected Salary', maid.expectedSalary, isDark),
      _infoRow('Working Hours', '${maid.workingHoursPerDay} hrs/day', isDark),
      if (maid.preferredWorkType != null) _infoRow('Pref. Work Type', maid.preferredWorkType!, isDark),
    ]);
  }

  Widget _buildLanguages(MaidModel maid, bool isDark) {
    return _buildSection('Languages', isDark, [
      Wrap(spacing: 6, runSpacing: 6, children: maid.languages.map((l) => Chip(label: Text(l), labelStyle: GoogleFonts.poppins(fontSize: 11), backgroundColor: AppColors.stageInterviewed.withValues(alpha: 0.1), side: BorderSide.none, visualDensity: VisualDensity.compact)).toList()),
    ]);
  }

  Widget _buildVerificationStatus(MaidModel maid, bool isDark) {
    return _buildSection('Verification Hub', isDark, [
      _verificationItem('Police Verification', maid.isPoliceVerified, isDark),
      _verificationItem('Aadhaar Verification', maid.isAadhaarVerified, isDark),
      _verificationItem('Medical Clearance', maid.isMedicalCleared, isDark),
    ]);
  }

  Widget _buildDocuments(MaidModel maid, bool isDark) {
    return _buildSection('Documents', isDark, [
      _documentRow('Aadhaar', maid.aadhaarDocUrl, isDark),
      _documentRow('Medical Clearance', maid.medicalClearanceDocUrl, isDark),
      _documentRow('Police Verification', maid.policeVerificationDocUrl, isDark),
    ]);
  }

  Widget _buildCurrentPlacement(MaidModel maid, bool isDark) {
    return _buildSection('Current Placement', isDark, [
      _infoRow('Placement ID', maid.currentPlacementId ?? 'N/A', isDark),
    ]);
  }

  Widget _buildRemarks(MaidModel maid, bool isDark) {
    return _buildSection('Remarks', isDark, [
      Text(maid.remarks ?? '', style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight)),
    ]);
  }

  Widget _buildActionBar(BuildContext context, MaidModel maid, bool isDark) {
    final state = Provider.of<GlobalAppState>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.criticalRed.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          if (maid.status == MaidStatus.newlyAdded) ...[
            _actionButton('Edit Profile', Icons.edit, AppColors.navyBlue, isDark, () {
              final routePrefix = state.currentUser?.role == UserRole.admin ? '/admin' : '/sourcing';
              context.go('$routePrefix/maids/${maid.id}/edit');
            }),
            _actionButton('Move to Verification', Icons.fact_check, AppColors.stagePoliceVerification, isDark, () {
              Provider.of<GlobalAppState>(context, listen: false).advanceMaidPipeline(maid.id, MaidStatus.verificationPending);
            }),
          ],
            
          if (maid.status == MaidStatus.verificationPending) ...[
            _actionButton('Promote to Medical Test', Icons.medical_services, AppColors.stageMedicalCheck, isDark, () {
              Provider.of<GlobalAppState>(context, listen: false).updateMaid(
                maid.copyWith(
                  status: MaidStatus.medicalPending,
                  isPoliceVerified: true,
                  isAadhaarVerified: true
                ),
                'Police & Aadhaar Verified. Moved to Medical Pending.'
              );
            }),
            _actionButton('Promote to Ready to Hire', Icons.verified, AppColors.statusVerified, isDark, () {
              Provider.of<GlobalAppState>(context, listen: false).updateMaid(
                maid.copyWith(
                  status: MaidStatus.readyToPlace,
                  isPoliceVerified: true,
                  isAadhaarVerified: true,
                  isMedicalCleared: false, // Explicitly bypassed
                  availableFrom: DateTime.now(),
                ),
                'Police & Aadhaar Verified. Medical bypassed. Moved to Ready to Place.'
              );
            }),
          ],
          
          if (maid.status == MaidStatus.medicalPending)
            _actionButton('Promote to Ready to Hire', Icons.verified, AppColors.statusVerified, isDark, () {
              Provider.of<GlobalAppState>(context, listen: false).updateMaid(
                maid.copyWith(
                  status: MaidStatus.readyToPlace,
                  isMedicalCleared: true,
                  availableFrom: DateTime.now(),
                ),
                'Medical Test Cleared. Moved to Ready to Place.'
              );
            }),

          if (maid.status != MaidStatus.blacklisted && maid.status != MaidStatus.placed)
            _actionButton('Blacklist', Icons.block, AppColors.statusBlacklisted, isDark, () {
              _showBlacklistDialog(context, maid.id);
            }),
        ]
      )
    );
  }

  void _showBlacklistDialog(BuildContext context, String maidId) {
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
                Provider.of<GlobalAppState>(context, listen: false).blacklistMaid(maidId, noteController.text.trim());
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

  Widget _actionButton(String label, IconData icon, Color color, bool isDark, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      )
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue)),
            const SizedBox(height: 12),
            ...children,
          ]
        )
      )
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.grey400 : AppColors.grey600))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.white : AppColors.textPrimaryLight))),
        ]
      )
    );
  }

  Widget _verificationItem(String label, bool isVerified, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(isVerified ? Icons.check_circle : Icons.cancel, size: 20, color: isVerified ? AppColors.successGreen : AppColors.criticalRed),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight)),
        ]
      )
    );
  }

  Widget _documentRow(String name, String? url, bool isDark) {
    final hasDoc = url != null && url.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(hasDoc ? Icons.description : Icons.description_outlined, size: 18, color: hasDoc ? AppColors.successGreen : AppColors.grey500),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight))),
          Text(hasDoc ? 'Uploaded' : 'Missing', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: hasDoc ? AppColors.successGreen : AppColors.urgentAmber)),
        ]
      )
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color))
    );
  }
}
