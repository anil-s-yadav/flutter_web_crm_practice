import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class CandidatePickerDialog extends StatefulWidget {
  const CandidatePickerDialog({super.key});

  static Future<Map<String, String>?> show(BuildContext context) {
    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => const CandidatePickerDialog(),
    );
  }

  @override
  State<CandidatePickerDialog> createState() => _CandidatePickerDialogState();
}

class _CandidatePickerDialogState extends State<CandidatePickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalAppState>(context);
    final isDark = context.themeRef.brightness == Brightness.dark;

    var availableCandidates = state.candidates
        .where((c) => c.status == CandidateStatus.readyToPlace)
        .toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      availableCandidates = availableCandidates.where((c) {
        return c.fullName.toLowerCase().contains(query) ||
            c.id.toLowerCase().contains(query) ||
            c.phone.contains(query) ||
            (c.altPhone != null && c.altPhone!.contains(query));
      }).toList();
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      title: Text(
        'Select Candidate',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white : AppColors.navyBlue,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.88,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.grey300,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(
                color: isDark ? AppColors.white : AppColors.grey900,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: availableCandidates.isEmpty
                  ? Center(
                      child: Text(
                        'No candidates found.',
                        style: GoogleFonts.poppins(
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 650;
                        if (isWide) {
                          return GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 78,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: availableCandidates.length,
                            itemBuilder: (context, index) {
                              final candidate = availableCandidates[index];
                              return _buildCompactItem(candidate, isDark, context);
                            },
                          );
                        }
                        return ListView.separated(
                          itemCount: availableCandidates.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final candidate = availableCandidates[index];
                            return _buildCompactItem(candidate, isDark, context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactItem(
    CandidateModel candidate,
    bool isDark,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop({
          'id': candidate.id,
          'name': candidate.fullName,
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.navyBlue.withValues(alpha: 0.1),
              child: Text(
                candidate.fullName.isNotEmpty ? candidate.fullName[0] : '?',
                style: const TextStyle(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          candidate.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color:
                                isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          candidate.id,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📞 ${candidate.phone}   •   ₹${candidate.expectedSalary}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.grey300 : AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${candidate.category} • ${candidate.experienceYears}y exp • ${candidate.education}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                  if (candidate.sourcedByName != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_pin, size: 10, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          'Sourced by: ${candidate.sourcedByName} (${candidate.sourcedByPhone ?? 'N/A'})',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
