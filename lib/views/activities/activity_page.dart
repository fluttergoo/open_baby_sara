import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_diaper_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_sleep_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_avatar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_card.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_pump_tracker_bottom_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<BabyModel> babiesList = [];
  String? babyID;
  String? firstName;

  @override
  void initState() {
    super.initState();
    context.read<BabyBloc>().add(LoadBabies());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          firstName = state.userModel.firstName;
        }
        return BlocListener<BabyBloc, BabyState>(
          listener: (context, state) {},
          child: BlocBuilder<BabyBloc, BabyState>(
            builder: (context, state) {
              if (state is BabyLoaded) {
                babiesList = state.babies;
                babyID = state.selectedBaby!.babyID;
                if (babyID != null) {
                  context.read<ActivityBloc>().add(
                    FetchActivitySleepLoad(babyID: babyID!),
                  );
                  context.read<ActivityBloc>().add(
                    FetchActivityPumpLoad(babyID: babyID!),
                  );
                }
              }
              return Scaffold(
                resizeToAvoidBottomInset: true,
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///
                          /// Avatar Image, Age, 3 dots.
                          ///
                          Row(
                            children: [
                              CustomAvatar(
                                size: 60.sp,
                                imageUrl:
                                    state is BabyLoaded
                                        ? state.selectedBaby?.imageUrl
                                        : null,
                              ),
                              SizedBox(width: 2.h),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButton<BabyModel>(
                                    value:
                                        state is BabyLoaded
                                            ? state.selectedBaby
                                            : null,
                                    items:
                                        babiesList.map((baby) {
                                          return DropdownMenuItem(
                                            value: baby,
                                            child: Text(baby.firstName),
                                          );
                                        }).toList(),
                                    onChanged: (newBaby) {
                                      if (newBaby != null) {
                                        context.read<BabyBloc>().add(
                                          SelectBaby(selectBabyModel: newBaby),
                                        );
                                      }
                                    },
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall!.copyWith(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  RichText(
                                    text: TextSpan(
                                      text: 'Age: ',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall!.copyWith(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              state is BabyLoaded
                                                  ? calculateBabyAge(
                                                    state
                                                        .selectedBaby!
                                                        .dateTime,
                                                  )
                                                  : 'unknown',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall!.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.today_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.more_horiz_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),

                          ///
                          /// Today Summary
                          ///
                          SizedBox(
                            width: double.infinity,
                            height: 120.h,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Today\'s Summary',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(DateTime.now()),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.h),
                                    SizedBox(
                                      height: 60.h,
                                      child: ListView.separated(
                                        itemBuilder: (context, index) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons
                                                    .baby_changing_station_outlined,
                                                size: 28.sp,
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                '6 Times',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder:
                                            (_, __) => SizedBox(width: 25.w),
                                        itemCount: 10,
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Track New Activity',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          ///
                          /// Track New Activity
                          ///
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 6.w,
                            mainAxisSpacing: 6.h,
                            childAspectRatio: 1.6,
                            children: [
                              ///
                              /// Feed Activity
                              ///
                              CustomCard(
                                color: AppColors.feedColor,
                                title: 'Feed',
                                babyID: babyID ?? '',
                                firstName: firstName ?? '',
                                imgUrl: 'assets/images/feed_icon.png',
                                voidCallback: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r),
                                      ),
                                    ),
                                    builder:
                                        (context) =>
                                            CustomSleepTrackerBottomSheet(
                                              babyID: babyID ?? '',
                                              firstName: firstName ?? '',
                                            ),
                                  );
                                  // showSleepTrackerBottomSheet(context);
                                },
                              ),

                              ///
                              /// Pump Activity
                              ///
                              CustomCard(
                                color: AppColors.pumpColor,
                                title: 'Pump',
                                babyID: babyID ?? '',
                                firstName: firstName ?? '',
                                imgUrl: 'assets/images/pump_icon.png',
                                voidCallback: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r),
                                      ),
                                    ),
                                    builder:
                                        (context) =>
                                            CustomPumpTrackerBottomSheet(
                                              babyID: babyID ?? '',
                                              firstName: firstName ?? '',
                                            ),
                                  );
                                  // showSleepTrackerBottomSheet(context);
                                },
                              ),

                              ///
                              /// Diaper Activity
                              ///
                              CustomCard(
                                color: AppColors.diaperColor,
                                title: 'Diaper',
                                babyID: babyID ?? '',
                                firstName: firstName ?? '',
                                imgUrl: 'assets/images/diaper_icon.png',
                                voidCallback: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r),
                                      ),
                                    ),
                                    builder:
                                        (context) =>
                                            CustomDiaperTrackerBottomSheet(
                                              babyID: babyID ?? '',
                                              firstName: firstName ?? '',
                                            ),
                                  );
                                  // showSleepTrackerBottomSheet(context);
                                },

                              ),

                              ///
                              /// Sleep Activity
                              ///
                              CustomCard(
                                color: AppColors.sleepColor,
                                title: 'Sleep',
                                babyID: babyID ?? '',
                                firstName: firstName ?? '',
                                imgUrl: 'assets/images/sleep_icon.png',
                                voidCallback: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r),
                                      ),
                                    ),
                                    builder:
                                        (context) =>
                                            CustomSleepTrackerBottomSheet(
                                              babyID: babyID ?? '',
                                              firstName: firstName ?? '',
                                            ),
                                  );
                                  // showSleepTrackerBottomSheet(context);
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),

                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Growth & Development',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          ///
                          /// Growth and Development
                          ///
                          SizedBox(
                            width: double.infinity,
                            height: 80.h,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ListView.separated(
                                        itemBuilder: (context, index) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Weight',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                '6 Times',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder:
                                            (_, __) => SizedBox(width: 25.w),
                                        itemCount: 10,
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: double.infinity,
                            height: 80.h,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ListView.separated(
                                        itemBuilder: (context, index) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Weight',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                '6 Times',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder:
                                            (_, __) => SizedBox(width: 25.w),
                                        itemCount: 10,
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        );
      },
    );
  }

  String calculateBabyAge(DateTime birthDate) {
    debugPrint(birthDate.toString());
    final now = DateTime.now();

    if (birthDate.isAfter(now)) {
      return "0 day";
    }

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      final lastDayOfPreviousMonth = DateTime(now.year, now.month, 0).day;
      days += lastDayOfPreviousMonth;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    int totalMonths = years * 12 + months;

    String age = '';
    if (totalMonths > 0) {
      age += '$totalMonths month${totalMonths > 1 ? 's' : ''}';
    }

    if (days > 0) {
      if (age.isNotEmpty) age += ' ';
      age += '$days day${days > 1 ? 's' : ''}';
    }

    return age.isEmpty ? '0 day' : age;
  }
}
