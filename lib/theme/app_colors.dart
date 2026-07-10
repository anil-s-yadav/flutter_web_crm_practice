import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Colors (Premium Royal Palette) ───
  static const Color navyBlue = Color(0xFF1B3A5C);       // Royal navy — rich but not black
  static const Color gold = Color(0xFFC9A84C);            // True antique gold — warm, not yellow
  static const Color white = Color(0xFFFFFFFF);

  // ─── Brand Variants ───
  static const Color lightGold = Color(0xFFF7F0DC);       // Warm ivory-gold tint
  static const Color darkNavy = Color(0xFF1E3A5A);         // Deep navy for dark mode containers
  static const Color navyLight = Color(0xFF2B5278);        // Mid-tone navy for accents
  static const Color navyDark = Color(0xFF162B42);         // Deep navy background
  static const Color goldLight = Color(0xFFDCC06A);        // Lighter gold for highlights
  static const Color goldDark = Color(0xFFAD8B3A);         // Darker gold for contrast

  // ─── Surface Colors ───
  static const Color surfaceLight = Color(0xFFF5F3EF);    // Warm ivory surface (not cold grey)
  static const Color surfaceDark = Color(0xFF1B2636);      // Deep navy-tinted dark surface
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF24364A);         // Navy-tinted card dark

  // ─── Neutral Palette (Warmer Greys) ───
  static const Color grey50 = Color(0xFFFAF9F7);          // Warm off-white
  static const Color grey100 = Color(0xFFF3F1ED);          // Warm light grey
  static const Color grey200 = Color(0xFFE8E5DF);          // Warm grey border
  static const Color grey300 = Color(0xFFD8D4CC);
  static const Color grey400 = Color(0xFFBDB8AE);
  static const Color grey500 = Color(0xFF9A9589);
  static const Color grey600 = Color(0xFF756F65);
  static const Color grey700 = Color(0xFF524E46);
  static const Color grey800 = Color(0xFF38352F);
  static const Color grey900 = Color(0xFF221F1A);

  // ─── Text Colors ───
  static const Color textPrimaryLight = Color(0xFF1E2A3A);   // Dark navy-ish for readability
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF7F4EF);    // Warm light for dark mode text
  static const Color textSecondaryDark = Color(0xFFC0BAB2);

  // ─── Ticket Priority Colors ───
  static const Color criticalRed = Color(0xFFD93636);
  static const Color urgentAmber = Color(0xFFE89B2D);
  static const Color standardBlue = Color(0xFF4A9FE5);

  // ─── Status Colors ───
  static const Color successGreen = Color(0xFF3DA655);
  static const Color success = Color(0xFF2A9D48);
  static const Color warningOrange = Color(0xFFE88A1A);
  static const Color warning = Color(0xFFEBB430);
  static const Color infoBlue = Color(0xFF3B8FD9);
  static const Color info = Color(0xFF209AB8);
  static const Color errorRed = Color(0xFFD64040);
  static const Color error = Color(0xFFCC3344);

  // ─── Pipeline Stage Colors ───
  static const Color stageInterviewed = Color(0xFF4A9FE5);
  static const Color stageMedicalCheck = Color(0xFF9C5CB4);
  static const Color stagePoliceVerification = Color(0xFFE87040);
  static const Color stageDocuments = Color(0xFF2E9E8F);
  static const Color stageVerified = Color(0xFF55B366);
  static const Color stageCompleted = Color(0xFF3DA655);
  static const Color stagePending = Color(0xFFBDB8AE);

  // ─── Candidate Status Colors ───
  static const Color statusVerified = Color(0xFF3DA655);
  static const Color statusPending = Color(0xFFE89B2D);
  static const Color statusPlaced = Color(0xFF4A9FE5);
  static const Color statusBlacklisted = Color(0xFFD93636);
  static const Color statusInterviewed = Color(0xFF7858B8);
  static const Color statusJobLeft = Color(0xFFE87040);

  // ─── Divider ───
  static const Color dividerLight = Color(0xFFE0DCD4);    // Warm divider
  static const Color dividerDark = Color(0xFF2A3648);      // Navy-tinted dark divider

  // ─── Dark mode surfaces ───
  static const Color darkSurface = Color(0xFF24364A);     // Navy-tinted, not pure grey
  static const Color darkSurfaceVariant = Color(0xFF2F4259); // Slightly lighter navy
}
