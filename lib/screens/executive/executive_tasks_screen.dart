import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/models/executive_task_model.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ExecutiveTasksScreen extends StatefulWidget {
  const ExecutiveTasksScreen({super.key});

  @override
  State<ExecutiveTasksScreen> createState() => _ExecutiveTasksScreenState();
}

class _ExecutiveTasksScreenState extends State<ExecutiveTasksScreen> {
  String _selectedFilter = 'Pending';
  final List<String> _filters = ['Pending', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<GlobalAppState>(context);
    final tasks = appState.tasks;

    // Grouping In Progress with Pending
    final filteredTasks =
        tasks.where((t) {
          if (_selectedFilter == 'Pending') {
            return t.status != TaskStatus.completed &&
                t.status != TaskStatus.cancelled;
          } else {
            return t.status == TaskStatus.completed;
          }
        }).toList();

    final isDesktop = context.media.width >= 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            filter,
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
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  filteredTasks.isEmpty
                      ? Center(
                        child: Text(
                          'No tasks found',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(filteredTasks[index], appState);
                        },
                      ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      EasyLoading.showError('Could not launch $urlString');
    }
  }

  Widget _buildTaskCard(ExecutiveTaskModel task, GlobalAppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 0 : 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isDark
                ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
                : BorderSide.none,
      ),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/executive/tasks/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.type.displayName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Client: ${task.clientName}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.clientAddress,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final encodedAddress = Uri.encodeComponent(
                          task.clientAddress,
                        );
                        _launchUrl(
                          'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
                        );
                      },
                      icon: const Icon(
                        Icons.navigation,
                        size: 16,
                        color: AppColors.white,
                      ),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _launchUrl('tel:${task.clientPhone}');
                      },
                      icon: const Icon(
                        Icons.call,
                        size: 16,
                        color: AppColors.white,
                      ),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
