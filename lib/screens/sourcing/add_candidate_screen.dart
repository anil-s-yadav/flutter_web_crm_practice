import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/core/default_doc_urls.dart';
import 'package:practice_app/core/service_constants.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_bloc.dart';
import 'package:practice_app/blocs/candidate/candidate_event.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/blocs/auth/auth_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:practice_app/widgets/candidate_avatar.dart';
import 'package:practice_app/utils/image_picker_helper.dart';
import 'package:practice_app/repositories/candidate_repository.dart';
import 'package:provider/provider.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _addressController = TextEditingController();
  final _experienceYearsController = TextEditingController(text: '0');

  // Submission state
  bool _isSubmitting = false;

  // Personal Info
  String _city = 'Mumbai';
  String _religion = 'Hindu';
  String _education = '10th Pass';

  // Role & Experience
  String _category = CategoryConstants.categories.first;
  String _leadSource = ServiceConstants.leadSources.first;
  final List<String> _languages = ['Hindi'];

  // Salary Range
  RangeValues _salaryRange = const RangeValues(12000, 20000);

  // Documents & Photo
  bool _hasAadhaar = false;
  String? _aadhaarDocUrl;
  String? _aadhaarFileName;

  bool _hasPan = false;
  String? _panDocUrl;
  String? _panFileName;

  bool _hasPassport = false;
  String? _passportDocUrl;
  String? _passportFileName;

  bool _hasPoliceClearance = false;
  String? _policeDocUrl;
  String? _policeFileName;

  bool _hasMedicalClearance = false;
  String? _medicalDocUrl;
  String? _medicalFileName;

  bool _hasPhoto = false;
  Uint8List? _photoBytes;
  String _photoUrl = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument({
    required Function(String url, String fileName) onSuccess,
  }) async {
    try {
      final picked = await pickImageData();
      if (picked != null) {
        setState(() {
          onSuccess(picked.base64DataUrl, picked.fileName);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload document: $e')),
        );
      }
    }
  }

  Future<void> _pickCandidatePhoto() async {
    try {
      final picked = await pickImageData();
      if (picked != null) {
        setState(() {
          _photoBytes = picked.bytes;
          _photoUrl = picked.base64DataUrl;
          _hasPhoto = true;
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
        _hasPhoto = true;
      });
    }
  }

  Future<void> _addCandidate() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;

    // Backend will generate official CN00000001 format ID
    final candidate = CandidateModel(
      id: '',

      fullName: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 25,
      phone: _phoneController.text.trim(),
      altPhone:
          _altPhoneController.text.trim().isEmpty
              ? null
              : _altPhoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _city,
      state: 'Maharashtra',
      languages: List<String>.from(_languages),
      religion: _religion,
      category: _category,
      education: _education,
      experienceYears:
          int.tryParse(_experienceYearsController.text.trim()) ?? 0,
      expectedSalary:
          '₹${_salaryRange.start.round()} - ₹${_salaryRange.end.round()}',
      workingHoursPerDay: 10,
      preferredWorkType: '24 Hours',
      status: CandidateStatus.newlyAdded,
      isMedicalCleared: _hasMedicalClearance,
      isPoliceVerified: _hasPoliceClearance,
      aadhaarDocUrl: DefaultDocUrls.sanitizeDocUrl(
        _aadhaarDocUrl,
        _hasAadhaar,
        DefaultDocUrls.aadhaar,
      ),
      panDocUrl: DefaultDocUrls.sanitizeDocUrl(
        _panDocUrl,
        _hasPan,
        DefaultDocUrls.pan,
      ),
      passportDocUrl: DefaultDocUrls.sanitizeDocUrl(
        _passportDocUrl,
        _hasPassport,
        DefaultDocUrls.passport,
      ),
      policeVerificationDocUrl: DefaultDocUrls.sanitizeDocUrl(
        _policeDocUrl,
        _hasPoliceClearance,
        DefaultDocUrls.police,
      ),
      medicalClearanceDocUrl: DefaultDocUrls.sanitizeDocUrl(
        _medicalDocUrl,
        _hasMedicalClearance,
        DefaultDocUrls.medical,
      ),
      photoUrl: DefaultDocUrls.sanitizePhotoUrl(_photoUrl),
      addedBy: currentUser?.name ?? 'System',
      dateAdded: DateTime.now(),
      sourcedById: currentUser?.id,
      sourcedByName: currentUser?.name,
      sourcedByPhone: currentUser?.phone,
      source: _leadSource,
    );

    setState(() => _isSubmitting = true);

    try {
      await CandidateRepository().createCandidate(candidate);

      if (mounted) {
        context.read<CandidateBloc>().add(const LoadCandidates());
        final candidateName = candidate.fullName;
        _resetForm();
        _showSuccessDialog(candidateName);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.criticalRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _phoneController.clear();
    _altPhoneController.clear();
    _ageController.text = '25';
    _addressController.clear();
    _experienceYearsController.text = '0';

    setState(() {
      _city = 'Mumbai';
      _religion = 'Hindu';
      _education = '10th Pass';
      _category = CategoryConstants.categories.first;
      _languages.clear();
      _languages.add('Hindi');
      _salaryRange = const RangeValues(12000, 20000);

      // Reset documents
      _hasAadhaar = false;
      _aadhaarDocUrl = null;
      _aadhaarFileName = null;

      _hasPan = false;
      _panDocUrl = null;
      _panFileName = null;

      _hasPassport = false;
      _passportDocUrl = null;
      _passportFileName = null;

      _hasPoliceClearance = false;
      _policeDocUrl = null;
      _policeFileName = null;

      _hasMedicalClearance = false;
      _medicalDocUrl = null;
      _medicalFileName = null;

      // Reset photo
      _hasPhoto = false;
      _photoBytes = null;
      _photoUrl = '';
    });
  }

  void _showSuccessDialog(String addedName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
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
                    '$addedName has been added to the pool.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? AppColors.grey300 : AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? AppColors.grey300 : AppColors.navyBlue,
                            side: BorderSide(
                              color:
                                  isDark
                                      ? AppColors.dividerDark
                                      : AppColors.grey300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Add Another',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            context.go('/sourcing/candidates/new');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'View Pool',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      // --- Personal Info Section ---
                      _buildSectionTitle(
                        'Personal Information',
                        Icons.person_outline,
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildPhotoUploadSection(isDark),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildTextField(
                          label: 'Full Name',
                          isDark: isDark,
                          controller: _nameController,
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                        ),
                        _buildTextField(
                          label: 'Phone Number',
                          isDark: isDark,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Required';
                            if (v.trim().length != 10)
                              return 'Enter exactly 10 digits';
                            return null;
                          },
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildTextField(
                          label: 'Alternate Phone',
                          isDark: isDark,
                          controller: _altPhoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                v.trim().length != 10) {
                              return 'Enter exactly 10 digits';
                            }
                            return null;
                          },
                        ),
                        // Placeholder for symmetry if needed, or leave empty
                        const SizedBox.shrink(),
                      ]),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildTextField(
                          label: 'Age',
                          isDark: isDark,
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(v.trim()) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown<String>(
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
                      ]),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Address',
                        isDark: isDark,
                        controller: _addressController,
                        maxLines: 2,
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildDropdown<String>(
                          label: 'City',
                          value: _city,
                          items: const ['Mumbai', 'Pune', 'Delhi', 'Bangalore'],
                          onChanged: (v) => setState(() => _city = v!),
                          isDark: isDark,
                        ),
                        _buildDropdown<String>(
                          label: 'Education',
                          value: _education,
                          items: CategoryConstants.educationLevels,
                          onChanged: (v) => setState(() => _education = v!),
                          isDark: isDark,
                        ),
                      ]),
                      const SizedBox(height: 48),

                      // --- Role & Experience Section ---
                      _buildSectionTitle(
                        'Role & Experience',
                        Icons.work_outline,
                        isDark,
                      ),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildDropdown<String>(
                          label: 'Job Category',
                          value: _category,
                          items: CategoryConstants.categories,
                          onChanged: (v) {
                            setState(() {
                              _category = v!;
                              final base =
                                  CategoryConstants.baseSalaries[_category] ??
                                  15000.0;
                              _salaryRange = RangeValues(base, base + 8000.0);
                            });
                          },
                          isDark: isDark,
                        ),
                        _buildTextField(
                          label: 'Experience (Years)',
                          isDark: isDark,
                          controller: _experienceYearsController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(v.trim()) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildDropdown<String>(
                          label: 'Lead Source',
                          value: _leadSource,
                          items: ServiceConstants.leadSources,
                          onChanged:
                              (v) => setState(
                                () =>
                                    _leadSource =
                                        v ?? ServiceConstants.leadSources.first,
                              ),
                          isDark: isDark,
                        ),
                        const SizedBox(),
                      ]),
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
                        'Salary Expectations Range',
                        Icons.attach_money,
                        isDark,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF141A28)
                                  : AppColors.grey50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isDark
                                    ? const Color(0xFF2A3448)
                                    : AppColors.grey200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Expected Monthly Salary Range:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark
                                            ? AppColors.grey300
                                            : AppColors.grey700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '₹${_salaryRange.start.round()} – ₹${_salaryRange.end.round()} / mo',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark
                                              ? AppColors.gold
                                              : AppColors.navyBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.gold,
                                inactiveTrackColor:
                                    isDark
                                        ? const Color(0xFF2A3448)
                                        : AppColors.grey200,
                                thumbColor: AppColors.gold,
                                overlayColor: AppColors.gold.withValues(
                                  alpha: 0.2,
                                ),
                                valueIndicatorColor:
                                    isDark
                                        ? AppColors.gold
                                        : AppColors.navyBlue,
                                valueIndicatorTextStyle: GoogleFonts.poppins(
                                  color:
                                      isDark
                                          ? AppColors.navyBlue
                                          : AppColors.white,
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
                                values: _salaryRange,
                                min: 5000,
                                max: 100000,
                                divisions: 95,
                                labels: RangeLabels(
                                  '₹${_salaryRange.start.round()}',
                                  '₹${_salaryRange.end.round()}',
                                ),
                                onChanged: (RangeValues newValues) {
                                  setState(() {
                                    _salaryRange = newValues;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Min: ₹5,000',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color:
                                          isDark
                                              ? AppColors.grey400
                                              : AppColors.grey600,
                                    ),
                                  ),
                                  Text(
                                    'Max: ₹1,00,000',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color:
                                          isDark
                                              ? AppColors.grey400
                                              : AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                      _buildResponsiveFields(context, [
                        _buildUploadCard(
                          title: 'Aadhaar Card',
                          isUploaded: _hasAadhaar,
                          fileName: _aadhaarFileName,
                          onUpload:
                              () => _pickDocument(
                                onSuccess: (url, name) {
                                  _hasAadhaar = true;
                                  _aadhaarDocUrl = url;
                                  _aadhaarFileName = name;
                                },
                              ),
                          onRemove:
                              () => setState(() {
                                _hasAadhaar = false;
                                _aadhaarDocUrl = null;
                                _aadhaarFileName = null;
                              }),
                          isDark: isDark,
                        ),
                        _buildUploadCard(
                          title: 'PAN Card',
                          isUploaded: _hasPan,
                          fileName: _panFileName,
                          onUpload:
                              () => _pickDocument(
                                onSuccess: (url, name) {
                                  _hasPan = true;
                                  _panDocUrl = url;
                                  _panFileName = name;
                                },
                              ),
                          onRemove:
                              () => setState(() {
                                _hasPan = false;
                                _panDocUrl = null;
                                _panFileName = null;
                              }),
                          isDark: isDark,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildUploadCard(
                          title: 'Police Clearance',
                          isUploaded: _hasPoliceClearance,
                          fileName: _policeFileName,
                          onUpload:
                              () => _pickDocument(
                                onSuccess: (url, name) {
                                  _hasPoliceClearance = true;
                                  _policeDocUrl = url;
                                  _policeFileName = name;
                                },
                              ),
                          onRemove:
                              () => setState(() {
                                _hasPoliceClearance = false;
                                _policeDocUrl = null;
                                _policeFileName = null;
                              }),
                          isDark: isDark,
                        ),
                        _buildUploadCard(
                          title: 'Medical Clearance',
                          isUploaded: _hasMedicalClearance,
                          fileName: _medicalFileName,
                          onUpload:
                              () => _pickDocument(
                                onSuccess: (url, name) {
                                  _hasMedicalClearance = true;
                                  _medicalDocUrl = url;
                                  _medicalFileName = name;
                                },
                              ),
                          onRemove:
                              () => setState(() {
                                _hasMedicalClearance = false;
                                _medicalDocUrl = null;
                                _medicalFileName = null;
                              }),
                          isDark: isDark,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildResponsiveFields(context, [
                        _buildUploadCard(
                          title: 'Passport (Optional)',
                          isUploaded: _hasPassport,
                          fileName: _passportFileName,
                          onUpload:
                              () => _pickDocument(
                                onSuccess: (url, name) {
                                  _hasPassport = true;
                                  _passportDocUrl = url;
                                  _passportFileName = name;
                                },
                              ),
                          onRemove:
                              () => setState(() {
                                _hasPassport = false;
                                _passportDocUrl = null;
                                _passportFileName = null;
                              }),
                          isDark: isDark,
                        ),
                      ]),
                      const SizedBox(height: 48),

                      // --- Save Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _addCandidate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.navyBlue,
                                    ),
                                  )
                                  : Text(
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
                name:
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Candidate',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveFields(BuildContext context, List<Widget> fields) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            fields.expand((f) => [f, const SizedBox(height: 24)]).toList()
              ..removeLast(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          fields
              .expand((f) => [Expanded(child: f), const SizedBox(width: 24)])
              .toList()
            ..removeLast(),
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
    TextEditingController? controller,
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
          controller: controller,
          initialValue: controller == null ? initialValue : null,
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
        DropdownButtonFormField<String>(
          initialValue: value as String,
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
              items.cast<String>().toSet().map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val.toString()),
                );
              }).toList(),
          onChanged: (String? val) => onChanged(val as T?),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool isUploaded,
    String? fileName,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A28) : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isUploaded
                  ? AppColors.successGreen
                  : (isDark ? const Color(0xFF2A3448) : AppColors.grey300),
          width: isUploaded ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isUploaded
                      ? AppColors.successGreen.withValues(alpha: 0.15)
                      : (isDark ? AppColors.darkSurface : AppColors.white),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
              color:
                  isUploaded
                      ? AppColors.successGreen
                      : (isDark ? AppColors.grey400 : AppColors.navyBlue),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.navyBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isUploaded
                      ? (fileName ?? 'Document attached')
                      : 'Click Upload to attach document file',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        isUploaded
                            ? AppColors.successGreen
                            : (isDark ? AppColors.grey400 : AppColors.grey600),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUploaded)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.criticalRed,
              tooltip: 'Remove document',
              onPressed: onRemove,
            )
          else
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file, size: 14),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyBlue,
                textStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
