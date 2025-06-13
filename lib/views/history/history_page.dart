import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_baby_firsts_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_diaper_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_doctor_visit_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_feed_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_fever_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_growth_development_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_medical_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_pump_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_sleep_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_teething_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/bottom_sheets/custom_vaccination_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/activity_constants.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/helper_activities.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/shared_prefs_helper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/history/widgets/activity_card_details.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/history/widgets/custom_baby_timeline_header_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BabyModel> babiesList = [];

  @override
  void initState() {
    super.initState();
    context.read<BabyBloc>().add(LoadBabies());
  }

  @override
  Widget build(BuildContext context) {
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
      child: BlocBuilder<BabyBloc, BabyState>(
        builder: (context, state) {
          if (state is BabyLoaded) {
            babiesList = state.babies;
          }
          return state is BabyLoading
              ? const Center(child: CircularProgressIndicator())
              : Scaffold(
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
                          CustomBabyTimelineHeaderCard(
                            babiesList: babiesList,
                            onFilterChanged: (
                              startDateTime,
                              endDateTime,
                              activityFilter,
                              babyID,
                            ) {
                              if (startDateTime != null &&
                                  endDateTime != null &&
                                  babyID != null) {
                                context.read<ActivityBloc>().add(
                                  LoadActivitiesByDateRange(
                                    startDay: startDateTime,
                                    endDay: endDateTime,
                                    babyID: babyID,
                                    activityType: activityFilter,
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 10.h),
                          Center(
                            child: Text(
                              context.tr('activity_timeline'),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          BlocListener<ActivityBloc, ActivityState>(
                            listener: (context, state) {
                              if (state is ActivityDeleted) {
                                showCustomFlushbar(
                                  context,
                                  context.tr('activity_deleted'),
                                  context.tr('activity_deleted_body'),
                                  Icons.delete_forever_outlined,
                                );
                                context.read<BabyBloc>().add(LoadBabies());
                              }
                            },
                            child: BlocBuilder<ActivityBloc, ActivityState>(
                              builder: (context, state) {
                                if (state is ActivityLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (state is ActivityByDateRangeLoaded) {
                                  final activities = state.activities;
                                  if (activities.isEmpty) {
                                    return Center(
                                      child: Text(
                                        context.tr('no_activities_found'),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: activities.length,
                                    itemBuilder: (context, index) {
                                      final activity = activities[index];
                                      final iconKey =
                                          activityIconMap[activity
                                              .activityType] ??
                                          'default';
                                      final iconPath =
                                          'assets/icons/$iconKey.png';
                                      final summary = getActivitySummary(
                                        activity,
                                        context,
                                      );

                                      return ActivityCardDetails(
                                        activity: activity,
                                        summary: summary,
                                        iconPath: iconPath,
                                        onDelete: () {
                                          context.read<ActivityBloc>().add(
                                            DeleteActivity(
                                              babyID: activity.babyID,
                                              activityID: activity.activityID,
                                            ),
                                          );
                                        },
                                        onEdit: () {
                                          _updateActivity(activity);
                                        },
                                      );
                                    },
                                  );
                                } else if (state is ActivityError) {
                                  return Center(child: Text(state.message));
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
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
  }

  void _updateActivity(ActivityModel activityModel) {
    final activityType = activityModel.activityType;

    if (activityType == ActivityType.babyFirsts.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomBabyFirstsTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    } else if (activityType == ActivityType.bottleFeed.name || activityType== ActivityType.breastFeed.name ) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomFeedTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    } else if (activityType == ActivityType.doctorVisit.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomDoctorVisitTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    } else if (activityType == ActivityType.vaccination.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomVaccinationTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    } else if (activityType== ActivityType.fever.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomFeverTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    } else if (activityType == ActivityType.medication.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomMedicalTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    } else if (activityType==ActivityType.teething.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomTeethingTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    }   else if (activityType == ActivityType.growth.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomGrowthDevelopmentTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    }
    else if (activityType==ActivityType.diaper.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomDiaperTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    }  else if (activityType==ActivityType.pumpTotal.name || activityType == ActivityType.pumpLeftRight.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomPumpTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    }  else if (activityType== ActivityType.sleep.name) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => CustomSleepTrackerBottomSheet(
          babyID: activityModel.babyID,
          firstName: activityModel.createdBy ?? '',
          isEdit: true,
          existingActivity: activityModel,
        ),
      );
    }  else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Unsupported'),
          content: Text('Editing this activity is not supported yet.'),
        ),
      );
    }
  }
}
