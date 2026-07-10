import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/auth/user_manager.dart';

class ExecutiveProfileScreen extends StatelessWidget {
  const ExecutiveProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = UserManager().currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceLight,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Executive',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Executive Officer',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color:
                    isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
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
                    leading: const Icon(
                      Icons.email_outlined,
                      color: AppColors.gold,
                    ),
                    title: Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    subtitle: Text(
                      user?.email ?? 'vikram@verifiedmaids.in',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.phone_outlined,
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
                      user?.phone ?? '+91 98765 43210',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.gold,
                    ),
                    title: Text(
                      'Assigned Zone',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    subtitle: Text(
                      'Mumbai West',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  UserManager().clearUser();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
