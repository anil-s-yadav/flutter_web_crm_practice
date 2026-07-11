import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/models/executive_task_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class ExecutiveTaskDetailScreen extends StatelessWidget {
  final String taskId;

  const ExecutiveTaskDetailScreen({super.key, required this.taskId});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      EasyLoading.showError('Could not launch $urlString');
    }
  }

  void _showUpdateStatusSheet(
    BuildContext context,
    ExecutiveTaskModel task,
    GlobalAppState state,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Task Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                ),
                title: const Text('Mark as Completed'),
                onTap: () {
                  Navigator.pop(context);
                  state.markTaskCompleted(task.id);
                  EasyLoading.showSuccess('Task Completed');
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment, color: AppColors.gold),
                title: const Text('Mark Payment Collected'),
                onTap: () {
                  Navigator.pop(context);
                  state.updateTask(task.copyWith(isPaymentCollected: true));
                  EasyLoading.showSuccess('Payment Collected');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inFmt = NumberFormat('#,##,###', 'en_IN');

    // Find the task
    final taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Not Found')),
        body: const Center(child: Text('The requested task does not exist.')),
      );
    }
    final task = state.tasks[taskIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              task.status == TaskStatus.completed
                                  ? AppColors.successGreen.withValues(
                                    alpha: 0.1,
                                  )
                                  : AppColors.warningOrange.withValues(
                                    alpha: 0.1,
                                  ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.status.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                task.status == TaskStatus.completed
                                    ? AppColors.successGreen
                                    : AppColors.warningOrange,
                          ),
                        ),
                      ),
                      Text(
                        'ID: ${task.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    task.type.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled: ${DateFormat('dd MMM yyyy, hh:mm a').format(task.scheduledDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Info Section
            Text(
              'Customer Basics',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: AppColors.gold),
                    title: Text(
                      'Name',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    subtitle: Text(
                      task.clientName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone, color: AppColors.gold),
                    title: Text(
                      'Phone',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    subtitle: Text(
                      task.clientPhone,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: AppColors.navyBlue),
                      onPressed: () => _launchUrl('tel:${task.clientPhone}'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_on,
                      color: AppColors.gold,
                    ),
                    title: Text(
                      'Address',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    subtitle: Text(
                      task.clientAddress,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.navigation,
                        color: AppColors.navyBlue,
                      ),
                      onPressed: () {
                        final encodedAddress = Uri.encodeComponent(
                          task.clientAddress,
                        );
                        _launchUrl(
                          'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Candidate Info Section
            if (task.candidateName != null) ...[
              Text(
                'Candidate Basics',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.badge, color: AppColors.gold),
                      title: Text(
                        'Candidate Name',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                      subtitle: Text(
                        task.candidateName!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                    ),
                    if (task.candidatePhone != null) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.phone_android,
                          color: AppColors.gold,
                        ),
                        title: Text(
                          'Candidate Phone',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                        subtitle: Text(
                          task.candidatePhone!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.call,
                            color: AppColors.navyBlue,
                          ),
                          onPressed:
                              () => _launchUrl('tel:${task.candidatePhone}'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Actions & Uploads
            Text(
              'Actions & Documents',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: [
                  if (task.status != TaskStatus.completed) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _showUpdateStatusSheet(context, task, state),
                        icon: const Icon(Icons.edit),
                        label: const Text('Update Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyBlue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!task.isContractUploaded &&
                      task.status != TaskStatus.completed)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          EasyLoading.show(status: 'Uploading Document...');
                          await Future.delayed(const Duration(seconds: 1));
                          state.updateTask(
                            task.copyWith(isContractUploaded: true),
                          );
                          EasyLoading.showSuccess('Document Uploaded');
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Signed Contract'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.standardBlue,
                          side: const BorderSide(color: AppColors.standardBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  else if (task.isContractUploaded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: AppColors.successGreen,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Contract Uploaded Successfully',
                            style: TextStyle(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            if (task.paymentAmount != null && task.isPaymentCollected) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: AppColors.successGreen,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Collected',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreen,
                          ),
                        ),
                        Text(
                          '₹${inFmt.format(task.paymentAmount!.toInt())}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
      ),
    );
  }
}
