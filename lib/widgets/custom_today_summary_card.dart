import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/helper_activities.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTodaySummaryCard extends StatefulWidget {
  final Color colorSummaryBody;

  final Color colorSummaryTitle;
  final String title;
  final String babyID;
  final String firstName;

  const CustomTodaySummaryCard({
    super.key,
    required this.colorSummaryBody,
    required this.colorSummaryTitle,
    required this.title,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomTodaySummaryCard> createState() => _CustomTodaySummaryCardState();
}

class _CustomTodaySummaryCardState extends State<CustomTodaySummaryCard> {
  @override
  void initState() {
    context.read<ActivityBloc>().add(
      LoadActivitiesWithDate(babyID: widget.babyID, day: DateTime.now()),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomTodaySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.babyID != widget.babyID) {
      context.read<ActivityBloc>().add(
        LoadActivitiesWithDate(babyID: widget.babyID, day: DateTime.now()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivitiesWithDateLoaded) {
          final totalFeedAmount = calculateTotalFeedAmount(
            state.feedActivities,
          );
          final totalFeedUnit = getFeedUnit(state.feedActivities);
          final sleptFormatted = formatSleepDuration(state.sleepActivities);
          final totalPumpAmount = calculateTotalPumpAmount(
            state.pumpActivities,
          );
          final totalPumpUnit = getPumpUnit(state.pumpActivities);
          final totalDiaper = summarizeDiaperTypes(state.diaperActivities);
          return Card(
            color: widget.colorSummaryBody,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 2.r,
                  ),
                  decoration: BoxDecoration(
                    color: widget.colorSummaryTitle,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        context.tr('today_summary'),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),

                // Today Summary Body
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFeedActivity(
                        context.tr('feed'),
                        'assets/images/feed_icon.png',
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.tr('total:'),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  totalFeedAmount.toString(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  totalFeedUnit.toString(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            Text(
                              '${state.feedActivities.length} ${context.tr('times')}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        state.feedActivities,
                      ),
                      SizedBox(width: 20.w),
                      _buildFeedActivity(
                        context.tr('sleep'),
                        'assets/images/sleep_icon.png',
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  sleptFormatted!,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            Text(
                              '${state.sleepActivities.length} ${context.tr('times slept.')}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        state.sleepActivities,
                      ),
                      SizedBox(width: 20.w),
                      _buildFeedActivity(
                        context.tr("diaper"),
                        'assets/images/diaper_icon.png',
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  totalDiaper!,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            Text(
                              '${state.diaperActivities.length} ${context.tr("times changed.")}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        state.diaperActivities,
                      ),
                      SizedBox(width: 20.w),
                      _buildFeedActivity(
                        context.tr('pump'),
                        'assets/images/pump_icon.png',
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.tr("total:"),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  totalPumpAmount.toString(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  totalPumpUnit.toString(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            Text(
                              '${state.pumpActivities.length} ${context.tr("times")}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        state.pumpActivities,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is ActivityLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return const SizedBox(); // ya da boş Container()
        }
      },
    );
  }

  Widget _buildFeedActivity(
    String title,
    String imgUrl,
    Widget bodyContext,
    List<ActivityModel> activities,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30.w, // avatar çapı kadar
            height: 30.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(150),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(1.r),
              child: Image.asset(imgUrl, fit: BoxFit.contain),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          activities.isEmpty
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '😴 ${context.tr('no_data')}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : bodyContext,
        ],
      ),
    );
  }
}
