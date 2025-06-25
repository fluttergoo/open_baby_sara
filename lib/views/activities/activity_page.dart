import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/sleep_timer/sleep_timer_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/auth/auth_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/shared_prefs_helper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_baby_firsts_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_diaper_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_doctor_visit_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_feed_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_fever_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_growth_development_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_medical_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_sleep_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_teething_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_vaccination_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_baby_header_card.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_card.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_pump_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_today_summary_card.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/customize_growth_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<BabyModel> babiesList = [];
  String? firstName;

  bool isSleepActivityRunning = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BabyBloc>().add(LoadBabies());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          firstName = state.userModel.firstName;
        }
        return BlocListener<BabyBloc, BabyState>(
          listenWhen: (previous, current) => current is BabyLoaded,
          listener: (context, state) async {
            if (state is BabyLoaded) {
              final savedID = await SharedPrefsHelper.getSelectedBabyID();
              if (savedID != null) {
                final alreadySelected = state.selectedBaby?.babyID == savedID;
                if (!alreadySelected) {
                  final matched = state.babies.firstWhere(
                    (b) => b.babyID == savedID,
                    orElse: () => state.babies.first,
                  );
                  context.read<BabyBloc>().add(
                    SelectBaby(selectBabyModel: matched),
                  );
                }
              }
            }
          },
          child: BlocBuilder<SleepTimerBloc, SleepTimerState>(
            builder: (context, state) {
              if (state is TimerRunning) {
                isSleepActivityRunning = true;
              }
              return BlocBuilder<BabyBloc, BabyState>(
                builder: (context, state) {
                  if (state is BabyLoaded) {
                    babiesList = state.babies;
                  }
                  return state is BabyLoading
                      ? Center(child: CircularProgressIndicator())
                      : Scaffold(
                        resizeToAvoidBottomInset: true,
                        body: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 8.h,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ///
                                  /// Avatar Image, Age, 3 dots.
                                  ///
                                  CustomBabyHeaderCard(babiesList: babiesList),

                                  ///
                                  /// Today Summary
                                  ///
                                  SizedBox(
                                    width: double.infinity,
                                    // height: 125.h,
                                    child: CustomTodaySummaryCard(
                                      colorSummaryTitle:
                                          AppColors.summaryHeader,
                                      colorSummaryBody: AppColors.summaryBody,
                                      title: 'title',
                                      babyID:
                                          state is BabyLoaded
                                              ? state.selectedBaby!.babyID
                                              : '',
                                      firstName: firstName ?? '',
                                    ),
                                  ),

                                  SizedBox(height: 10.h),

                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      context.tr("track_new_activity"),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
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
                                        title: context.tr("feed"),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl: 'assets/images/feed_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomFeedTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
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
                                        title: context.tr("pump"),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl: 'assets/images/pump_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomPumpTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
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
                                        title: context.tr("diaper"),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl: 'assets/images/diaper_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomDiaperTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
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
                                        title: context.tr('sleep'),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl: 'assets/images/sleep_icon.png',
                                        isActivityRunning: isSleepActivityRunning,
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomSleepTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
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
                                      context.tr('growth_development'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 10.h),

                                  ///
                                  /// Growth and Development
                                  ///
                                  SizedBox(
                                    width: double.infinity,
                                    height: 100.h,
                                    child: CustomizeGrowthCard(
                                      color: AppColors.growthColor,
                                      title: 'Weight',
                                      babyID:
                                          state is BabyLoaded
                                              ? state.selectedBaby!.babyID
                                              : '',
                                      firstName: firstName ?? '',
                                      imgUrl: 'assets/images/growth_icon.png',
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
                                                  CustomGrowthDevelopmentTrackerBottomSheet(
                                                    babyID:
                                                        state is BabyLoaded
                                                            ? state
                                                                .selectedBaby!
                                                                .babyID
                                                            : '',
                                                    firstName: firstName ?? '',
                                                  ),
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(height: 5.h),

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
                                        color: AppColors.babyFirstsColor,
                                        title: context.tr('baby_firsts'),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl:
                                            'assets/images/baby_firsts_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomBabyFirstsTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
                                                    ),
                                          );
                                          // showSleepTrackerBottomSheet(context);
                                        },
                                      ),

                                      ///
                                      /// Pump Activity
                                      ///
                                      CustomCard(
                                        color: AppColors.teethingColor,
                                        title: context.tr('teething'),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl:
                                            'assets/images/teething_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomTeethingTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
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
                                      context.tr('health'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),

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
                                        color: AppColors.medicalColor,
                                        title: context.tr('medication'),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl:
                                            'assets/images/medication_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomMedicalTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
                                                    ),
                                          );
                                          // showSleepTrackerBottomSheet(context);
                                        },
                                      ),

                                      ///
                                      /// Pump Activity
                                      ///
                                      CustomCard(
                                        color: AppColors.doctorVisitColor,
                                        title: context.tr('doctor_visit'),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl:
                                            'assets/images/doctor_visit_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomDoctorVisitTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
                                                    ),
                                          );
                                          // showSleepTrackerBottomSheet(context);
                                        },
                                      ),

                                      CustomCard(
                                        color: AppColors.vaccineColor,
                                        title: context.tr('vaccination'),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl:
                                            'assets/images/vaccine_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomVaccinationTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
                                                    ),
                                          );
                                          // showSleepTrackerBottomSheet(context);
                                        },
                                      ),

                                      CustomCard(
                                        color: AppColors.feverTrackerColor,
                                        title: context.tr('fever'),
                                        babyID:
                                            state is BabyLoaded
                                                ? state.selectedBaby!.babyID
                                                : '',
                                        firstName: firstName ?? '',
                                        imgUrl: 'assets/images/fever_icon.png',
                                        voidCallback: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomFeverTrackerBottomSheet(
                                                      babyID:
                                                          state is BabyLoaded
                                                              ? state
                                                                  .selectedBaby!
                                                                  .babyID
                                                              : '',
                                                      firstName:
                                                          firstName ?? '',
                                                    ),
                                          );
                                          // showSleepTrackerBottomSheet(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                },
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
