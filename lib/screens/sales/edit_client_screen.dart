import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/core/service_constants.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/client/client_bloc.dart';
import 'package:practice_app/blocs/client/client_event.dart';
import 'package:practice_app/blocs/client/client_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

class EditClientScreen extends StatefulWidget {
  final String clientId;
  const EditClientScreen({super.key, required this.clientId});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late ClientModel _client;
  bool _isLoading = true;

  // Personal Info
  String _fullName = '';
  String _phone = '';
  String _altPhone = '';
  String _email = '';
  String _locality = '';
  String _city = '';
  String _address = '';
  String _source = ServiceConstants.leadSources.first;

  // Household Details
  String _houseType = '';
  int _familySize = 0;
  bool _hasPets = false;
  String _petDetails = '';
  bool _hasElderlyMembers = false;
  bool _hasChildren = false;
  int _childrenCount = 0;

  // Service Requirements
  String _preferredCategory = '';
  String _serviceType = ServiceConstants.serviceTypes.first;
  String _workTimings = ServiceConstants.workTimingPresets.first;
  String _budgetRange = '';
  String _foodPreference = ServiceConstants.foodPreferences.first;
  String _genderPreference = ServiceConstants.genderPreferences.first;
  List<String> _preferredLanguages = ['Hindi'];
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

