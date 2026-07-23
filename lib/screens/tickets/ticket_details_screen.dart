import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/ticket_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
// We'll mock GlobalAppState retrieval, or assume tickets are generated locally,
// but in a real app it'd come from Provider.of<GlobalAppState>(context).
import 'package:practice_app/providers/global_app_state.dart';
import 'package:provider/provider.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final _resolutionController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = context.media.width < 800;

    TicketModel? ticket = TicketModel(
      id: widget.ticketId,
      title: 'Mock Ticket for ${widget.ticketId}',
      description:
          'This is a detailed description of the mock ticket. The client reported an issue and we need to resolve it as quickly as possible. Please ensure all steps are followed.',
      priority: TicketPriority.urgent,
      status: TicketStatus.inProgress,
      clientId: 'C001',
      clientName: 'Sharma Family',
      assignedTo: 'Support Agent',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      slaDeadline: DateTime.now().add(const Duration(days: 1)),
      candidateId: 'M001',
      candidateName: 'Sunita Devi',
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.id,
                        style: GoogleFonts.poppins(
                          color: AppColors.grey500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _buildPriorityBadge(ticket.priority),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.title,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      _buildInfoItem(
                        'Created At',
                        _dateFormat.format(ticket.createdAt),
                        Icons.calendar_today,
                        isDark,
                      ),
                      if (ticket.slaDeadline != null)
                        _buildInfoItem(
                          'SLA Deadline',
                          _dateFormat.format(ticket.slaDeadline!),
                          Icons.timer,
                          isDark,
                          isWarning: ticket.isSlaBreached,
                        ),
                      _buildInfoItem(
                        'Assigned To',
                        ticket.assignedTo,
                        Icons.person_outline,
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main Content Row (split on desktop)
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: isMobile ? 0 : 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Block
                      _buildSectionCard(
                        title: 'Description',
                        icon: Icons.description,
                        isDark: isDark,
                        child: Text(
                          ticket.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color:
                                isDark ? AppColors.grey300 : AppColors.grey800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Resolution Block
                      _buildSectionCard(
                        title: 'Resolution Notes',
                        icon: Icons.check_circle_outline,
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ticket.resolution != null &&
                                ticket.resolution!.isNotEmpty) ...[
                              Text(
                                ticket.resolution!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  height: 1.6,
                                  color:
                                      isDark
                                          ? AppColors.grey300
                                          : AppColors.grey800,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextField(
                              controller: _resolutionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Add resolution notes...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.grey500,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor:
                                    isDark
                                        ? AppColors.darkSurfaceVariant
                                        : AppColors.grey50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? AppColors.dividerDark
                                            : AppColors.grey300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        isDark
                                            ? AppColors.dividerDark
                                            : AppColors.grey300,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color:
                                    isDark
                                        ? AppColors.white
                                        : AppColors.grey900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Notes updated successfully.',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: AppColors.successGreen,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.save, size: 18),
                                label: const Text('Save Notes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navyBlue,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile) const SizedBox(width: 20),

                // Right Column
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile) const SizedBox(height: 20),

                      // Status Controls
                      _buildSectionCard(
                        title: 'Ticket Status',
                        icon: Icons.flag,
                        isDark: isDark,
                        child: DropdownButtonFormField<TicketStatus>(
                          initialValue: ticket.status,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    isDark
                                        ? AppColors.dividerDark
                                        : AppColors.grey300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color:
                                    isDark
                                        ? AppColors.dividerDark
                                        : AppColors.grey300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          dropdownColor:
                              isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.white,
                          items:
                              TicketStatus.values
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Row(
                                        children: [
                                          _statusIndicator(s),
                                          const SizedBox(width: 10),
                                          Text(
                                            s.displayName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color:
                                                  isDark
                                                      ? AppColors.white
                                                      : AppColors.grey900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Status changed to ${val.displayName}',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: AppColors.successGreen,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Client Details
                      _buildSectionCard(
                        title: 'Related Entities',
                        icon: Icons.link,
                        isDark: isDark,
                        child: Column(
                          children: [
                            _buildEntityTile(
                              title: 'Client',
                              name: ticket.clientName,
                              id: ticket.clientId,
                              icon: Icons.business,
                              isDark: isDark,
                            ),
                            if (ticket.candidateName != null) ...[
                              const Divider(height: 24),
                              _buildEntityTile(
                                title: 'Candidate',
                                name: ticket.candidateName!,
                                id: ticket.candidateId ?? 'N/A',
                                icon: Icons.person,
                                isDark: isDark,
                              ),
                            ],
                            if (ticket.contractId != null) ...[
                              const Divider(height: 24),
                              _buildEntityTile(
                                title: 'Contract',
                                name: ticket.contractId!,
                                id: ticket.contractId!,
                                icon: Icons.description,
                                isDark: isDark,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color bg;
    Color fg;
    switch (priority) {
      case TicketPriority.critical:
        bg = AppColors.criticalRed.withValues(alpha: 0.1);
        fg = AppColors.criticalRed;
        break;
      case TicketPriority.urgent:
        bg = AppColors.gold.withValues(alpha: 0.1);
        fg = AppColors.gold;
        break;
      case TicketPriority.standard:
        bg = AppColors.navyBlue.withValues(alpha: 0.1);
        fg = AppColors.navyBlue;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.displayName.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    bool isWarning = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color:
              isWarning
                  ? AppColors.criticalRed
                  : (isDark ? AppColors.grey400 : AppColors.grey600),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.grey500 : AppColors.grey600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    isWarning
                        ? AppColors.criticalRed
                        : (isDark ? AppColors.white : AppColors.navyBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.navyBlue),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEntityTile({
    required String title,
    required String name,
    required String id,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? AppColors.grey500 : AppColors.grey600,
                ),
              ),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.white : AppColors.navyBlue,
                ),
              ),
              Text(
                id,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? AppColors.grey500 : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusIndicator(TicketStatus status) {
    Color color;
    switch (status) {
      case TicketStatus.open:
        color = AppColors.statusPending;
        break;
      case TicketStatus.inProgress:
        color = AppColors.statusInterviewed;
        break;
      case TicketStatus.resolved:
        color = AppColors.statusVerified;
        break;
      case TicketStatus.closed:
        color = AppColors.grey500;
        break;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
