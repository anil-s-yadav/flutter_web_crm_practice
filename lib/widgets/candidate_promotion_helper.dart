import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/audit_log/audit_log_bloc.dart';
import 'package:practice_app/core/default_doc_urls.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/image_picker_helper.dart';

class CandidatePromotionHelper {
  static bool hasDoc(String? url) {
    return url != null && url.trim().isNotEmpty && url.trim() != 'null';
  }

  static Future<void> promoteToVerification(
    BuildContext context,
    CandidateModel candidate,
  ) async {
    final updated = candidate.copyWith(
      status: CandidateStatus.verificationPending,
    );
    context.read<CandidateBloc>().add(UpdateCandidate(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${candidate.fullName} moved to Verification Hub.'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  static Future<void> rollbackToNewlyAdded(
    BuildContext context,
    CandidateModel candidate,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.undo, color: AppColors.urgentAmber, size: 22),
            const SizedBox(width: 10),
            Text(
              'Rollback to Newly Added',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to move "${candidate.fullName}" back to Newly Added? This will unlock the profile for editing.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.grey500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyBlue,
              elevation: 0,
            ),
            child: Text(
              'Rollback',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final updated = candidate.copyWith(
        status: CandidateStatus.newlyAdded,
      );
      context.read<CandidateBloc>().add(UpdateCandidate(updated));
      try {
        context.read<AuditLogBloc>().add(
          LogAuditEvent(
            entityType: 'candidate',
            targetId: candidate.id,
            actionType: 'rollback',
            description:
                'Candidate rolled back from Verification to Newly Added (Profile unlocked)',
          ),
        );
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${candidate.fullName} rolled back to Newly Added (Profile unlocked).'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  static Future<void> promoteToMedical(
    BuildContext context,
    CandidateModel candidate,
  ) async {
    if (!hasDoc(candidate.policeVerificationDocUrl)) {
      _showUploadRequiredDialog(
        context: context,
        candidate: candidate,
        title: 'Police Verification Certificate Required',
        message:
            'A Police Verification Certificate must be uploaded before promoting "${candidate.fullName}" to Medical clearance.',
        docLabel: 'Police Verification Certificate',
        icon: Icons.local_police_outlined,
        onDocumentUploaded: (base64Url) {
          final updated = candidate.copyWith(
            policeVerificationDocUrl: DefaultDocUrls.sanitizeDocUrl(
              base64Url,
              'Police',
            ),
            isPoliceVerified: true,
            status: CandidateStatus.medicalPending,
          );
          context.read<CandidateBloc>().add(UpdateCandidate(updated));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Police certificate uploaded and ${candidate.fullName} promoted to Medical!',
              ),
              backgroundColor: AppColors.successGreen,
            ),
          );
        },
      );
      return;
    }

    final updated = candidate.copyWith(
      status: CandidateStatus.medicalPending,
      isPoliceVerified: true,
    );
    context.read<CandidateBloc>().add(UpdateCandidate(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${candidate.fullName} promoted to Medical Test.'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  static Future<void> promoteToReadyToPlace(
    BuildContext context,
    CandidateModel candidate, {
    bool skipMedical = false,
  }) async {
    // 1. If currently in verificationPending, must have Police Verification Certificate
    if (candidate.status == CandidateStatus.verificationPending) {
      if (!hasDoc(candidate.policeVerificationDocUrl)) {
        _showUploadRequiredDialog(
          context: context,
          candidate: candidate,
          title: 'Police Verification Certificate Required',
          message:
              'A Police Verification Certificate must be uploaded before promoting "${candidate.fullName}" to Ready to Place.',
          docLabel: 'Police Verification Certificate',
          icon: Icons.local_police_outlined,
          onDocumentUploaded: (base64Url) {
            final updated = candidate.copyWith(
              policeVerificationDocUrl: DefaultDocUrls.sanitizeDocUrl(
                base64Url,
                'Police',
              ),
              isPoliceVerified: true,
              status: CandidateStatus.readyToPlace,
              availableFrom: DateTime.now(),
            );
            context.read<CandidateBloc>().add(UpdateCandidate(updated));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Police certificate uploaded and ${candidate.fullName} marked Ready to Place!',
                ),
                backgroundColor: AppColors.successGreen,
              ),
            );
          },
        );
        return;
      }
    }

    // 2. If currently in medicalPending, must have Medical Clearance Certificate
    if (candidate.status == CandidateStatus.medicalPending) {
      if (!hasDoc(candidate.medicalClearanceDocUrl)) {
        _showUploadRequiredDialog(
          context: context,
          candidate: candidate,
          title: 'Medical Clearance Certificate Required',
          message:
              'A Medical Clearance Certificate must be uploaded before promoting "${candidate.fullName}" to Ready to Place.',
          docLabel: 'Medical Clearance Certificate',
          icon: Icons.health_and_safety_outlined,
          onDocumentUploaded: (base64Url) {
            final updated = candidate.copyWith(
              medicalClearanceDocUrl: DefaultDocUrls.sanitizeDocUrl(
                base64Url,
                'Medical',
              ),
              isMedicalCleared: true,
              status: CandidateStatus.readyToPlace,
              availableFrom: DateTime.now(),
            );
            context.read<CandidateBloc>().add(UpdateCandidate(updated));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Medical certificate uploaded and ${candidate.fullName} marked Ready to Place!',
                ),
                backgroundColor: AppColors.successGreen,
              ),
            );
          },
        );
        return;
      }
    }

    final updated = candidate.copyWith(
      status: CandidateStatus.readyToPlace,
      isPoliceVerified: true,
      isMedicalCleared:
          candidate.status == CandidateStatus.medicalPending ||
          candidate.isMedicalCleared,
      availableFrom: DateTime.now(),
    );
    context.read<CandidateBloc>().add(UpdateCandidate(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${candidate.fullName} promoted to Ready to Place!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  static void _showUploadRequiredDialog({
    required BuildContext context,
    required CandidateModel candidate,
    required String title,
    required String message,
    required String docLabel,
    required IconData icon,
    required void Function(String base64Url) onDocumentUploaded,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.urgentAmber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.urgentAmber, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color:
                      isDark ? AppColors.grey300 : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF141A28) : AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        isDark ? const Color(0xFF2A3448) : AppColors.grey200,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upload $docLabel now to proceed with promotion.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey400 : AppColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                try {
                  final picked = await pickImageData();
                  if (picked != null) {
                    onDocumentUploaded(picked.base64DataUrl);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to upload document: $e'),
                        backgroundColor: AppColors.criticalRed,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: Text('Upload $docLabel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyBlue,
                elevation: 0,
                textStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
