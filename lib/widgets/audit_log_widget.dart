import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:practice_app/models/audit_log_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

class AuditLogWidget extends StatelessWidget {
  final List<AuditLogModel> logs;
  final String title;

  const AuditLogWidget({
    super.key,
    required this.logs,
    this.title = 'Audit Log',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm');

    if (logs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 14,
                color: isDark ? AppColors.grey400 : AppColors.grey600
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.grey300 : AppColors.grey700
                )
              ),
            ]
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatter.format(log.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isDark ? AppColors.grey500 : AppColors.grey500
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? AppColors.grey400 : AppColors.grey600
                        ),
                        children: [
                          TextSpan(
                            text: '${log.userName} (${log.userRole.name.toUpperCase()}): ',
                            style: const TextStyle(fontWeight: FontWeight.w600)
                          ),
                          TextSpan(text: log.description),
                        ]
                      )
                    )
                  )
                ]
              );
            }
          )
        ]
      )
    );
  }
}
