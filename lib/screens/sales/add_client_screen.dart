import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/core/service_constants.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/blocs/auth/auth_state.dart';
import 'package:practice_app/blocs/client/client_bloc.dart';
import 'package:practice_app/blocs/client/client_event.dart';
import 'package:practice_app/repositories/client_repository.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Step 1: Personal Info
  String _fullName = '';
  String _phone = '';
  String _altPhone = '';
  String _email = '';
  String _locality = '';
  String _city = 'Mumbai';
  String _address = '';
  String _source = ServiceConstants.leadSources.first;

  // Step 2: Household Details
  String _houseType = '2BHK';
  int _familySize = 3;
  bool _hasPets = false;
  String _petDetails = '';
  bool _hasElderly = false;
  bool _hasChildren = false;
  int _childrenCount = 1;

  // Step 3: Service Requirements
  String _preferredCategory = CategoryConstants.categories.first;
  String _serviceType = ServiceConstants.serviceTypes.first;
  String _workTimings = ServiceConstants.workTimingPresets.first;
  double _budgetBase = 15000;
  double _budgetEnd = 25000;
  String _foodPreference = ServiceConstants.foodPreferences.first;
  String _genderPreference = ServiceConstants.genderPreferences.first;
  final List<String> _preferredLanguages = ['Hindi'];
  String _religionPreference = ServiceConstants.religionPreferences.first;
  String _expectedJoining = ServiceConstants.expectedJoiningOptions.first;
  String _contractDuration = ServiceConstants.contractDurations.last;
  String _remarks = '';

  final List<String> _houseTypes = [
    '1BHK',
    '2BHK',
    '3BHK',
    '4BHK',
    'Villa',
    'Bungalow',
    'Penthouse',
    'Duplex',
  ];

  Future<void> _addClient() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final authState = context.read<AuthBloc>().state;
      final currentUser = authState is AuthAuthenticated ? authState.user : null;

      final client = ClientModel(
        id: '',
        fullName: _fullName,
        phone: _phone,
        altPhone: _altPhone.isEmpty ? null : _altPhone,
        email: _email.isEmpty ? '$_phone@placeholder.com' : _email,
        address: _address,
        city: _city,
        locality: _locality,
        houseType: _houseType,
        familySize: _familySize,
        hasPets: _hasPets,
        petDetails: _hasPets ? _petDetails : null,
        hasElderlyMembers: _hasElderly,
        hasChildren: _hasChildren,
        childrenCount: _hasChildren ? _childrenCount : null,
        preferredCandidateCategory: _preferredCategory,
        requiredSkills: const ['Standard Duty'],
        budgetRange: '₹${_budgetBase.toInt()} - ₹${_budgetEnd.toInt()}',
        status: ClientStatus.followUp,
        assignedEmployeeId: currentUser?.id ?? 'VMU0002',
        assignedEmployeeName: currentUser?.name,
        source: _source,
        inquiryDate: DateTime.now(),
        remarks: _remarks.isNotEmpty ? _remarks : null,
        serviceType: _serviceType,
        workTimings: _workTimings,
        foodPreference: _foodPreference,
        genderPreference: _genderPreference,
        preferredLanguages: _preferredLanguages.isEmpty ? const ['Hindi'] : _preferredLanguages,
        religionPreference: _religionPreference,
        expectedJoining: _expectedJoining,
        contractDuration: _contractDuration,
      );

      await context.read<ClientRepository>().createClient(client);
      if (!mounted) return;
      context.read<ClientBloc>().add(const LoadClients());
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save client: $errorMsg',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
                      Icons.check_circle,
                      color: AppColors.successGreen,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Client Added!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_fullName has been added as a new inquiry.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop(); // close dialog
                        context.go('/sales/clients'); // route to leads list
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Leads Directory',
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
    final isMobile = context.media.width < 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Stepper(
            type: isMobile ? StepperType.vertical : StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep == 0) {
                if (_formKey1.currentState!.validate()) {
                  _formKey1.currentState!.save();
                  setState(() => _currentStep += 1);
                }
              } else if (_currentStep == 1) {
                if (_formKey2.currentState!.validate()) {
                  _formKey2.currentState!.save();
                  setState(() => _currentStep += 1);
                }
              } else if (_currentStep == 2) {
                if (_formKey3.currentState!.validate()) {
                  _formKey3.currentState!.save();
                  _addClient();
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                context.pop();
              }
            },
            controlsBuilder: (context, details) {
              final isLast = _currentStep == 2;
              return Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLast ? AppColors.successGreen : AppColors.gold,
                          foregroundColor:
                              isLast ? AppColors.white : AppColors.navyBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(isLast ? 'Save Client' : 'Continue'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color:
                                isDark
                                    ? AppColors.dividerDark
                                    : AppColors.grey300,
                          ),
                        ),
                        child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Basic Info'),
                isActive: _currentStep >= 0,
                state:
                    _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Form(
                  key: _formKey1,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        isDark: isDark,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                        onSaved: (v) => _fullName = v!,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        isDark: isDark,
                        validator:
                            (v) =>
                                v == null || v.length != 10
                                    ? 'Enter exactly 10 digits'
                                    : null,
                        onSaved: (v) => _phone = v!,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Alternate Phone (Optional)',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        isDark: isDark,
                        validator: (v) {
                           if (v != null && v.isNotEmpty && v.length != 10) {
                              return 'Enter exactly 10 digits';
                           }
                           return null;
                        },
                        onSaved: (v) => _altPhone = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Email (Optional)',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(v)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (v) => _email = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Locality (e.g. Bandra)',
                              icon: Icons.location_city_outlined,
                              isDark: isDark,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                              onSaved: (v) => _locality = v!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'City',
                              initialValue: _city,
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                              onSaved: (v) => _city = v ?? 'Mumbai',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Full Address',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                        isDark: isDark,
                        onSaved: (v) => _address = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        label: 'Lead Source',
                        value: _source,
                        items: ServiceConstants.leadSources,
                        onChanged: (v) => setState(() => _source = v ?? ServiceConstants.leadSources.first),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('Household Details'),
                isActive: _currentStep >= 1,
                state:
                    _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'House Type',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _houseTypes.map((t) {
                              final selected = _houseType == t;
                              return ChoiceChip(
                                label: Text(t),
                                selected: selected,
                                onSelected: (val) {
                                  if (val) setState(() => _houseType = t);
                                },
                                selectedColor: AppColors.navyBlue,
                                labelStyle: TextStyle(
                                  color:
                                      selected
                                          ? AppColors.white
                                          : (isDark
                                              ? AppColors.white
                                              : AppColors.navyBlue),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Family Size',
                              value: _familySize,
                              items: [1, 2, 3, 4, 5, 6, 7, 8],
                              onChanged:
                                  (v) => setState(() => _familySize = v!),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CheckboxListTile(
                        title: const Text('Has Pets'),
                        value: _hasPets,
                        onChanged: (v) => setState(() => _hasPets = v!),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_hasPets)
                        _buildTextField(
                          label: 'Pet Details (e.g. 1 Dog, 2 Cats)',
                          icon: Icons.pets,
                          isDark: isDark,
                          onSaved: (v) => _petDetails = v ?? '',
                        ),
                      CheckboxListTile(
                        title: const Text('Has Elderly Members'),
                        value: _hasElderly,
                        onChanged: (v) => setState(() => _hasElderly = v!),
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Has Children'),
                        value: _hasChildren,
                        onChanged: (v) => setState(() => _hasChildren = v!),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_hasChildren)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                          child: Row(
                            children: [
                              const Text('Number of Children: '),
                              const SizedBox(width: 16),
                              DropdownButton<int>(
                                value: _childrenCount,
                                items:
                                    [1, 2, 3, 4, 5]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text('$e'),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) => setState(() => _childrenCount = v!),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('Requirements'),
                isActive: _currentStep >= 2,
                content: Form(
                  key: _formKey3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Looking For (Category)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            CategoryConstants.categories.map((c) {
                              final selected = _preferredCategory == c;
                              return ChoiceChip(
                                label: Text(c),
                                selected: selected,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() => _preferredCategory = c);
                                  }
                                },
                                selectedColor: AppColors.navyBlue,
                                labelStyle: TextStyle(
                                  color:
                                      selected
                                          ? AppColors.white
                                          : (isDark
                                              ? AppColors.white
                                              : AppColors.navyBlue),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Service Type',
                              value: _serviceType,
                              items: ServiceConstants.serviceTypes,
                              onChanged: (v) => setState(() => _serviceType = v ?? ServiceConstants.serviceTypes.first),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Work Timings',
                              value: _workTimings,
                              items: ServiceConstants.workTimingPresets,
                              onChanged: (v) => setState(() => _workTimings = v ?? ServiceConstants.workTimingPresets.first),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Expected Joining',
                              value: _expectedJoining,
                              items: ServiceConstants.expectedJoiningOptions,
                              onChanged: (v) => setState(() => _expectedJoining = v ?? ServiceConstants.expectedJoiningOptions.first),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Contract Duration',
                              value: _contractDuration,
                              items: ServiceConstants.contractDurations,
                              onChanged: (v) => setState(() => _contractDuration = v ?? ServiceConstants.contractDurations.last),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget Range',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.grey300 : AppColors.grey700,
                              ),
                            ),
                            Text(
                              '₹${_budgetBase.toInt()} – ₹${_budgetEnd.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.gold,
                          inactiveTrackColor:
                              isDark
                                  ? const Color(0xFF2A3448)
                                  : AppColors.grey200,
                          thumbColor: AppColors.gold,
                          overlayColor: AppColors.gold.withValues(alpha: 0.2),
                          valueIndicatorColor: AppColors.navyBlue,
                          valueIndicatorTextStyle: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          showValueIndicator: ShowValueIndicator.onDrag,
                          rangeThumbShape:
                              const RoundRangeSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                        ),
                        child: RangeSlider(
                          values: RangeValues(_budgetBase, _budgetEnd),
                          min: 5000,
                          max: 100000,
                          divisions: 95, // Steps of 1000
                          labels: RangeLabels(
                            '₹${_budgetBase.toInt()}',
                            '₹${_budgetEnd.toInt()}',
                          ),
                          activeColor: AppColors.gold,
                          inactiveColor:
                              isDark ? AppColors.dividerDark : AppColors.grey200,
                          onChanged: (RangeValues values) {
                            setState(() {
                              _budgetBase = values.start;
                              _budgetEnd = values.end;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Min: ₹5,000',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? AppColors.grey400 : AppColors.grey600,
                              ),
                            ),
                            Text(
                              'Max: ₹1,00,000',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? AppColors.grey400 : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Food Preference',
                              value: _foodPreference,
                              items: ServiceConstants.foodPreferences,
                              onChanged: (v) => setState(() => _foodPreference = v ?? ServiceConstants.foodPreferences.first),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Gender Preference',
                              value: _genderPreference,
                              items: ServiceConstants.genderPreferences,
                              onChanged: (v) => setState(() => _genderPreference = v ?? ServiceConstants.genderPreferences.first),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Preferred Language(s)',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.grey300 : AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ServiceConstants.commonLanguages.map((lang) {
                          final selected = _preferredLanguages.contains(lang);
                          return FilterChip(
                            label: Text(lang),
                            selected: selected,
                            selectedColor: AppColors.gold.withValues(alpha: 0.3),
                            checkmarkColor: AppColors.navyBlue,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _preferredLanguages.add(lang);
                                } else {
                                  _preferredLanguages.remove(lang);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Religion Preference',
                              value: _religionPreference,
                              items: ServiceConstants.religionPreferences,
                              onChanged: (v) => setState(() => _religionPreference = v ?? ServiceConstants.religionPreferences.first),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Expected Joining',
                              value: _expectedJoining,
                              items: ServiceConstants.expectedJoiningOptions,
                              onChanged: (v) => setState(() => _expectedJoining = v ?? ServiceConstants.expectedJoiningOptions.first),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Internal Notes / Remarks',
                        icon: Icons.notes,
                        maxLines: 3,
                        isDark: isDark,
                        onSaved: (v) => _remarks = v ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required bool isDark,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    final isPhone = keyboardType == TextInputType.phone;
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
          maxLength: isPhone ? 10 : maxLength,
          inputFormatters: isPhone
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,
          decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.grey400 : AppColors.grey600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey300,
          ),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        counterText: '', // hide the length counter
      ),
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
          initialValue: items.contains(value) ? value : items.first,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.grey300,
          ),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
      ),
      dropdownColor: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
      items: items.toSet().map((T val) {
        return DropdownMenuItem<T>(value: val, child: Text(val.toString()));
      }).toList(),
      onChanged: onChanged,
    ),
      ],
    );
  }
}
