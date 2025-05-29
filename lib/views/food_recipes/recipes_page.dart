import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/food_recipes/recipe_detail_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/recipe/recipe_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/recipe_model.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> with TickerProviderStateMixin {
  Map<String, List<RecipeModel>> grouped = {};
  List<RecipeModel> filteredRecipes = [];
  String? selectedAgeGroup;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  void _filterRecipes(String? ageGroupKey) {
    setState(() {
      selectedAgeGroup = ageGroupKey;
      if (ageGroupKey == null) {
        filteredRecipes = grouped.values.expand((list) => list).toList();
      } else {
        filteredRecipes = grouped[ageGroupKey] ?? [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    context.read<RecipeBloc>().add(LoadRecipe());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F5F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade400,
                              Colors.deepPurple.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('baby_recipes'),

                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Healthy meals for your little one'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<RecipeBloc, RecipeState>(
                builder: (context, state) {
                  if (state is RecipeLoading) {
                    return _buildLoadingState();
                  } else if (state is RecipeLoaded) {
                    grouped = _groupByAgeGroup(state.recipes);
                    if (filteredRecipes.isEmpty) {
                      filteredRecipes = state.recipes;
                    }
                    _animationController.forward();

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Filter Buttons
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: _buildAgeFilterButtons(grouped.keys.toList()),
                          ),

                          SizedBox(height: 8.h),

                          // Recipe List
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: filteredRecipes.length,
                              itemBuilder: (context, index) {
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 300 + (index * 100)),
                                  curve: Curves.easeOutBack,
                                  child: _buildModernCard(context, filteredRecipes[index], index),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return _buildEmptyState();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F5F5),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading delicious recipes...'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.restaurant_menu_outlined,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No recipes found'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<RecipeModel>> _groupByAgeGroup(List<RecipeModel> recipes) {
    return recipes.fold({}, (Map<String, List<RecipeModel>> acc, recipe) {
      acc.putIfAbsent(recipe.ageGroupKey, () => []).add(recipe);
      return acc;
    });
  }

  Widget _buildAgeFilterButtons(List<String> ageGroupKeys) {
    final pastelColors = [
      const Color(0xFFFFE5E5), const Color(0xFFE5F3FF), const Color(0xFFE5FFE5),
      const Color(0xFFFFF5E5), const Color(0xFFF5E5FF), const Color(0xFFE5FFFF),
      const Color(0xFFFFFDE5), const Color(0xFFFFE5F5),
    ];

    return SizedBox(
      height: 32.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: ageGroupKeys.length + 1,
        itemBuilder: (context, index) {
          final key = index == 0 ? null : ageGroupKeys[index - 1];
          final label = index == 0 ? "All".tr() : key!.tr();
          final isSelected = selectedAgeGroup == key;
          final pastelColor = pastelColors[index % pastelColors.length];

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: InkWell(
              borderRadius: BorderRadius.circular(18.r),
              onTap: () => _filterRecipes(key),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  color: isSelected ? Colors.deepPurple : pastelColor,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildModernCard(BuildContext context, RecipeModel recipe, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: Material(
        borderRadius: BorderRadius.circular(20.r),
        elevation: 4,
        shadowColor: Colors.grey.shade200,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    RecipeDetailPage(recipe: recipe),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: const Color(0xFFF6F5F5),
            ),
            child: Row(
              children: [
                // Recipe Image
                Hero(
                  tag: 'recipe_${recipe.titleKey}_$index',
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        recipe.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Recipe Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.titleKey.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),

                      // Age Group
                      Text(
                        recipe.ageGroupKey.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Time Info - Satır Satır
                      _buildTimeChip(
                        Icons.timer_outlined,
                        recipe.prepTimeKey.tr(),
                        Colors.orange.shade100,
                        Colors.orange.shade600,
                      ),
                      SizedBox(height: 4.h),
                      _buildTimeChip(
                        Icons.local_fire_department_outlined,
                        recipe.cookTimeKey.tr(),
                        Colors.red.shade100,
                        Colors.red.shade600,
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.deepPurple.shade400,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTimeChip(IconData icon, String time, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: textColor,
          ),
          SizedBox(width: 3.w),
          Text(
            time,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}