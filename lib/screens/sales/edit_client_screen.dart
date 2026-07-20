import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/models/client_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
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
  String _email = '';
  String _locality = '';
  String _city = '';
  String _address = '';

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
  String _budgetRange = '';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<GlobalAppState>(context, listen: false);
      try {
        final found = state.clients.firstWhere((c) => c.id == widget.clientId);
        setState(() {
          _client = found;
          _fullName = _client.fullName;
          _phone = _client.phone;
          _email = _client.email;
          _locality = _client.locality;
          _city = _client.city;
          _address = _client.address;

          _houseType = _client.houseType;
          _familySize = _client.familySize;
          _hasPets = _client.hasPets;
          _petDetails = _client.petDetails ?? '';
          _hasElderlyMembers = _client.hasElderlyMembers;
          _hasChildren = _client.hasChildren;
          _childrenCount = _client.childrenCount ?? 0;

          _preferredCategory = _client.preferredCandidateCategory;
          _budgetRange = _client.budgetRange;

          _isLoading = false;
        });
      } catch (_) {
        context.pop();
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final state = Provider.of<GlobalAppState>(context, listen: false);

      final updatedClient = ClientModel(
        id: _client.id,
        fullName: _fullName,
        phone: _phone,
        altPhone: _client.altPhone,
        email: _email,
        address: _address,
        city: _city,
        locality: _locality,
        houseType: _houseType,
        familySize: _familySize,
        hasPets: _hasPets,
        petDetails: _hasPets ? _petDetails : null,
        hasElderlyMembers: _hasElderlyMembers,
        hasChildren: _hasChildren,
        childrenCount: _hasChildren ? _childrenCount : null,
        preferredCandidateCategory: _preferredCategory,
        requiredSkills: _client.requiredSkills,
        budgetRange: _budgetRange,
        status: _client.status,
        assignedEmployeeId: _client.assignedEmployeeId,
        source: _client.source,
        inquiryDate: _client.inquiryDate,
        remarks: _client.remarks,
      );

      state.updateClient(updatedClient);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client Profile updated successfully.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isDark = context.themeRef.brightness == Brightness.dark;

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
                              validator:
                                  (v) => v!.length < 10 ? 'Invalid' : null,
                              onSaved: (v) => _phone = v!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Email',
                              isDark: isDark,
                              initialValue: _email,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _email = v!,
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
                      _buildDropdown<String>(
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
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Budget Range',
                        isDark: isDark,
                        initialValue: _budgetRange,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        onSaved: (v) => _budgetRange = v!,
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
          initialValue: value,
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
              items.map((T val) {
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
