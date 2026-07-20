import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // Mock settings state
  double _commissionRate = 10.0;
  bool _emailAlerts = true;
  bool _smsAlerts = false;
  bool _paymentReminders = true;
  bool _contractExpiry = true;
  bool _slaBreach = true;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Shell sets the background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your agency preferences, security, and defaults.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildSection(
                  title: 'Business Profile',
                  icon: Icons.business,
                  isDark: isDark,
                  children: [
                    _buildInfoRow('Company Name', 'Verified Maids', isDark),
                    _buildInfoRow('Contact Email', 'admin@verifiedmaids.com', isDark),
                    _buildInfoRow('Support Phone', '+91 98765 43210', isDark),
                    _buildInfoRow('Office Address', '123 Business Park, Mumbai, India', isDark),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSection(
                  title: 'Commission & Fees',
                  icon: Icons.percent,
                  isDark: isDark,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Default Commission Rate',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.white : AppColors.navyBlue,
                                ),
                              ),
                              Text(
                                'Applied to new contracts automatically',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark ? AppColors.grey400 : AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_commissionRate.toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _commissionRate,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      activeColor: AppColors.gold,
                      inactiveColor: isDark ? AppColors.grey700 : AppColors.grey200,
                      onChanged: (val) => setState(() => _commissionRate = val),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSection(
                  title: 'Notification Preferences',
                  icon: Icons.notifications_active_outlined,
                  isDark: isDark,
                  children: [
                    _buildSwitch('Email Alerts', 'Receive daily summary emails', _emailAlerts, (v) => setState(() => _emailAlerts = v), isDark),
                    _buildSwitch('SMS Alerts', 'Instant text messages for urgent issues', _smsAlerts, (v) => setState(() => _smsAlerts = v), isDark),
                    const Divider(height: 24),
                    _buildSwitch('Payment Reminders', 'Notify when invoices are overdue', _paymentReminders, (v) => setState(() => _paymentReminders = v), isDark),
                    _buildSwitch('Contract Expiry', 'Alert 30 days before contract ends', _contractExpiry, (v) => setState(() => _contractExpiry = v), isDark),
                    _buildSwitch('SLA Breach', 'Alert when SLA timeline is missed', _slaBreach, (v) => setState(() => _slaBreach = v), isDark),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSection(
                  title: 'Security',
                  icon: Icons.security,
                  isDark: isDark,
                  children: [
                    _buildSwitch('Two-Factor Authentication', 'Require OTP for admin login', _twoFactorAuth, (v) => setState(() => _twoFactorAuth = v), isDark),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.password, size: 16),
                      label: const Text('Change Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                        foregroundColor: isDark ? AppColors.white : AppColors.navyBlue,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSection(
                  title: 'Data Management',
                  icon: Icons.storage,
                  isDark: isDark,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Export all agency data as CSV for external reporting or backup.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? AppColors.grey400 : AppColors.grey600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Export Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyBlue,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Clear local application cache. This will not delete any permanent data.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? AppColors.grey400 : AppColors.grey600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.cleaning_services, size: 16),
                          label: const Text('Clear Cache'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.criticalRed,
                            side: const BorderSide(color: AppColors.criticalRed),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.grey400 : AppColors.grey500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
          ),
        ],
      ),
    );
  }
}