  @override
  void initState() {
    super.initState();
    final clientState = context.read<ClientBloc>().state;
    if (clientState is ClientLoaded) {
      try {
        final found = clientState.clients.firstWhere((c) => c.id == widget.clientId);
        setState(() {
          _client = found;
          _fullName = found.fullName;
          _phone = found.phone;
          _altPhone = found.altPhone ?? '';
          _email = found.email;
          _address = found.address;
          _city = found.city;
          _locality = found.locality;
          _source = found.source.isNotEmpty ? found.source : ServiceConstants.leadSources.first;
          _houseType = found.houseType;
          _familySize = found.familySize;
          _hasPets = found.hasPets;
          _petDetails = found.petDetails ?? '';
          _hasElderlyMembers = found.hasElderlyMembers;
          _hasChildren = found.hasChildren;
          _childrenCount = found.childrenCount ?? 1;
          _preferredCategory = found.preferredCandidateCategory;
          _serviceType = found.serviceType.isNotEmpty ? found.serviceType : ServiceConstants.serviceTypes.first;
          _workTimings = found.workTimings.isNotEmpty ? found.workTimings : ServiceConstants.workTimingPresets.first;
          _budgetRange = found.budgetRange;
          _foodPreference = found.foodPreference.isNotEmpty ? found.foodPreference : ServiceConstants.foodPreferences.first;
          _genderPreference = found.genderPreference.isNotEmpty ? found.genderPreference : ServiceConstants.genderPreferences.first;
          _preferredLanguages = found.preferredLanguages.isNotEmpty ? List<String>.from(found.preferredLanguages) : ['Hindi'];
          _religionPreference = found.religionPreference.isNotEmpty ? found.religionPreference : ServiceConstants.religionPreferences.first;
          _expectedJoining = found.expectedJoining.isNotEmpty ? found.expectedJoining : ServiceConstants.expectedJoiningOptions.first;
          _contractDuration = found.contractDuration.isNotEmpty ? found.contractDuration : ServiceConstants.contractDurations.last;
          _remarks = found.remarks ?? '';
          _isLoading = false;
        });
      } catch (e) {
        context.pop();
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedClient = _client.copyWith(
        fullName: _fullName,
        phone: _phone,
        altPhone: _altPhone.isEmpty ? null : _altPhone,
        email: _email,
        address: _address,
        city: _city,
        locality: _locality,
        source: _source,
        houseType: _houseType,
        familySize: _familySize,
        hasPets: _hasPets,
        petDetails: _hasPets ? _petDetails : null,
        hasElderlyMembers: _hasElderlyMembers,
        hasChildren: _hasChildren,
        childrenCount: _hasChildren ? _childrenCount : null,
        preferredCandidateCategory: _preferredCategory,
        serviceType: _serviceType,
        workTimings: _workTimings,
        budgetRange: _budgetRange,
        foodPreference: _foodPreference,
        genderPreference: _genderPreference,
        preferredLanguages: _preferredLanguages.isEmpty ? const ['Hindi'] : _preferredLanguages,
        religionPreference: _religionPreference,
        expectedJoining: _expectedJoining,
        contractDuration: _contractDuration,
        remarks: _remarks.isEmpty ? null : _remarks,
      );

      context.read<ClientBloc>().add(UpdateClient(updatedClient));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client details updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isDark = context.themeRef.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Client Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
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
                      Text(
                        'Personal Information',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Full Name',
                        isDark: isDark,
                        initialValue: _fullName,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        onSaved: (v) => _fullName = v!,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Phone Number',
                              isDark: isDark,
                              initialValue: _phone,
                              keyboardType: TextInputType.phone,
                              validator:
                                  (v) =>
                                      v == null || v.length != 10
                                          ? 'Enter exactly 10 digits'
                                          : null,
                              onSaved: (v) => _phone = v!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Alternate Phone',
                              isDark: isDark,
                              initialValue: _altPhone,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v != null && v.isNotEmpty && v.length != 10) {
                                  return 'Enter exactly 10 digits';
                                }
                                return null;
                              },
                              onSaved: (v) => _altPhone = v ?? '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Email',
                              isDark: isDark,
                              initialValue: _email,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _email = v!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Lead Source',
                              isDark: isDark,
                              value: _source,
                              items: ServiceConstants.leadSources.contains(_source)
                                  ? ServiceConstants.leadSources
                                  : [...ServiceConstants.leadSources, _source],
                              onChanged:
                                  (val) => setState(() => _source = val ?? ServiceConstants.leadSources.first),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              label: 'Address',
                              isDark: isDark,
                              initialValue: _address,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _address = v!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Locality',
                              isDark: isDark,
                              initialValue: _locality,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _locality = v!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'City',
                              isDark: isDark,
                              initialValue: _city,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _city = v!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Household Details',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'House Type',
                              isDark: isDark,
                              value: _houseType,
                              items:
                                  _houseTypes.contains(_houseType)
                                      ? _houseTypes
                                      : [..._houseTypes, _houseType],
                              onChanged:
                                  (val) => setState(() => _houseType = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Family Size',
                              isDark: isDark,
                              initialValue: _familySize.toString(),
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      int.tryParse(v!) == null
                                          ? 'Invalid'
                                          : null,
                              onSaved: (v) => _familySize = int.parse(v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'Has Pets',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: _hasPets,
                        onChanged: (val) => setState(() => _hasPets = val),
                        activeThumbColor: AppColors.navyBlue,
                      ),
                      if (_hasPets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildTextField(
                            label: 'Pet Details',
                            isDark: isDark,
                            initialValue: _petDetails,
                            onSaved: (v) => _petDetails = v ?? '',
                          ),
                        ),
                      SwitchListTile(
                        title: Text(
                          'Has Elderly Members',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: _hasElderlyMembers,
                        onChanged:
                            (val) => setState(() => _hasElderlyMembers = val),
                        activeThumbColor: AppColors.navyBlue,
                      ),
                      SwitchListTile(
                        title: Text(
                          'Has Children',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: _hasChildren,
                        onChanged: (val) => setState(() => _hasChildren = val),
                        activeThumbColor: AppColors.navyBlue,
                      ),
                      if (_hasChildren)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildTextField(
                            label: 'Children Count',
                            isDark: isDark,
                            initialValue: _childrenCount.toString(),
                            keyboardType: TextInputType.number,
                            onSaved:
                                (v) =>
                                    _childrenCount =
                                        int.tryParse(v ?? '0') ?? 0,
                          ),
                        ),
                      const SizedBox(height: 32),
                      Text(
                        'Service Requirements',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Preferred Category',
                              isDark: isDark,
                              value: _preferredCategory,
                              items:
                                  CategoryConstants.categories.contains(
                                        _preferredCategory,
                                      )
                                      ? CategoryConstants.categories
                                      : [
                                        ...CategoryConstants.categories,
                                        _preferredCategory,
                                      ],
                              onChanged:
                                  (val) => setState(() => _preferredCategory = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Service Type',
                              isDark: isDark,
                              value: _serviceType,
                              items: ServiceConstants.serviceTypes.contains(_serviceType)
                                  ? ServiceConstants.serviceTypes
                                  : [...ServiceConstants.serviceTypes, _serviceType],
                              onChanged:
                                  (val) => setState(() => _serviceType = val ?? ServiceConstants.serviceTypes.first),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Work Timings',
                              isDark: isDark,
                              value: _workTimings,
                              items: ServiceConstants.workTimingPresets.contains(_workTimings)
                                  ? ServiceConstants.workTimingPresets
                                  : [...ServiceConstants.workTimingPresets, _workTimings],
                              onChanged:
                                  (val) => setState(() => _workTimings = val ?? ServiceConstants.workTimingPresets.first),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Budget Range (e.g. ₹15,000 - ₹25,000)',
                              isDark: isDark,
                              initialValue: _budgetRange,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _budgetRange = v!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Food Preference',
                              isDark: isDark,
                              value: _foodPreference,
                              items: ServiceConstants.foodPreferences.contains(_foodPreference)
                                  ? ServiceConstants.foodPreferences
                                  : [...ServiceConstants.foodPreferences, _foodPreference],
                              onChanged:
                                  (val) => setState(() => _foodPreference = val ?? ServiceConstants.foodPreferences.first),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Gender Preference',
                              isDark: isDark,
                              value: _genderPreference,
                              items: ServiceConstants.genderPreferences.contains(_genderPreference)
                                  ? ServiceConstants.genderPreferences
                                  : [...ServiceConstants.genderPreferences, _genderPreference],
                              onChanged:
                                  (val) => setState(() => _genderPreference = val ?? ServiceConstants.genderPreferences.first),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Preferred Language(s)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Religion Preference',
                              isDark: isDark,
                              value: _religionPreference,
                              items: ServiceConstants.religionPreferences.contains(_religionPreference)
                                  ? ServiceConstants.religionPreferences
                                  : [...ServiceConstants.religionPreferences, _religionPreference],
                              onChanged:
                                  (val) => setState(() => _religionPreference = val ?? ServiceConstants.religionPreferences.first),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Expected Joining',
                              isDark: isDark,
                              value: _expectedJoining,
                              items: ServiceConstants.expectedJoiningOptions.contains(_expectedJoining)
                                  ? ServiceConstants.expectedJoiningOptions
                                  : [...ServiceConstants.expectedJoiningOptions, _expectedJoining],
                              onChanged:
                                  (val) => setState(() => _expectedJoining = val ?? ServiceConstants.expectedJoiningOptions.first),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<String>(
                              label: 'Contract Duration',
                              isDark: isDark,
                              value: _contractDuration,
                              items: ServiceConstants.contractDurations.contains(_contractDuration)
                                  ? ServiceConstants.contractDurations
                                  : [...ServiceConstants.contractDurations, _contractDuration],
                              onChanged:
                                  (val) => setState(() => _contractDuration = val ?? ServiceConstants.contractDurations.last),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Internal Notes / Remarks',
                        isDark: isDark,
                        initialValue: _remarks,
                        maxLines: 3,
                        onSaved: (v) => _remarks = v ?? '',
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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

  Widget _buildTextField({
    required String label,
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
            counterText: '',
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
    final effectiveValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : value);
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
          initialValue: effectiveValue,
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
          dropdownColor:
              isDark ? AppColors.darkSurfaceVariant : AppColors.white,
          items:
              items.toSet().map((T val) {
                return DropdownMenuItem<T>(
                  value: val,
                  child: Text(val.toString()),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
