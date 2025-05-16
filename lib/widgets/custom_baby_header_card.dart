import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/shared_prefs_helper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_avatar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CustomBabyHeaderCard extends StatelessWidget {
  final List<BabyModel> babiesList;

  const CustomBabyHeaderCard({
    super.key,
    required this.babiesList,
  });

  String calculateBabyAge(DateTime birthDate) {
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return "0 day";

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      final lastDay = DateTime(now.year, now.month, 0).day;
      days += lastDay;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    int totalMonths = years * 12 + months;
    String age = '';
    if (totalMonths > 0) age += '$totalMonths month${totalMonths > 1 ? 's' : ''}';
    if (days > 0) {
      if (age.isNotEmpty) age += ' ';
      age += '$days day${days > 1 ? 's' : ''}';
    }
    return age.isEmpty ? '0 day' : age;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BabyBloc>().state;
    final selectedBaby = state is BabyLoaded ? state.selectedBaby : null;

    final ThemeData theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final lightPrimaryColor = Color(0xFFE9F6EF); // Light mint green color

    return Column(
      children: [
        // Top section with avatar and baby info
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            children: [
              // Avatar with decorative circle behind it
              CustomAvatar(
                size: 60.sp,
                imageUrl: selectedBaby?.imageUrl,
              ),

              SizedBox(width: 5.w),

              // Baby info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baby name with dropdown
                    DropdownButtonHideUnderline(
                      child: DropdownButton<BabyModel>(
                        key: ValueKey(selectedBaby?.babyID),
                        value: selectedBaby,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                        items: babiesList.map((baby) {
                          return DropdownMenuItem(
                            value: baby,
                            child: Text(
                              baby.firstName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newBaby) async {
                          if (newBaby != null) {
                            context.read<BabyBloc>().add(SelectBaby(selectBabyModel: newBaby));
                            await SharedPrefsHelper.saveSelectedBabyID(newBaby.babyID);
                          }
                        },
                      ),
                    ),

                    // Age info with cute baby icon
                    Row(
                      children: [
                        Text(
                          'Age:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          state is BabyLoaded
                              ? calculateBabyAge(state.selectedBaby!.dateTime)
                              : 'unknown',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w,),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_horiz_outlined,
                  // color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Action buttons
        /*Container(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.today_outlined,
                label: 'Calendar',
                onTap: () {},
              ),
              _buildVerticalDivider(),
              _buildActionButton(
                context,
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
                onTap: () {},
              ),
              _buildVerticalDivider(),
              _buildActionButton(
                context,
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () {},
              ),
              _buildVerticalDivider(),
              _buildActionButton(
                context,
                icon: Icons.more_horiz,
                label: 'More',
                onTap: () {},
              ),
            ],
          ),
        ),*/
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 22.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24.h,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }
}
