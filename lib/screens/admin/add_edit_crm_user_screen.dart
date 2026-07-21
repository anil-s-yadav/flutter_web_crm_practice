import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/models/crm_user_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class AddEditCrmUserScreen extends StatefulWidget {
  final String? userId; // null = add mode

  const AddEditCrmUserScreen({super.key, this.userId});

  @override
  State<AddEditCrmUserScreen> createState() => _AddEditCrmUserScreenState();
}

class _AddEditCrmUserScreenState extends State<AddEditCrmUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.sales;
  bool _isEdit = false;
  CrmUserModel? _existingUser;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _isEdit = true;
      final state = Provider.of<GlobalAppState>(context, listen: false);
      _existingUser = state.crmUsers.firstWhere(
        (u) => u.id == widget.userId,
        orElse: () => throw Exception('User not found'),
      );
      _nameController.text = _existingUser!.name;
      _emailController.text = _existingUser!.email;
      _phoneController.text = _existingUser!.phone;
      _selectedRole = _existingUser!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final state = Provider.of<GlobalAppState>(context, listen: false);

    if (_isEdit) {
      state.updateCrmUser(_existingUser!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
      ));
    } else {
      final newId = 'USR${(state.crmUsers.length + 1).toString().padLeft(3, '0')}';
      state.addCrmUser(CrmUserModel(
        id: newId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        joinedDate: DateTime.now(),
        password: _passwordController.text.trim().isEmpty ? 'password123' : _passwordController.text.trim(),
      ));
    }

    // Show success and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Member updated successfully' : 'New member added'),
        backgroundColor: AppColors.successGreen,
      ),
    );
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/admin/team');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (GoRouter.of(context).canPop()) {
                            context.pop();
                          } else {
                            context.go('/admin/team');
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEdit ? 'Edit Team Member' : 'Add New Team Member',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Text(
                      _isEdit ? 'Update this member\'s information.' : 'Create a new CRM user account and assign them a role.',
                      style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.grey400 : AppColors.grey600),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Personal Info Section ---
                  _buildSectionCard(
                    title: 'Personal Information',
                    icon: Icons.person,
                    isDark: isDark,
                    children: [
                      _buildTextField('Full Name', _nameController, Icons.badge, isDark, validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
                      const SizedBox(height: 20),
                      _buildTextField('Email Address', _emailController, Icons.email, isDark,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v!.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          }),
                      const SizedBox(height: 20),
                      _buildTextField('Phone Number', _phoneController, Icons.phone, isDark,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.trim().isEmpty ? 'Phone is required' : null),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Role & Access Section ---
                  _buildSectionCard(
                    title: 'Role & Access',
                    icon: Icons.security,
                    isDark: isDark,
                    children: [
                      Text('Assign Role', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.white : AppColors.navyBlue)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildRoleChip(UserRole.sales, 'Sales Rep', 'Can manage clients, contracts, invoices', Icons.handshake, AppColors.stageInterviewed, isDark),
                          _buildRoleChip(UserRole.sourcing, 'Sourcing Lead', 'Can add & verify candidates', Icons.person_search, AppColors.stageMedicalCheck, isDark),
                          _buildRoleChip(UserRole.executive, 'Field Executive', 'Can complete tasks, visit clients', Icons.directions_run, AppColors.stageDocuments, isDark),
                          _buildRoleChip(UserRole.admin, 'Admin', 'Full access to everything', Icons.admin_panel_settings, AppColors.gold, isDark),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Password Section (only for new users) ---
                  if (!_isEdit)
                    _buildSectionCard(
                      title: 'Set Password',
                      icon: Icons.lock,
                      isDark: isDark,
                      children: [
                        _buildTextField('Temporary Password', _passwordController, Icons.password, isDark,
                            obscureText: true, hintText: 'Leave empty for default (password123)'),
                        const SizedBox(height: 8),
                        Text(
                          'The user can change this after their first login.',
                          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.grey400 : AppColors.grey500),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // --- Save Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(_isEdit ? Icons.save : Icons.person_add, size: 20),
                      label: Text(_isEdit ? 'Save Changes' : 'Add Member', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required bool isDark, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.grey200),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 22),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? AppColors.white : AppColors.navyBlue)),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isDark, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.grey300 : AppColors.grey700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter $label',
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.grey500 : AppColors.grey400),
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip(UserRole role, String label, String desc, IconData icon, Color color, bool isDark) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.dividerDark : AppColors.grey200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : (isDark ? AppColors.grey400 : AppColors.grey500), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? color : (isDark ? AppColors.white : AppColors.navyBlue))),
                  Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.grey400 : AppColors.grey500)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
