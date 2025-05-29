import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> with TickerProviderStateMixin {
  final List<String> _faqKeys = const [
    "faq_what_is_baby_sara",
    "faq_track_activities",
    "faq_multiple_babies",
    "faq_add_caregiver",
    "faq_caregiver",
    "faq_reset_password",
    "faq_recipes_feature",
    "faq_sounds_feature",
    "faq_data_backup",
    "faq_data_security",
    "faq_contact_support",
  ];

  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredFaqKeys = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _filteredFaqKeys = _faqKeys;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterFaqs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFaqKeys = _faqKeys;
      } else {
        _filteredFaqKeys = _faqKeys.where((key) {
          final question = "${key}_question".tr().toLowerCase();
          final answer = "${key}_answer".tr().toLowerCase();
          return question.contains(query.toLowerCase()) ||
              answer.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5E6E8),
              Color(0xFFF6F5F5),
              Color(0xFFE8F4F8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Back Button and Title Row
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "faq_title".tr(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "faq_subtitle".tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          style: Theme.of(context).textTheme.titleMedium,
                          controller: _searchController,
                          onChanged: _filterFaqs,
                          decoration: InputDecoration(
                            labelStyle: Theme.of(context).textTheme.titleSmall,
                            hintText: context.tr('search'),
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 16,
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.search_rounded,
                                color: Color(0xFF6B7280),
                                size: 24,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterFaqs('');
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                color: Color(0xFF6B7280),
                              ),
                            )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // FAQ List
                Expanded(
                  child: _filteredFaqKeys.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredFaqKeys.length,
                    itemBuilder: (context, index) {
                      final key = _filteredFaqKeys[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildFaqCard(key, index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard(String key, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF6B9D).withOpacity(0.2),
                          Color(0xFF4ECDC4).withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForFaq(key),
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    "${key}_question".tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      height: 1.4,
                    ),
                  ),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "${key}_answer".tr(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475569),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "no_results_found".tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "try_different_keywords".tr(),
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForFaq(String key) {
    switch (key) {
      case "faq_reset_password":
        return Icons.lock_reset_rounded;
      case "faq_multiple_babies":
        return Icons.family_restroom_rounded;
      case "faq_track_activities":
        return Icons.track_changes_rounded;
      case "faq_recipes_feature":
        return Icons.restaurant_menu_rounded;
      case "faq_sounds_feature":
        return Icons.music_note_rounded;
      case "faq_data_security":
        return Icons.security_rounded;
      case "faq_data_backup":
        return Icons.backup_rounded;
      case "faq_contact_support":
        return Icons.support_agent_rounded;
      case "faq_caregiver":
        return Icons.person_add_rounded;
      case "faq_add_caregiver":
        return Icons.group_add_rounded;
      case "faq_what_is_baby_sara":
        return Icons.info_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}