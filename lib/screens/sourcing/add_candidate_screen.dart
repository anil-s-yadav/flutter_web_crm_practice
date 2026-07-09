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
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Step 1: Personal Info
  String _name = '';
  String _phone = '';
  int _age = 25;
  String _city = 'Mumbai';
  String _address = '';
  String _religion = 'Hindu';
  String _education = '10th Pass';

  // Step 2: Role & Experience
  String _category = CategoryConstants.categories.first;
  final List<String> _languages = ['Hindi'];
  int _experienceYears = 0;

  // Step 3: Salary
  double _expectedSalary = CategoryConstants.baseSalaries.values.first;

  // Step 4: Documents (Simulated)
  bool _hasAadhaar = false;
  bool _hasPhoto = false;

  void _addCandidate() {
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
      isPoliceVerified: false,
      isAadhaarVerified: false,
      aadhaarDocUrl: _hasAadhaar ? 'simulated_aadhaar_url.pdf' : null,
      photoUrl: _hasPhoto ? 'simulated_photo_url.jpg' : '',
      addedBy: state.currentUser?.name ?? 'System',
      dateAdded: DateTime.now(),
    );

    state.addCandidate(candidate);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Candidate $_name added successfully!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeRef.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Candidate',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      ),
      body: Stepper(
        type:
            context.media.width > 600
                ? StepperType.horizontal
                : StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          bool isValid = true;
          if (_currentStep == 0) {
            isValid = _formKey1.currentState?.validate() ?? false;
            if (isValid) _formKey1.currentState?.save();
          } else if (_currentStep == 1) {
            isValid = _formKey3.currentState?.validate() ?? false;
            if (isValid) _formKey3.currentState?.save();
          }

          if (isValid) {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _addCandidate();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _currentStep == 2 ? 'Save Candidate' : 'Continue',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(
                      'Back',
                      style: GoogleFonts.poppins(color: AppColors.grey500),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [_buildStep1(isDark), _buildStep2(isDark), _buildStep3(isDark)],
      ),
    );
  }

  Step _buildStep1(bool isDark) {
    return Step(
      title: const Text('Personal Details'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKey1,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.length < 10 ? 'Invalid phone' : null,
                    onSaved: (v) => _phone = v!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _age.toString(),
                    validator:
                        (v) => int.tryParse(v!) == null ? 'Invalid' : null,
                    onSaved: (v) => _age = int.parse(v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              initialValue: _city,
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _city = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => _address = v!,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Religion',
                border: OutlineInputBorder(),
              ),
              initialValue: _religion,
              items:
                  ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Other'].map((
                    String val,
                  ) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
              onChanged: (val) => setState(() => _religion = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Education',
                border: OutlineInputBorder(),
              ),
              initialValue: _education,
              items:
                  ['Below 10th', '10th Pass', '12th Pass', 'Graduate'].map((
                    String val,
                  ) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
              onChanged: (val) => setState(() => _education = val!),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep2(bool isDark) {
    final languageOptions = [
      'Hindi',
      'Marathi',
      'English',
      'Tamil',
      'Telugu',
      'Gujarati',
      'Bengali',
    ];

    return Step(
      title: const Text('Role & Experience'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Service Category',
                border: OutlineInputBorder(),
              ),
              initialValue: _category,
              items:
                  CategoryConstants.categories.map((String val) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _category = val!;
                  _expectedSalary =
                      CategoryConstants.baseSalaries[_category] ?? 10000;
                });
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Years of Experience',
                border: OutlineInputBorder(),
                suffixText: 'Years',
              ),
              keyboardType: TextInputType.number,
              initialValue: _experienceYears.toString(),
              validator: (v) => int.tryParse(v!) == null ? 'Invalid' : null,
              onSaved: (v) => _experienceYears = int.parse(v!),
            ),
            const SizedBox(height: 24),
            Text(
              'Languages Spoken',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                      selectedColor: AppColors.gold.withValues(alpha: 0.3),
                      checkmarkColor: AppColors.navyBlue,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _languages.add(lang);
                          } else {
                            _languages.remove(lang);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep3(bool isDark) {
    return Step(
      title: const Text('Salary & Docs'),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expected Salary (Monthly)',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Base salary for $_category typically starts at ₹${CategoryConstants.baseSalaries[_category]?.toInt() ?? ""}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Salary (₹)',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
            keyboardType: TextInputType.number,
            initialValue: _expectedSalary.toInt().toString(),
            onChanged:
                (v) => setState(
                  () => _expectedSalary = double.tryParse(v) ?? _expectedSalary,
                ),
          ),
          const SizedBox(height: 32),
          Text(
            'Initial Documents (Optional)',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildSimulatedUploadBox(
            'Aadhaar Card',
            _hasAadhaar,
            (val) => setState(() => _hasAadhaar = val),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildSimulatedUploadBox(
            'Profile Photo',
            _hasPhoto,
            (val) => setState(() => _hasPhoto = val),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedUploadBox(
    String label,
    bool isUploaded,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isUploaded
                ? AppColors.successGreen.withValues(alpha: 0.1)
                : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isUploaded
                  ? AppColors.successGreen
                  : (isDark ? AppColors.dividerDark : AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            color: isUploaded ? AppColors.successGreen : AppColors.grey500,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          if (!isUploaded)
            ElevatedButton(
              onPressed: () => onChanged(true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Simulate Upload'),
            )
          else
            TextButton(
              onPressed: () => onChanged(false),
              child: const Text(
                'Remove',
                style: TextStyle(color: AppColors.criticalRed),
              ),
            ),
        ],
      ),
    );
  }
}
