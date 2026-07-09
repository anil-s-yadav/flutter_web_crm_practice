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
      appBar: AppBar(
        title: Text('Learning Center', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reference Guide & Standard Operating Procedures',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue)
            ),
            const SizedBox(height: 8),
            Text(
              'Use this section to understand standard abbreviations, scripts, and FAQs used across Verified Candidates CRM.',
              style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.grey400 : AppColors.grey600)
            ),
            const SizedBox(height: 32),
            
            // Language Abbreviations
            _buildSectionHeader('Language Abbreviations', Icons.translate, isDark),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildAbbreviationCard('en', 'English', isDark),
                _buildAbbreviationCard('hi', 'Hindi', isDark),
                _buildAbbreviationCard('ma', 'Marathi', isDark),
                _buildAbbreviationCard('gu', 'Gujarati', isDark),
                _buildAbbreviationCard('ta', 'Tamil', isDark),
                _buildAbbreviationCard('te', 'Telugu', isDark),
                _buildAbbreviationCard('pu', 'Punjabi', isDark),
                _buildAbbreviationCard('bn', 'Bengali', isDark),
              ],
            ),
            const SizedBox(height: 32),

            // Education Abbreviations
            _buildSectionHeader('Education Categories', Icons.school, isDark),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildAbbreviationCard('Below 10th', 'Basic literacy', isDark),
                _buildAbbreviationCard('10th Pass', 'Completed SSC', isDark),
                _buildAbbreviationCard('12th Pass', 'Completed HSC', isDark),
                _buildAbbreviationCard('Graduate', 'Completed Degree', isDark),
              ],
            ),
            const SizedBox(height: 32),

            // Sourcing Scripts
            _buildSectionHeader('Standard Scripts (Sourcing)', Icons.record_voice_over, isDark),
            const SizedBox(height: 16),
            _buildScriptCard(
              'Initial Interview (Hindi)',
              'Namaste! Main Verified Candidates se baat kar rahi hoon. Kya aap abhi kaam dhundh rahe hain? Humare paas kaafi requirements hain. Kya aap humare office aakar verification process start kar sakte hain?',
              isDark
            ),
            const SizedBox(height: 12),
            _buildScriptCard(
              'Medical Checkup Reminder',
              'Aapka police aur aadhaar verification complete ho gaya hai. Agla step medical checkup hai. Kripya apna medical clearance certificate jama karein taaki hum aapko jald se jald kaam dila sakein.',
              isDark
            ),
            const SizedBox(height: 32),

            // FAQs
            _buildSectionHeader('Frequently Asked Questions (Internal)', Icons.help_outline, isDark),
            const SizedBox(height: 16),
            _buildFaqCard(
              'When should a candidate be moved to "Ready to Place"?',
              'A candidate should only be moved to "Ready to Place" after their Aadhaar and Police verification are completed. Medical clearance is highly recommended but can be bypassed if the client agrees.',
              isDark
            ),
            const SizedBox(height: 12),
            _buildFaqCard(
              'What happens when a candidate is blacklisted?',
              'When a candidate is blacklisted, they are permanently hidden from client placement views. A permanent note MUST be logged explaining the reason (e.g., theft, absconding, forged documents).',
              isDark
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
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.textPrimaryLight)),
      ],
    );
  }

  Widget _buildAbbreviationCard(String shortForm, String fullForm, bool isDark) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navyBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(shortForm, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
          ),
          const SizedBox(height: 8),
          Text(fullForm, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.grey300 : AppColors.textPrimaryLight)),
        ],
      ),
    );
  }

  Widget _buildScriptCard(String title, String content, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: AppColors.gold, width: 4)),
              ),
              child: Text(content, style: GoogleFonts.poppins(fontSize: 13, fontStyle: FontStyle.italic, color: isDark ? AppColors.grey400 : AppColors.grey700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(String question, String answer, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200)),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.white : AppColors.textPrimaryLight)),
          iconColor: AppColors.navyBlue,
          collapsedIconColor: AppColors.grey500,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(answer, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.grey400 : AppColors.grey600)),
          ],
        ),
      ),
    );
  }
}
