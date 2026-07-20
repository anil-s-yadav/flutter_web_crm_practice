import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  String _name = '';
  String _phone = '';
  int _age = 25;
  String _city = 'Mumbai';
  String _address = '';
  String _religion = 'Hindu';
  String _education = '10th Pass';

  // Role & Experience
  String _category = CategoryConstants.categories.first;
  final List<String> _languages = ['Hindi'];
  int _experienceYears = 0;

  // Salary
  double _expectedSalary = CategoryConstants.baseSalaries.values.first;

  // Documents
  bool _hasAadhaar = false;
  bool _hasPhoto = false;
  bool _hasPan = false;
  bool _hasPoliceClearance = false;

  void _addCandidate() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final state = Provider.of<GlobalAppState>(context, listen: false);

    // Generate an ID
    final newId =
        'M${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final candidate = CandidateModel(
      id: newId,
      fullName: _name,
      age: _age,
      phone: _phone,
      address: _address,
      city: _city,
      state: 'Maharashtra',
      languages: _languages.isEmpty ? ['Hindi'] : _languages,
      religion: _religion,
      category: _category,
      education: _education,
      experienceYears: _experienceYears,
      expectedSalary:
          '₹${_expectedSalary.toInt()} - ₹${(_expectedSalary * 1.2).toInt()}',
      workingHoursPerDay: _category == 'Driver' ? 12 : 10,
      status: CandidateStatus.newlyAdded,
      isMedicalCleared: false,
      isPoliceVerified: _hasPoliceClearance,
      isAadhaarVerified: _hasAadhaar,
      aadhaarDocUrl: _hasAadhaar ? 'simulated_aadhaar_url.pdf' : null,
      photoUrl: _hasPhoto ? 'simulated_photo_url.jpg' : '',
      addedBy: state.currentUser?.name ?? 'System',
      dateAdded: DateTime.now(),
    );

    state.addCandidate(candidate);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.successGreen,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Candidate Added',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_name has been added to the pool.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? AppColors.grey300 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        context.pop(); // go back
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;
    final languageOptions = [
      'Hindi',
      'Marathi',
      'English',
      'Tamil',
      'Telugu',
      'Gujarati',
      'Bengali',
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey200,
                ),
              ),
              color: isDark ? AppColors.darkSurface : AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Add New Candidate',
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 24,
                      //     fontWeight: FontWeight.bold,
                      //     color: isDark ? AppColors.white : AppColors.navyBlue,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   'Enter the candidate details to add them to the sourcing pool.',
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 14,
                      //     color: isDark ? AppColors.grey400 : AppColors.grey600,
                      //   ),
                      // ),
                      // const SizedBox(height: 32),

                      // --- Personal Info Section ---
                      _buildSectionTitle(
                        'Personal Information',
                        Icons.person_outline,
                        isDark,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Full Name',
                              isDark: isDark,
                              initialValue: _name,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                              onSaved: (v) => _name = v ?? '',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              label: 'Phone Number',
                              isDark: isDark,
                              initialValue: _phone,
                              keyboardType: TextInputType.phone,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                              onSaved: (v) => _phone = v ?? '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Age',
                              isDark: isDark,
                              initialValue: _age.toString(),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (int.tryParse(v) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                              onSaved: (v) => _age = int.parse(v ?? '25'),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Religion',
                              value: _religion,
                              items: const [
                                'Hindu',
                                'Muslim',
                                'Christian',
                                'Sikh',
                                'Other',
                              ],
                              onChanged: (v) => setState(() => _religion = v!),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Address',
                        isDark: isDark,
                        initialValue: _address,
                        maxLines: 2,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                        onSaved: (v) => _address = v ?? '',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'City',
                              value: _city,
                              items: const [
                                'Mumbai',
                                'Pune',
                                'Delhi',
                                'Bangalore',
                              ],
                              onChanged: (v) => setState(() => _city = v!),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Education',
                              value: _education,
                              items: const [
                                'None',
                                '8th Pass',
                                '10th Pass',
                                '12th Pass',
                                'Graduate',
                              ],
                              onChanged: (v) => setState(() => _education = v!),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // --- Role & Experience Section ---
                      _buildSectionTitle(
                        'Role & Experience',
                        Icons.work_outline,
                        isDark,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Job Category',
                              value: _category,
                              items: CategoryConstants.categories,
                              onChanged: (v) {
                                setState(() {
                                  _category = v!;
                                  _expectedSalary =
                                      CategoryConstants
                                          .baseSalaries[_category] ??
                                      15000;
                                });
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              label: 'Experience (Years)',
                              isDark: isDark,
                              initialValue: _experienceYears.toString(),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (int.tryParse(v) == null)
                                  return 'Invalid number';
                                return null;
                              },
                              onSaved:
                                  (v) => _experienceYears = int.parse(v ?? '0'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Languages Spoken',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.grey300 : AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            languageOptions.map((lang) {
                              final isSelected = _languages.contains(lang);
                              return FilterChip(
                                label: Text(lang),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _languages.add(lang);
                                    } else {
                                      _languages.remove(lang);
                                    }
                                  });
                                },
                                backgroundColor:
                                    isDark
                                        ? AppColors.darkSurfaceVariant
                                        : AppColors.grey50,
                                selectedColor: AppColors.gold.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppColors.goldDark,
                                labelStyle: GoogleFonts.poppins(
                                  color:
                                      isSelected
                                          ? (isDark
                                              ? AppColors.gold
                                              : AppColors.goldDark)
                                          : (isDark
                                              ? AppColors.grey400
                                              : AppColors.grey700),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.gold
                                            : (isDark
                                                ? AppColors.dividerDark
                                                : AppColors.grey300),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 48),

                      // --- Salary Expectations Section ---
                      _buildSectionTitle(
                        'Salary Expectations',
                        Icons.attach_money,
                        isDark,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Expected Monthly Salary: ₹${_expectedSalary.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.gold,
                          inactiveTrackColor:
                              isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.grey200,
                          thumbColor: AppColors.gold,
                          overlayColor: AppColors.gold.withValues(alpha: 0.2),
                          valueIndicatorColor: AppColors.navyBlue,
                        ),
                        child: Slider(
                          value: _expectedSalary.clamp(5000, 100000),
                          min: 5000,
                          max: 100000,
                          divisions: 95,
                          label: '₹${_expectedSalary.toInt()}',
                          onChanged: (v) => setState(() => _expectedSalary = v),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // --- Documents Section ---
                      _buildSectionTitle(
                        'Document Status',
                        Icons.folder_open,
                        isDark,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUploadCard(
                              title: 'Aadhaar Card',
                              isUploaded: _hasAadhaar,
                              onUpload:
                                  () => setState(() => _hasAadhaar = true),
                              onRemove:
                                  () => setState(() => _hasAadhaar = false),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildUploadCard(
                              title: 'PAN Card',
                              isUploaded: _hasPan,
                              onUpload: () => setState(() => _hasPan = true),
                              onRemove: () => setState(() => _hasPan = false),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUploadCard(
                              title: 'Passport Photo',
                              isUploaded: _hasPhoto,
                              onUpload: () => setState(() => _hasPhoto = true),
                              onRemove: () => setState(() => _hasPhoto = false),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildUploadCard(
                              title: 'Police Clearance',
                              isUploaded: _hasPoliceClearance,
                              onUpload:
                                  () => setState(
                                    () => _hasPoliceClearance = true,
                                  ),
                              onRemove:
                                  () => setState(
                                    () => _hasPoliceClearance = false,
                                  ),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // --- Save Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _addCandidate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Add Candidate',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.grey400 : AppColors.navyBlue,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.navyBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Divider(
            color: isDark ? AppColors.dividerDark : AppColors.grey200,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required bool isDark,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.grey300 : AppColors.grey700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey300,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.grey300 : AppColors.grey700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.grey300,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark ? AppColors.white : AppColors.navyBlue,
          ),
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool isUploaded,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isUploaded
                  ? AppColors.successGreen
                  : (isDark ? AppColors.dividerDark : AppColors.grey300),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isUploaded
                      ? AppColors.successGreen.withValues(alpha: 0.1)
                      : (isDark ? AppColors.darkSurface : AppColors.white),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUploaded ? Icons.check : Icons.upload_file,
              color:
                  isUploaded
                      ? AppColors.successGreen
                      : (isDark ? AppColors.grey400 : AppColors.navyBlue),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                if (isUploaded)
                  Text(
                    'document_attached.pdf',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.successGreen,
                    ),
                  ),
              ],
            ),
          ),
          if (isUploaded)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.criticalRed,
              onPressed: onRemove,
            )
          else
            TextButton(
              onPressed: onUpload,
              style: TextButton.styleFrom(foregroundColor: AppColors.gold),
              child: const Text('Upload'),
            ),
        ],
      ),
    );
  }
}
