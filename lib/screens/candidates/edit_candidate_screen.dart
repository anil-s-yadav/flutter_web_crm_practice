import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/core/category_constants.dart';
import 'package:practice_app/models/candidate_model.dart';
import 'package:practice_app/providers/global_app_state.dart';
import 'package:practice_app/theme/app_colors.dart';
import 'package:practice_app/utils/extensions.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<GlobalAppState>(context, listen: false);
      final found = state.getCandidate(widget.candidateId);
      if (found != null) {
        setState(() {
          _candidate = found;
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
          _isLoading = false;
        });
      } else {
        context.pop();
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final state = Provider.of<GlobalAppState>(context, listen: false);

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
      );

      final summary = 'Updated: ${changes.join(', ')}';
      state.updateCandidate(updatedCandidate, summary);

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
      // appBar: AppBar(
      //   title: Text(
      //     'Edit Candidate Details',
      //     style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      //   ),
      //   backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      //   elevation: 0,
      //   actions: [
      //     TextButton.icon(
      //       onPressed: _saveChanges,
      //       icon: const Icon(Icons.save),
      //       label: Text(
      //         'Save',
      //         style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      //       ),
      //       style: TextButton.styleFrom(foregroundColor: AppColors.navyBlue),
      //     ),
      //     const SizedBox(width: 16),
      //   ],
      // ),
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
                      TextFormField(
                        initialValue: _name,
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
                              initialValue: _phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (v) =>
                                      v!.length < 10 ? 'Invalid phone' : null,
                              onSaved: (v) => _phone = v!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _age.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                border: OutlineInputBorder(),
                              ),
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
                            child: TextFormField(
                              initialValue: _address,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _address = v!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              initialValue: _city,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _city = v!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Religion',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _religion.isEmpty ? null : _religion,
                        items:
                            [
                              'Hindu',
                              'Muslim',
                              'Christian',
                              'Sikh',
                              'Other',
                            ].map((String val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                        onChanged: (val) => setState(() => _religion = val!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Education',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _education.isEmpty ? null : _education,
                        items:
                            [
                              'Below 10th',
                              '10th Pass',
                              '12th Pass',
                              'Graduate',
                            ].map((String val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
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
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Service Category',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _category,
                        items:
                            CategoryConstants.categories.map((String val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _experienceYears.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Experience (Years)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      int.tryParse(v!) == null
                                          ? 'Invalid'
                                          : null,
                              onSaved: (v) => _experienceYears = int.parse(v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _expectedSalary,
                              decoration: const InputDecoration(
                                labelText: 'Expected Salary',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                              onSaved: (v) => _expectedSalary = v!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyBlue,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
}
