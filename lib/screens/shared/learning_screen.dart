import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final isMobile = context.media.width < 800;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reference Guide & Standard Operating Procedures',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use this section to understand standard abbreviations, scripts, and FAQs used across Verified Maids CRM.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 32),

            Wrap(
              spacing: 32,
              runSpacing: 32,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                // Language Abbreviations
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Language Abbreviations',
                      Icons.translate,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTable(
                      [
                        {'code': 'en', 'name': 'English'},
                        {'code': 'hi', 'name': 'Hindi'},
                        {'code': 'ma', 'name': 'Marathi'},
                        {'code': 'gu', 'name': 'Gujarati'},
                        {'code': 'ta', 'name': 'Tamil'},
                        {'code': 'te', 'name': 'Telugu'},
                        {'code': 'pu', 'name': 'Punjabi'},
                        {'code': 'bn', 'name': 'Bengali'},
                      ],
                      'Code',
                      'Language',
                      isDark,
                    ),
                  ],
                ),

                // Education Abbreviations
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Education Categories',
                      Icons.school,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTable(
                      [
                        {'code': 'Below 10th', 'name': 'Basic literacy'},
                        {'code': '10th Pass', 'name': 'Completed SSC'},
                        {'code': '12th Pass', 'name': 'Completed HSC'},
                        {'code': 'Graduate', 'name': 'Completed Degree'},
                      ],
                      'Category',
                      'Description',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Sourcing Scripts
            _buildSectionHeader(
              'Standard Scripts (Sourcing)',
              Icons.record_voice_over,
              isDark,
            ),
            const SizedBox(height: 16),
            _buildScriptCard(
              'Initial Interview (Hindi)',
              'Namaste! Main Verified Maids se baat kar rahi hoon. Kya aap abhi kaam dhundh rahe hain? Humare paas kaafi requirements hain. Kya aap humare office aakar verification process start kar sakte hain?',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildScriptCard(
              'Medical Checkup Reminder',
              'Aapka police aur aadhaar verification complete ho gaya hai. Agla step medical checkup hai. Kripya apna medical clearance certificate jama karein taaki hum aapko jald se jald kaam dila sakein.',
              isDark,
            ),
            const SizedBox(height: 32),

            // FAQs
            _buildSectionHeader(
              'Frequently Asked Questions (Internal)',
              Icons.help_outline,
              isDark,
            ),
            const SizedBox(height: 16),
            _buildFaqCard(
              'When should a candidate be moved to "Ready to Place"?',
              'A candidate should only be moved to "Ready to Place" after their Aadhaar and Police verification are completed. Medical clearance is highly recommended but can be bypassed if the client agrees.',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildFaqCard(
              'What happens when a candidate is blacklisted?',
              'When a candidate is blacklisted, they are permanently hidden from client placement views. A permanent note MUST be logged explaining the reason (e.g., theft, absconding, forged documents).',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.gold),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTable(
    List<Map<String, String>> items,
    String col1,
    String col2,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          items.map((item) {
            return Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['code']!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color:
                            isDark
                                ? AppColors.grey300
                                : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildScriptCard(String title, String content, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: AppColors.gold, width: 4),
                ),
              ),
              child: Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.grey400 : AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(String question, String answer, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.white : AppColors.textPrimaryLight,
            ),
          ),
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.grey500,
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          children: [
            Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
