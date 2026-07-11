import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
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
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Step 1: Personal Info
  String _fullName = '';
  String _phone = '';
  String _email = '';
  String _locality = '';
  String _city = 'Mumbai';
  String _address = '';

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
  double _budgetBase = 15000;
  double _budgetEnd = 20000;
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

  void _addClient() {
    final state = Provider.of<GlobalAppState>(context, listen: false);

    // Generate an ID based on current count
    final newId = 'CLI${2000 + state.clients.length + 1}';

    final client = ClientModel(
      id: newId,
      fullName: _fullName,
      phone: _phone,
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
      requiredSkills: const ['Standard Duty'], // default hidden skill
      budgetRange: '₹${_budgetBase.toInt()} - ₹${_budgetEnd.toInt()}',
      status: ClientStatus.newInquiry,
      assignedEmployeeId: state.currentUser?.id.toString(),
      source: 'Direct Entry',
      inquiryDate: DateTime.now(),
      remarks: _remarks.isNotEmpty ? _remarks : null,
    );

    state.addClient(client);
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
      appBar: AppBar(
        title: Text(
          'Add New Client',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
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
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLast ? AppColors.successGreen : AppColors.gold,
                          foregroundColor:
                              isLast ? AppColors.white : AppColors.navyBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isLast ? 'Save Client' : 'Continue'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color:
                                isDark ? AppColors.dividerDark : AppColors.grey300,
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
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
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
                        label: 'Email (Optional)',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
                                  (v) => v == null || v.isEmpty ? 'Required' : null,
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
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('Household Details'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
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
                              onChanged: (v) => setState(() => _familySize = v!),
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
                        'Looking For',
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
                                  if (val) setState(() => _preferredCategory = c);
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
                      Text(
                        'Budget Range: ₹${_budgetBase.toInt()} - ₹${_budgetEnd.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RangeSlider(
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
    return TextFormField(
      initialValue: initialValue,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
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
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required bool isDark,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
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
      items:
          items
              .map((i) => DropdownMenuItem(value: i, child: Text(i.toString())))
              .toList(),
      onChanged: onChanged,
    );
  }
}
