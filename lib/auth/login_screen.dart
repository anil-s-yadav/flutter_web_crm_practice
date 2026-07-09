import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/utils/shared_preferences.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800)
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _quickLogin(UserRole role) async {
    setState(() => _isLoading = true);

    final mockUsers = {
      UserRole.admin: UserModel(
        id: 1,
        name: 'Admin User',
        email: 'admin@verifiedmaids.com',
        role: UserRole.admin
      ),
      UserRole.sales: UserModel(
        id: 2,
        name: 'Sales Manager',
        email: 'sales@verifiedmaids.com',
        role: UserRole.sales
      ),
      UserRole.sourcing: UserModel(
        id: 3,
        name: 'Sourcing Lead',
        email: 'sourcing@verifiedmaids.com',
        role: UserRole.sourcing
      ),
      UserRole.executive: UserModel(
        id: 4,
        name: 'Field Executive',
        email: 'exec@verifiedmaids.com',
        role: UserRole.executive
      ),
    };

    try {
      await LocalStoragePref().setLoginBool(true);
      await UserManager().setUser(mockUsers[role]!);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A1628),
                    const Color(0xFF0F2847),
                    const Color(0xFF0A1628),
                  ]
                : [
                    AppColors.navyBlue,
                    AppColors.navyLight,
                    AppColors.navyDark,
                  ]
          )
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'lib/assets/applogo.png',
                      height: 120,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Premium Domestic Staffing',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: AppColors.white.withValues(alpha: 0.7),
                        letterSpacing: 2
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface.withValues(alpha: 0.9)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10)
                          ),
                        ]
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.navyBlue
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Access your dashboard',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.grey500
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Email / Mobile',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.grey500
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.gold.withValues(alpha: 0.8),
                                  size: 20
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.gold,
                                    width: 1.5
                                  )
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14
                                )
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.grey500
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.gold.withValues(alpha: 0.8),
                                  size: 20
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppColors.grey500
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  }
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.gold,
                                    width: 1.5
                                  )
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14
                                )
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign In button
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.navyBlue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                  )
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.navyBlue
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Quick login section
                    Text(
                      'DEMO ACCESS',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white.withValues(alpha: 0.5),
                        letterSpacing: 3
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick login buttons grid
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildQuickLoginButton(
                          label: 'Admin',
                          icon: Icons.admin_panel_settings,
                          role: UserRole.admin
                        ),
                        _buildQuickLoginButton(
                          label: 'Sales',
                          icon: Icons.point_of_sale,
                          role: UserRole.sales
                        ),
                        _buildQuickLoginButton(
                          label: 'Sourcing',
                          icon: Icons.person_search,
                          role: UserRole.sourcing
                        ),
                        _buildQuickLoginButton(
                          label: 'Executive',
                          icon: Icons.phone_android,
                          role: UserRole.executive
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginButton({
    required String label,
    required IconData icon,
    required UserRole role
  }) {
    return SizedBox(
      width: 150,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : () => _quickLogin(role),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.4)
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12)
        ),
      ),
    );
  }
}
