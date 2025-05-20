import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/activity_constants.dart';
import 'package:flutter_sara_baby_tracker_and_sound/views/history/widgets/activity_card_details.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/helper_activities.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/shared_prefs_helper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                      Text(
                        " Activity Timeline",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      BlocBuilder<ActivityBloc, ActivityState>(
                        builder: (context, state) {
                          if (state is ActivityLoading) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is ActivityByDateRangeLoaded) {
                            final activities = state.activities;
                            if (activities.isEmpty) {
                              return Center(
                                child: Text("No activities found."),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: activities.length,
                              itemBuilder: (context, index) {
                                final activity = activities[index];
                                final activityDayStr = activity.data['activityDay'] as String?;
                                final activityDay = activityDayStr != null
                                    ? DateTime.tryParse(activityDayStr)
                                    : null;

                                final formattedDate = activityDay != null
                                    ? DateFormat('MMM d').format(activityDay)
                                    : '--';

                                final formattedTime = activityDay != null
                                    ? DateFormat('h:mm a').format(activityDay)
                                    : '';

                                final iconKey = activityIconMap[activity.activityType] ?? 'default';
                                final iconPath = 'assets/icons/$iconKey.png';

                                final summary = getActivitySummary(activity,context);

                                return ActivityCardDetails(
                                  activity: activity,
                                  summary: summary,
                                  iconPath: iconPath,
                                );
                              },
                            );
                          } else if (state is ActivityError) {
                            return Center(child: Text(state.message));
                          } else {
                            return SizedBox.shrink();
                          }
                        },
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
}
