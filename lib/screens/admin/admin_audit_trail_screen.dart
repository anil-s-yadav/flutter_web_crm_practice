import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class AdminAuditTrailScreen extends StatefulWidget {
  const AdminAuditTrailScreen({super.key});

  @override
  State<AdminAuditTrailScreen> createState() => _AdminAuditTrailScreenState();
}

class _AdminAuditTrailScreenState extends State<AdminAuditTrailScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm:ss');

    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredLogs = state.auditLogs.where((l) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return l.userName.toLowerCase().contains(q) ||
             l.targetId.toLowerCase().contains(q) ||
             l.description.toLowerCase().contains(q) ||
             l.actionType.name.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Global Audit Trail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search logs by user, action, target ID, or description...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              )
            )
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: filteredLogs.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.grey200),
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Text(
                          formatter.format(log.timestamp),
                          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.grey400 : AppColors.grey500)
                        )
                      ),
                      Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _actionColor(log.actionType).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text(
                          log.actionType.name.toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _actionColor(log.actionType))
                        )
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.userName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(log.userRole.name, style: GoogleFonts.poppins(color: AppColors.grey500, fontSize: 11)),
                          ]
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.description, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.white : AppColors.navyBlue)),
                            Text('Target ID: ${log.targetId}', style: GoogleFonts.poppins(color: AppColors.grey500, fontSize: 11)),
                          ]
                        )
                      )
                    ]
                  )
                );
              }
            )
          )
        ]
      )
    );
  }

  Color _actionColor(ActionType type) {
    switch (type) {
      case ActionType.create: return AppColors.successGreen;
      case ActionType.update: return AppColors.statusInterviewed;
      case ActionType.delete: return AppColors.criticalRed;
      case ActionType.statusChange: return AppColors.navyBlue;
      case ActionType.paymentLogged: return AppColors.gold;
      case ActionType.contractRenewed: return AppColors.statusVerified;
      case ActionType.slaInitiated: return AppColors.urgentAmber;
      case ActionType.taskCompleted: return AppColors.stageMedicalCheck;
    }
  }
}
