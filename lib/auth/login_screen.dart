import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/blocs/auth/auth_event.dart';
import 'package:practice_app/blocs/auth/auth_state.dart';

import '../auth/user_manager.dart';
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

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(_emailController.text, _passwordController.text),
      );
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
            colors:
                isDark
                    ? [
                      const Color(0xFF0A1628),
                      const Color(0xFF0F2847),
                      const Color(0xFF0A1628),
                    ]
                    : [
                      AppColors.navyBlue,
                      AppColors.navyLight,
                      AppColors.navyDark,
                    ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              UserManager().setUser(state.user);
              context.go('/');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Center(
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
                        Image.asset('lib/assets/applogo.png', height: 120),
                        const SizedBox(height: 16),
                        Text(
                          'Premium Domestic Staffing',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: AppColors.white.withValues(alpha: 0.7),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Login Card
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkSurface.withValues(alpha: 0.9)
                                    : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
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
                                    color:
                                        isDark
                                            ? AppColors.white
                                            : AppColors.navyBlue,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Access your dashboard',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.grey500,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.grey500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.gold.withValues(alpha: 0.8),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor:
                                        isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.grey50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.gold,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.grey500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.gold.withValues(alpha: 0.8),
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: AppColors.grey500,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor:
                                        isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.grey50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.gold,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Sign In button
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submitLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.gold,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.navyBlue,
                                              ),
                                            )
                                            : Text(
                                              'Sign In',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
