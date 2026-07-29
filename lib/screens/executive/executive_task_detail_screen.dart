import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/task/task_bloc.dart';
import 'package:practice_app/blocs/task/task_event.dart';
import 'package:practice_app/blocs/task/task_state.dart';
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

  void _showReceiptDialog(BuildContext context, ExecutiveTaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.successGreen),
              const SizedBox(width: 8),
              Text(
                'Digital Receipt',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment received successfully.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${task.clientName}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Task ID: ${task.id}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const Divider(),
                    Text(
                      'Amount Paid: ₹${task.paymentAmount?.toStringAsFixed(0) ?? "0"}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                EasyLoading.showSuccess('Receipt sent via WhatsApp');
              },
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Share Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showActionDialog(BuildContext context, ExecutiveTaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                task.type == TaskType.candidateDrop
                    ? 'Deployment Checklist'
                    : 'Update Task Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (task.type == TaskType.candidateDrop) ...[
                ListTile(
                  leading: const Icon(
                    Icons.person_pin_circle,
                    color: AppColors.navyBlue,
                  ),
                  title: const Text('Mark Staff as Dropped'),
                  subtitle: Text(
                    task.status == TaskStatus.completed
                        ? 'Completed'
                        : 'Pending',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  trailing:
                      task.status == TaskStatus.completed
                          ? const Icon(
                            Icons.check_circle,
                            color: AppColors.successGreen,
                          )
                          : null,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<TaskBloc>().add(
                      UpdateTask(task.copyWith(status: TaskStatus.completed)),
                    );
                    EasyLoading.showSuccess('Staff Dropped Successfully');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.document_scanner,
                    color: AppColors.gold,
                  ),
                  title: const Text('Upload Signed Contract'),
                  subtitle: Text(
                    task.isContractUploaded ? 'Uploaded' : 'Pending',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  trailing:
                      task.isContractUploaded
                          ? const Icon(
                            Icons.check_circle,
                            color: AppColors.successGreen,
                          )
                          : null,
                  onTap: () async {
                    Navigator.pop(context);
                    EasyLoading.show(status: 'Uploading...');
                    await Future.delayed(const Duration(seconds: 1));
                    if (!context.mounted) return;
                    context.read<TaskBloc>().add(
                      UpdateTask(task.copyWith(isContractUploaded: true)),
                    );
                    EasyLoading.showSuccess('Contract Uploaded');
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                  ),
                  title: const Text('Mark as Completed'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<TaskBloc>().add(
                      UpdateTask(task.copyWith(status: TaskStatus.completed)),
                    );
                    EasyLoading.showSuccess('Task Completed');
                  },
                ),
              ],

              ListTile(
                leading: const Icon(
                  Icons.payments,
                  color: AppColors.statusPlaced,
                ),
                title: const Text('Log Payment & Issue Receipt'),
                subtitle: Text(
                  task.isPaymentCollected ? 'Collected' : 'Pending',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing:
                    task.isPaymentCollected
                        ? const Icon(
                          Icons.check_circle,
                          color: AppColors.successGreen,
                        )
                        : null,
                onTap: () {
                  Navigator.pop(context);
                  if (!task.isPaymentCollected) {
                    context.read<TaskBloc>().add(
                      UpdateTask(task.copyWith(isPaymentCollected: true)),
                    );
                    EasyLoading.showSuccess('Payment Collected');
                  }
                  // Show receipt dialog
                  _showReceiptDialog(context, task);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inFmt = NumberFormat('#,##,###', 'en_IN');

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, taskState) {
        if (taskState is TaskInitial || taskState is TaskLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (taskState is TaskError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${taskState.message}')),
          );
        }

        final tasks = (taskState as TaskLoaded).tasks;
        final taskIndex = tasks.indexWhere((t) => t.id == taskId);

        if (taskIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Not Found')),
            body: const Center(
              child: Text('The requested task does not exist.'),
            ),
          );
        }
        final task = tasks[taskIndex];

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.surfaceLight,
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
                              color:
                                  isDark ? AppColors.white : AppColors.navyBlue,
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
                            leading: const Icon(
                              Icons.person,
                              color: AppColors.gold,
                            ),
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
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.phone,
                              color: AppColors.gold,
                            ),
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
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: AppColors.navyBlue,
                              ),
                              onPressed:
                                  () => _launchUrl('tel:${task.clientPhone}'),
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
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.navyBlue,
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
                              leading: const Icon(
                                Icons.badge,
                                color: AppColors.gold,
                              ),
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
                                  color:
                                      isDark
                                          ? AppColors.white
                                          : AppColors.navyBlue,
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
                                        isDark
                                            ? AppColors.white
                                            : AppColors.navyBlue,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.call,
                                    color: AppColors.navyBlue,
                                  ),
                                  onPressed:
                                      () => _launchUrl(
                                        'tel:${task.candidatePhone}',
                                      ),
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
                                    () => _showActionDialog(context, task),
                                icon: const Icon(Icons.edit),
                                label: const Text('Update Status'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navyBlue,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                                  EasyLoading.show(
                                    status: 'Uploading Document...',
                                  );
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  if (!context.mounted) return;
                                  context.read<TaskBloc>().add(
                                    UpdateTask(
                                      task.copyWith(isContractUploaded: true),
                                    ),
                                  );
                                  EasyLoading.showSuccess('Document Uploaded');
                                },
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload Signed Contract'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.standardBlue,
                                  side: const BorderSide(
                                    color: AppColors.standardBlue,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            )
                          else if (task.isContractUploaded)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen.withValues(
                                  alpha: 0.1,
                                ),
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

                    if (task.paymentAmount != null &&
                        task.isPaymentCollected) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.successGreen.withValues(
                              alpha: 0.3,
                            ),
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
                                        isDark
                                            ? AppColors.white
                                            : AppColors.navyBlue,
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
      },
    );
  }
}
