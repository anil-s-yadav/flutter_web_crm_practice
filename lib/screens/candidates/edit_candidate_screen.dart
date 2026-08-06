import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/candidate/candidate_state.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/core/default_doc_urls.dart';
import 'package:practice_app/core/service_constants.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/candidate_avatar.dart';
import 'package:practice_app/utils/image_picker_helper.dart';

class EditCandidateScreen extends StatefulWidget {
  final String candidateId;
  const EditCandidateScreen({super.key, required this.candidateId});

  @override
  State<EditCandidateScreen> createState() => _EditCandidateScreenState();
}

class _EditCandidateScreenState extends State<EditCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  late CandidateModel _candidate;
  bool _isLoading = true;

  // Form fields
  String _name = '';
  String _phone = '';
  int _age = 0;
  String _city = '';
  String _address = '';
  String _religion = '';
  String _education = '';
  String _category = '';
  List<String> _languages = [];
  int _experienceYears = 0;
  String _expectedSalary = '';
  String _minSalary = '15000';
  String _maxSalary = '25000';
  String _leadSource = '';

  String? _aadhaarDocUrl;
  String? _panDocUrl;
  String? _passportDocUrl;
  String? _policeVerificationDocUrl;
  String? _medicalClearanceDocUrl;
  bool _isPoliceVerified = false;
  bool _isMedicalCleared = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final candidateState = context.read<CandidateBloc>().state;
      CandidateModel? found;
      if (candidateState is CandidateLoaded) {
        found =
            candidateState.candidates
                .where((c) => c.id == widget.candidateId)
                .firstOrNull;
      }
      if (found != null) {
        setState(() {
          _candidate = found!;
          _name = _candidate.fullName;
          _phone = _candidate.phone;
          _age = _candidate.age;
          _city = _candidate.city;
          _address = _candidate.address;
          _religion = _candidate.religion;
          _education = _candidate.education;
          _category = _candidate.category;
          _languages = List.from(_candidate.languages);
          _experienceYears = _candidate.experienceYears;
          _expectedSalary = _candidate.expectedSalary;
          _leadSource =
              _candidate.source.isNotEmpty
                  ? _candidate.source
                  : ServiceConstants.leadSources.first;
          _photoUrl = _candidate.photoUrl;
          _aadhaarDocUrl = _candidate.aadhaarDocUrl;
          _panDocUrl = _candidate.panDocUrl;
          _passportDocUrl = _candidate.passportDocUrl;
          _policeVerificationDocUrl = _candidate.policeVerificationDocUrl;
          _medicalClearanceDocUrl = _candidate.medicalClearanceDocUrl;
          _isPoliceVerified = _candidate.isPoliceVerified;
          _isMedicalCleared = _candidate.isMedicalCleared;
          _parseSalaryRange(_candidate.expectedSalary);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Uint8List? _photoBytes;
  String _photoUrl = '';

  Future<void> _pickCandidatePhoto() async {
    try {
      final picked = await pickImageData();
      if (picked != null) {
        setState(() {
          _photoBytes = picked.bytes;
          _photoUrl = picked.base64DataUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick photo: $e')));
      }
    }
  }

  Future<void> _enterPhotoUrl() async {
    final controller = TextEditingController(
      text: _photoUrl.startsWith('data:') ? '' : _photoUrl,
    );
    final url = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              'Enter Photo URL',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/photo.jpg',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() {
        _photoBytes = null;
        _photoUrl = url;
      });
    }
  }

  void _parseSalaryRange(String salaryStr) {
    final clean = salaryStr.replaceAll('₹', '').replaceAll(',', '').trim();
    if (clean.contains('-') || clean.contains('–')) {
      final parts = clean.split(RegExp(r'[-–]'));
      if (parts.length >= 2) {
        _minSalary = parts[0].trim();
        _maxSalary = parts[1].trim();
        return;
      }
    }
    final single = int.tryParse(clean.replaceAll(RegExp(r'[^0-9]'), ''));
    if (single != null) {
      _minSalary = single.toString();
      _maxSalary = (single + 5000).toString();
    } else {
      _minSalary = '15000';
      _maxSalary = '25000';
    }
  }

  void _saveChanges() {
    if (_candidate.status != CandidateStatus.newlyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot edit profile once moved to Verification. Rollback to Newly Added first.',
          ),
          backgroundColor: AppColors.criticalRed,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _expectedSalary =
          '₹${_minSalary.replaceAll('₹', '').trim()} - ₹${_maxSalary.replaceAll('₹', '').trim()}';

      // Determine what changed for the audit log
      List<String> changes = [];
      if (_name != _candidate.fullName) changes.add('Name');
      if (_phone != _candidate.phone) changes.add('Phone');
      if (_age != _candidate.age) changes.add('Age');
      if (_city != _candidate.city || _address != _candidate.address) {
        changes.add('Address');
      }
      if (_religion != _candidate.religion) changes.add('Religion');
      if (_education != _candidate.education) changes.add('Education');
      if (_category != _candidate.category) changes.add('Category');
      if (_languages.join(',') != _candidate.languages.join(',')) {
        changes.add('Languages');
      }
      if (_experienceYears != _candidate.experienceYears) {
        changes.add('Experience');
      }
      if (_expectedSalary != _candidate.expectedSalary) changes.add('Salary');
      if (_photoUrl != _candidate.photoUrl) changes.add('Photo');
      if (_aadhaarDocUrl != _candidate.aadhaarDocUrl ||
          _panDocUrl != _candidate.panDocUrl ||
          _passportDocUrl != _candidate.passportDocUrl ||
          _policeVerificationDocUrl != _candidate.policeVerificationDocUrl ||
          _medicalClearanceDocUrl != _candidate.medicalClearanceDocUrl ||
          _isPoliceVerified != _candidate.isPoliceVerified ||
          _isMedicalCleared != _candidate.isMedicalCleared) {
        changes.add('Documents & Verification');
      }

      if (changes.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No changes made.')));
        context.pop();
        return;
      }

      final updatedCandidate = _candidate.copyWith(
        fullName: _name,
        age: _age,
        phone: _phone,
        address: _address,
        city: _city,
        category: _category,
        languages: _languages,
        religion: _religion,
        education: _education,
        experienceYears: _experienceYears,
        expectedSalary: _expectedSalary,
        source: _leadSource,
        photoUrl: DefaultDocUrls.sanitizePhotoUrl(_photoUrl),
        aadhaarDocUrl: _aadhaarDocUrl,
        panDocUrl: _panDocUrl,
        passportDocUrl: _passportDocUrl,
        policeVerificationDocUrl: _policeVerificationDocUrl,
        medicalClearanceDocUrl: _medicalClearanceDocUrl,
        isPoliceVerified: _isPoliceVerified,
        isMedicalCleared: _isMedicalCleared,
      );

      context.read<CandidateBloc>().add(UpdateCandidate(updatedCandidate));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
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
                      if (_candidate.status != CandidateStatus.newlyAdded) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.urgentAmber.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.urgentAmber.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: AppColors.urgentAmber,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Profile is locked because candidate has moved to ${_candidate.status.displayName}. Rollback to Newly Added to edit.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark
                                            ? AppColors.white
                                            : AppColors.navyBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        'Personal Information',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPhotoUploadSection(isDark),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Full Name',
                        isDark: isDark,
                        initialValue: _name,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        onSaved: (v) => _name = v!,
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
                              label: 'Age',
                              isDark: isDark,
                              initialValue: _age.toString(),
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      int.tryParse(v!) == null
                                          ? 'Invalid'
                                          : null,
                              onSaved: (v) => _age = int.parse(v!),
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
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
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
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        label: 'Religion',
                        isDark: isDark,
                        value: _religion.isEmpty ? 'Hindu' : _religion,
                        items: [
                          'Hindu',
                          'Muslim',
                          'Christian',
                          'Sikh',
                          'Other',
                        ],
                        onChanged: (val) => setState(() => _religion = val!),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        label: 'Education',
                        isDark: isDark,
                        value:
                            CategoryConstants.educationLevels.contains(
                                  _education,
                                )
                                ? _education
                                : (_education.isEmpty
                                    ? 'Not Specified'
                                    : _education),
                        items:
                            CategoryConstants.educationLevels.contains(
                                  _education,
                                )
                                ? CategoryConstants.educationLevels
                                : [
                                  ...CategoryConstants.educationLevels,
                                  if (_education.isNotEmpty &&
                                      !CategoryConstants.educationLevels
                                          .contains(_education))
                                    _education,
                                ],
                        onChanged: (val) => setState(() => _education = val!),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Professional Details',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<String>(
                        label: 'Service Category',
                        isDark: isDark,
                        value:
                            _category.isEmpty
                                ? CategoryConstants.categories.first
                                : _category,
                        items:
                            CategoryConstants.categories.contains(_category)
                                ? CategoryConstants.categories
                                : [...CategoryConstants.categories, _category],
                        onChanged: (val) {
                          setState(() {
                            _category = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Languages Spoken',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            languageOptions.map((lang) {
                              final isSelected = _languages.contains(lang);
                              return FilterChip(
                                label: Text(lang),
                                selected: isSelected,
                                selectedColor: AppColors.gold.withValues(
                                  alpha: 0.3,
                                ),
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
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Experience (Years)',
                        isDark: isDark,
                        initialValue: _experienceYears.toString(),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) => int.tryParse(v!) == null ? 'Invalid' : null,
                        onSaved: (v) => _experienceYears = int.parse(v!),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Expected Monthly Salary Range',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Min Salary (₹)',
                              isDark: isDark,
                              initialValue: _minSalary,
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                              onSaved: (v) => _minSalary = v ?? '15000',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Max Salary (₹)',
                              isDark: isDark,
                              initialValue: _maxSalary,
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                              onSaved: (v) => _maxSalary = v ?? '25000',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDropdown<String>(
                        label: 'Lead Source',
                        isDark: isDark,
                        value:
                            _leadSource.isNotEmpty
                                ? _leadSource
                                : ServiceConstants.leadSources.first,
                        items: ServiceConstants.leadSources,
                        onChanged: (val) => setState(() => _leadSource = val!),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Documents & Verification',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDocCard(
                        title: 'Aadhaar Card',
                        url: _aadhaarDocUrl,
                        isDark: isDark,
                        onUpload: () async {
                          final picked = await pickImageData();
                          if (picked != null) {
                            setState(() {
                              _aadhaarDocUrl = DefaultDocUrls.sanitizeDocUrl(
                                picked.base64DataUrl,
                                'Aadhaar',
                              );
                            });
                          }
                        },
                        onRemove: () => setState(() => _aadhaarDocUrl = null),
                      ),
                      const SizedBox(height: 12),
                      _buildDocCard(
                        title: 'PAN Card',
                        url: _panDocUrl,
                        isDark: isDark,
                        onUpload: () async {
                          final picked = await pickImageData();
                          if (picked != null) {
                            setState(() {
                              _panDocUrl = DefaultDocUrls.sanitizeDocUrl(
                                picked.base64DataUrl,
                                'PAN',
                              );
                            });
                          }
                        },
                        onRemove: () => setState(() => _panDocUrl = null),
                      ),
                      const SizedBox(height: 12),
                      _buildDocCard(
                        title: 'Police Verification',
                        url: _policeVerificationDocUrl,
                        isDark: isDark,
                        isPromotionOnly: true,
                        onUpload: () async {
                          final picked = await pickImageData();
                          if (picked != null) {
                            setState(() {
                              _policeVerificationDocUrl =
                                  DefaultDocUrls.sanitizeDocUrl(
                                    picked.base64DataUrl,
                                    'Police',
                                  );
                              _isPoliceVerified = true;
                            });
                          }
                        },
                        onRemove:
                            () => setState(() {
                              _policeVerificationDocUrl = null;
                              _isPoliceVerified = false;
                            }),
                      ),
                      const SizedBox(height: 12),
                      _buildDocCard(
                        title: 'Medical Clearance',
                        url: _medicalClearanceDocUrl,
                        isDark: isDark,
                        isPromotionOnly: true,
                        onUpload: () async {
                          final picked = await pickImageData();
                          if (picked != null) {
                            setState(() {
                              _medicalClearanceDocUrl =
                                  DefaultDocUrls.sanitizeDocUrl(
                                    picked.base64DataUrl,
                                    'Medical',
                                  );
                              _isMedicalCleared = true;
                            });
                          }
                        },
                        onRemove:
                            () => setState(() {
                              _medicalClearanceDocUrl = null;
                              _isMedicalCleared = false;
                            }),
                      ),
                      const SizedBox(height: 12),
                      _buildDocCard(
                        title: 'Passport (Optional)',
                        url: _passportDocUrl,
                        isDark: isDark,
                        onUpload: () async {
                          final picked = await pickImageData();
                          if (picked != null) {
                            setState(() {
                              _passportDocUrl = DefaultDocUrls.sanitizeDocUrl(
                                picked.base64DataUrl,
                                'Passport',
                              );
                            });
                          }
                        },
                        onRemove: () => setState(() => _passportDocUrl = null),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _candidate.status == CandidateStatus.newlyAdded
                                  ? _saveChanges
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyBlue,
                            disabledBackgroundColor:
                                isDark ? AppColors.grey700 : AppColors.grey300,
                            disabledForegroundColor: AppColors.grey500,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _candidate.status == CandidateStatus.newlyAdded
                                ? 'Save Changes'
                                : 'Profile Locked (${_candidate.status.displayName})',
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

  Widget _buildPhotoUploadSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A28) : AppColors.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3448) : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CandidateAvatar(
                photoBytes: _photoBytes,
                photoUrl: _photoUrl,
                name: _name.isNotEmpty ? _name : 'Candidate',
                radius: 40,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickCandidatePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isDark ? const Color(0xFF141A28) : AppColors.white,
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
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Candidate Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                Text(
                  _photoUrl.isNotEmpty
                      ? (_photoUrl.startsWith('data:')
                          ? 'Photo attached & ready'
                          : _photoUrl)
                      : 'Upload candidate photo or enter image URL',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickCandidatePhoto,
                      icon: const Icon(Icons.add_a_photo, size: 15),
                      label: const Text('Choose Photo File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyBlue,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _enterPhotoUrl,
                      icon: const Icon(Icons.link, size: 15),
                      label: const Text('Image URL'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? AppColors.grey300 : AppColors.navyBlue,
                        textStyle: GoogleFonts.poppins(fontSize: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (_photoUrl.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: AppColors.errorRed,
                        tooltip: 'Remove Photo',
                        onPressed: () {
                          setState(() {
                            _photoBytes = null;
                            _photoUrl = '';
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          inputFormatters:
              isPhone
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

  Widget _buildDocCard({
    required String title,
    required String? url,
    required bool isDark,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
    bool isPromotionOnly = false,
  }) {
    final hasDoc = url != null && url.trim().isNotEmpty && url.trim() != 'null';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A28) : AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3448) : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDoc ? Icons.description : Icons.description_outlined,
            size: 20,
            color: hasDoc ? AppColors.successGreen : AppColors.grey500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                Text(
                  hasDoc
                      ? 'Document Attached'
                      : (isPromotionOnly
                          ? 'Upload during promotion'
                          : 'Not Uploaded'),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color:
                        hasDoc
                            ? AppColors.successGreen
                            : (isPromotionOnly
                                ? AppColors.grey500
                                : AppColors.urgentAmber),
                  ),
                ),
              ],
            ),
          ),
          if (hasDoc) ...[
            if (!isPromotionOnly) ...[
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Replace Document',
                color: AppColors.gold,
                onPressed: onUpload,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: 'Remove Document',
              color: AppColors.errorRed,
              onPressed: onRemove,
            ),
          ] else if (isPromotionOnly) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.grey500.withValues(alpha: 0.1)
                        : AppColors.grey200.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Via Promotion',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.file_upload_outlined, size: 14),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyBlue,
                elevation: 0,
                textStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
