import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_app/auth/user_manager.dart';
import 'package:practice_app/blocs/learning/learning_bloc.dart';
import 'package:practice_app/blocs/learning/learning_event.dart';
import 'package:practice_app/blocs/learning/learning_state.dart';
import 'package:practice_app/models/learning_topic_model.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/theme/app_colors.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedLanguage = 'english'; // 'english', 'hindi'

  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(const LoadLearningTopics());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    context.read<LearningBloc>().add(LoadLearningTopics(
          category: _selectedCategory == 'all' ? null : _selectedCategory,
          search: val.trim().isEmpty ? null : val.trim(),
        ));
  }

  void _onCategoryChanged(String cat) {
    setState(() => _selectedCategory = cat);
    context.read<LearningBloc>().add(LoadLearningTopics(
          category: cat == 'all' ? null : cat,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$label copied to clipboard! Ready to use on call or WhatsApp.',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final userRole = UserManager().currentUser?.role;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          final allTopics = state is LearningLoaded ? state.topics : <LearningTopicModel>[];

          // Filter by language client-side if chosen
          final displayedTopics = allTopics.where((t) {
            if (_selectedLanguage == 'english') {
              return t.scriptEnglish != null && t.scriptEnglish!.isNotEmpty;
            } else if (_selectedLanguage == 'hindi') {
              return t.scriptHindi != null && t.scriptHindi!.isNotEmpty;
            }
            return true;
          }).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                _buildHeader(isDark, userRole),
                const SizedBox(height: 20),

                // Search & Filter Toolbar
                _buildFilterBar(isDark),
                const SizedBox(height: 16),

                // Language Selector Pills
                _buildLanguageSelector(isDark),
                const SizedBox(height: 20),

                // Content
                if (state is LearningLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (displayedTopics.isEmpty)
                  _buildEmptyState(isDark)
                else
                  _buildTopicsList(displayedTopics, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark, UserRole? role) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_outlined, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Knowledge & Training Hub',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'English & हिंदी / Hinglish',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Master client calling scripts, objection rebuttals, service scopes & operational SOPs',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            if (role == UserRole.admin)
              ElevatedButton.icon(
                onPressed: () => _showAddTopicModal(context, isDark),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Guide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Refresh Learning Topics',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<LearningBloc>().add(LoadLearningTopics(
                      category: _selectedCategory == 'all' ? null : _selectedCategory,
                      search: _searchController.text.trim().isEmpty
                          ? null
                          : _searchController.text.trim(),
                    ));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 820;

        final searchWidget = SizedBox(
          width: isNarrow ? double.infinity : 360,
          height: 42,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search scripts, objections, tips in Hindi / English...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey500,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.grey300,
                ),
              ),
            ),
          ),
        );

        final categoriesWidget = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _categoryChip('All Topics', 'all', isDark),
              const SizedBox(width: 6),
              _categoryChip('📞 Sales Pitch', 'salesPitch', isDark),
              const SizedBox(width: 6),
              _categoryChip('🛡️ Objections & Rebuttals', 'objectionHandling', isDark),
              const SizedBox(width: 6),
              _categoryChip('📋 8 Services Scope', 'serviceScope', isDark),
              const SizedBox(width: 6),
              _categoryChip('🔍 Sourcing SOP', 'sourcingVerification', isDark),
              const SizedBox(width: 6),
              _categoryChip('🚗 Field SOP', 'fieldSop', isDark),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchWidget,
              const SizedBox(height: 10),
              categoriesWidget,
            ],
          );
        }

        return Row(
          children: [
            searchWidget,
            const SizedBox(width: 16),
            Expanded(child: categoriesWidget),
          ],
        );
      },
    );
  }

  Widget _categoryChip(String label, String value, bool isDark) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _onCategoryChanged(value),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold
                : (isDark ? AppColors.darkSurfaceVariant : AppColors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.gold
                  : (isDark ? AppColors.dividerDark : AppColors.grey300),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppColors.navyBlue
                  : (isDark ? AppColors.grey200 : AppColors.grey800),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            'Script Language:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
          const SizedBox(width: 10),
          _langButton('🇬🇧 English Script', 'english', isDark),
          const SizedBox(width: 8),
          _langButton('🇮🇳 हिंदी / Hinglish Script', 'hindi', isDark),
        ],
      ),
    );
  }

  Widget _langButton(String label, String value, bool isDark) {
    final isSelected = _selectedLanguage == value;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = value),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.navyBlue
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.grey100),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : (isDark ? AppColors.dividerDark : AppColors.grey300),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppColors.gold
                : (isDark ? AppColors.grey300 : AppColors.grey800),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsList(List<LearningTopicModel> list, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final topic = list[index];
        return _buildTopicCard(topic, isDark);
      },
    );
  }

  Widget _buildTopicCard(LearningTopicModel topic, bool isDark) {
    final showEnglish = _selectedLanguage != 'hindi' &&
        topic.scriptEnglish != null &&
        topic.scriptEnglish!.isNotEmpty;
    final showHindi = _selectedLanguage != 'english' &&
        topic.scriptHindi != null &&
        topic.scriptHindi!.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.grey200,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge & Title Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(topic.category).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    topic.category.displayName.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: _getCategoryColor(topic.category),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (topic.targetRole != 'all')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Role: ${topic.targetRole.toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              topic.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            Text(
              topic.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),

            // English Script Box
            if (showEnglish) ...[
              _buildScriptBox(
                title: '🇬🇧 English Script / Pitch',
                content: topic.scriptEnglish!,
                color: AppColors.standardBlue,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
            ],

            // Hindi / Hinglish Script Box
            if (showHindi) ...[
              _buildScriptBox(
                title: '🇮🇳 हिंदी / Hinglish Script (Conversational)',
                content: topic.scriptHindi!,
                color: AppColors.successGreen,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
            ],

            // Key Tip Banner
            if (topic.keyTip != null && topic.keyTip!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '💡 Pro Tip for Client Call: ',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.gold : AppColors.navyBlue,
                          ),
                          children: [
                            TextSpan(
                              text: topic.keyTip!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: isDark ? AppColors.grey300 : AppColors.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Bullet Points / Checklist
            if (topic.bulletPoints.isNotEmpty) ...[
              Text(
                'Key Action Points & Checklist:',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.grey400 : AppColors.grey700,
                ),
              ),
              const SizedBox(height: 6),
              ...topic.bulletPoints.map((bp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4, right: 6),
                        child: Icon(Icons.check_circle_outline, size: 14, color: AppColors.successGreen),
                      ),
                      Expanded(
                        child: Text(
                          bp,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? AppColors.grey300 : AppColors.grey800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],

            // Tags
            if (topic.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: topic.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isDark ? AppColors.grey400 : AppColors.grey600,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptBox({
    required String title,
    required String content,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard(content, title),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        'Copy Script',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: isDark ? AppColors.white : AppColors.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text(
              'No training topics found matching your filter.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.navyBlue,
              ),
            ),
            Text(
              'Try changing your search keywords or switching category.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(LearningCategory cat) {
    switch (cat) {
      case LearningCategory.salesPitch:
        return AppColors.standardBlue;
      case LearningCategory.objectionHandling:
        return AppColors.criticalRed;
      case LearningCategory.serviceScope:
        return AppColors.gold;
      case LearningCategory.sourcingVerification:
        return AppColors.successGreen;
      case LearningCategory.fieldSop:
        return AppColors.urgentAmber;
    }
  }

  void _showAddTopicModal(BuildContext context, bool isDark) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final englishScriptController = TextEditingController();
    final hindiScriptController = TextEditingController();
    final tipController = TextEditingController();
    LearningCategory selectedCategory = LearningCategory.salesPitch;
    String targetRole = 'all';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Dialog(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Training Guide / Script',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.navyBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Topic Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(labelText: 'Subtitle / Objective'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LearningCategory>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: LearningCategory.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: englishScriptController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'English Script / Pitch'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: hindiScriptController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'हिंदी / Hinglish Script'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tipController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Key Tip for Customer Call'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty) return;
                            final newTopic = LearningTopicModel(
                              id: 'LRN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              title: titleController.text.trim(),
                              subtitle: subtitleController.text.trim(),
                              category: selectedCategory,
                              targetRole: targetRole,
                              scriptEnglish: englishScriptController.text.trim(),
                              scriptHindi: hindiScriptController.text.trim(),
                              keyTip: tipController.text.trim(),
                              bulletPoints: const [],
                              tags: const ['Custom Guide'],
                            );
                            context.read<LearningBloc>().add(CreateLearningTopicEvent(newTopic));
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navyBlue,
                          ),
                          child: const Text('Save to Database'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).then((_) {
      titleController.dispose();
      subtitleController.dispose();
      englishScriptController.dispose();
      hindiScriptController.dispose();
      tipController.dispose();
    });
  }
}
