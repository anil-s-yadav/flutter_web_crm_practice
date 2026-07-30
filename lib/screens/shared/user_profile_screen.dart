import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/theme/theme_provider.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Profile controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;

  // Password controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSavingProfile = false;
  bool _isChangingPassword = false;

  // Preference Toggles
  bool _emailNotifs = true;
  bool _inAppSound = true;
  bool _ticketAlerts = true;
  String _notificationStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final user = UserManager().currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _altPhoneController =
        TextEditingController(text: user?.alternatePhone ?? '');

    _checkNotificationPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (mounted) {
        setState(() {
          switch (settings.authorizationStatus) {
            case AuthorizationStatus.authorized:
              _notificationStatus = 'Granted (Push Active)';
              break;
            case AuthorizationStatus.provisional:
              _notificationStatus = 'Provisional';
              break;
            case AuthorizationStatus.denied:
              _notificationStatus = 'Denied';
              break;
            case AuthorizationStatus.notDetermined:
              _notificationStatus = 'Not Requested Yet';
              break;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _notificationStatus = 'Standard Web Notifications Active';
        });
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await _checkNotificationPermission();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification Permission: ${settings.authorizationStatus.name.toUpperCase()}',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request permission: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _saveProfileDetails() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isSavingProfile = true);

    try {
      final currentUser = UserManager().currentUser;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          alternatePhone: _altPhoneController.text.trim(),
        );

        await UserManager().setUser(updatedUser);
      }

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile details updated successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isChangingPassword = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _isChangingPassword = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Confirm Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: const Text(
              'Are you sure you want to sign out of your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: AppColors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await UserManager().clearUser();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = UserManager().currentUser;
    final roleName = user?.role.displayName ?? 'User';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.media.width > 800 ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile Card
                _buildHeaderCard(context, user, roleName, isDark),
                const SizedBox(height: 24),

                // Navigation Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2232) : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isDark ? const Color(0xFF2D374D) : AppColors.grey200,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: isDark ? AppColors.navyBlue : AppColors.navyBlue,
                    unselectedLabelColor:
                        isDark ? AppColors.grey400 : AppColors.grey600,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.person_outline, size: 18),
                        text: 'Personal Details',
                      ),
                      Tab(
                        icon: Icon(Icons.shield_outlined, size: 18),
                        text: 'Security & Password',
                      ),
                      Tab(
                        icon: Icon(Icons.tune_outlined, size: 18),
                        text: 'Preferences & Notifs',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tab Content Body
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    switch (_tabController.index) {
                      case 0:
                        return _buildPersonalDetailsTab(isDark);
                      case 1:
                        return _buildSecurityTab(user, isDark);
                      case 2:
                        return _buildPreferencesTab(isDark);
                      default:
                        return _buildPersonalDetailsTab(isDark);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    UserModel? user,
    String roleName,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3A52) : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark ? const Color(0xFF1E2638) : AppColors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 13,
                    color: AppColors.navyBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Basic Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user?.name ?? 'User Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        roleName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'no-email@verifiedmaids.in',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Active Session • Verified Account',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Logout Button
          if (context.media.width > 600)
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: BorderSide(
                  color: AppColors.errorRed.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsTab(bool isDark) {
    final user = UserManager().currentUser;
    final isDesktop = context.media.width > 700;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3A52) : AppColors.grey200,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account & Contact Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Update your personal profile information and contact phone numbers.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 28),

            // Name & Email
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCleanTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                      isDark: isDark,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Name required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildCleanTextField(
                      label: 'Email Address (Read-Only)',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      readOnly: true,
                      suffixIcon: Icons.lock_outline,
                    ),
                  ),
                ],
              )
            else ...[
              _buildCleanTextField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline,
                isDark: isDark,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Name required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildCleanTextField(
                label: 'Email Address (Read-Only)',
                controller: _emailController,
                icon: Icons.email_outlined,
                isDark: isDark,
                readOnly: true,
                suffixIcon: Icons.lock_outline,
              ),
            ],
            const SizedBox(height: 20),

            // Phone & Alt Phone
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCleanTextField(
                      label: 'Primary Phone Number',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      hint: 'e.g. +91 98765 43210',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildCleanTextField(
                      label: 'Alternate Phone Number',
                      controller: _altPhoneController,
                      icon: Icons.phone_android_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      hint: 'e.g. +91 98765 43211',
                    ),
                  ),
                ],
              )
            else ...[
              _buildCleanTextField(
                label: 'Primary Phone Number',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
                hint: 'e.g. +91 98765 43210',
              ),
              const SizedBox(height: 16),
              _buildCleanTextField(
                label: 'Alternate Phone Number',
                controller: _altPhoneController,
                icon: Icons.phone_android_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
                hint: 'e.g. +91 98765 43211',
              ),
            ],
            const SizedBox(height: 24),

            // User ID Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141A28)
                    : AppColors.grey50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A3448) : AppColors.grey200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Account ID',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.grey400
                                : AppColors.grey600,
                          ),
                        ),
                        Text(
                          user?.id ?? 'U_0000',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.white
                                : AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    color: isDark ? AppColors.grey300 : AppColors.grey600,
                    tooltip: 'Copy User ID',
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: user?.id ?? ''),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User ID copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Save Action
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isSavingProfile ? null : _saveProfileDetails,
                icon: _isSavingProfile
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.navyBlue,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_isSavingProfile ? 'Saving...' : 'Save Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab(UserModel? user, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3A52) : AppColors.grey200,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security & Password',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your password and active security sessions.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 28),

            _buildCleanTextField(
              label: 'Current Password',
              controller: _currentPasswordController,
              icon: Icons.lock_outline,
              isDark: isDark,
              obscureText: _obscureCurrent,
              suffixWidget: IconButton(
                icon: Icon(
                  _obscureCurrent
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.grey400,
                ),
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter current password' : null,
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCleanTextField(
                    label: 'New Password',
                    controller: _newPasswordController,
                    icon: Icons.key_outlined,
                    isDark: isDark,
                    obscureText: _obscureNew,
                    suffixWidget: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.grey400,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    validator: (val) => val == null || val.length < 6
                        ? 'Min 6 characters'
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCleanTextField(
                    label: 'Confirm New Password',
                    controller: _confirmPasswordController,
                    icon: Icons.key_outlined,
                    isDark: isDark,
                    obscureText: _obscureConfirm,
                    suffixWidget: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.grey400,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (val) => val != _newPasswordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isChangingPassword ? null : _changePassword,
                icon: _isChangingPassword
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.security, size: 18),
                label: Text(
                  _isChangingPassword ? 'Updating...' : 'Update Password',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesTab(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3A52) : AppColors.grey200,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences & Notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Customize application theme and notification preferences.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 28),

          // Push Notification Permission Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.gold,
                  size: 26,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      Text(
                        'Permission Status: $_notificationStatus',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _requestNotificationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Request Permission'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dark Theme Toggle
          _buildPreferenceTile(
            title: 'Dark Theme Mode',
            subtitle: 'Enable sleek dark theme interface for night use',
            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            isDark: isDark,
            value: themeProvider.isDarkMode(context),
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
          Divider(color: isDark ? const Color(0xFF2E3A52) : AppColors.grey200),

          // Email Notifs
          _buildPreferenceTile(
            title: 'Email Summary Digest',
            subtitle: 'Receive daily digest of inquiries and replacements',
            icon: Icons.email_outlined,
            isDark: isDark,
            value: _emailNotifs,
            onChanged: (val) => setState(() => _emailNotifs = val),
          ),
          Divider(color: isDark ? const Color(0xFF2E3A52) : AppColors.grey200),

          // Sound Alerts
          _buildPreferenceTile(
            title: 'In-App Sound Chimes',
            subtitle: 'Play audio notification for high priority ticket alerts',
            icon: Icons.volume_up_outlined,
            isDark: isDark,
            value: _inAppSound,
            onChanged: (val) => setState(() => _inAppSound = val),
          ),
          Divider(color: isDark ? const Color(0xFF2E3A52) : AppColors.grey200),

          // Ticket Alerts
          _buildPreferenceTile(
            title: 'Urgent Request Popups',
            subtitle: 'Show floating notification badges for instant updates',
            icon: Icons.notifications_none_outlined,
            isDark: isDark,
            value: _ticketAlerts,
            onChanged: (val) => setState(() => _ticketAlerts = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    bool readOnly = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? hint,
    IconData? suffixIcon,
    Widget? suffixWidget,
    String? Function(String?)? validator,
  }) {
    final bgColor = readOnly
        ? (isDark ? const Color(0xFF141A28) : AppColors.grey100)
        : (isDark ? const Color(0xFF141A28) : AppColors.grey50);
    final borderColor = isDark ? const Color(0xFF2A3448) : AppColors.grey300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: readOnly
                    ? AppColors.gold
                    : (isDark ? AppColors.grey300 : AppColors.grey700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: readOnly
                ? (isDark ? AppColors.grey400 : AppColors.grey600)
                : (isDark ? AppColors.white : AppColors.navyBlue),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.grey500 : AppColors.grey400,
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: readOnly
                  ? (isDark ? AppColors.grey500 : AppColors.grey400)
                  : AppColors.gold,
            ),
            suffixIcon: suffixWidget ??
                (suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        size: 18,
                        color: AppColors.grey400,
                      )
                    : null),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
