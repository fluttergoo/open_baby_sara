import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/core/utils/helper_activities.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
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

  /// Builds the smart insight sentence shown at the top of the card.
  String _buildInsightSentence(
    ActivitiesWithDateLoaded state,
    BuildContext context,
  ) {
    final hasFeed = state.feedActivities.isNotEmpty;
    final hasSleep = state.sleepActivities.isNotEmpty;
    final hasAnyActivity =
        hasFeed ||
        hasSleep ||
        state.diaperActivities.isNotEmpty ||
        state.pumpActivities.isNotEmpty ||
        state.medicationActivities.isNotEmpty ||
        state.feverActivities.isNotEmpty ||
        state.vaccinationActivities.isNotEmpty ||
        state.doctorVisitActivities.isNotEmpty;

    if (!hasAnyActivity) {
      return context.tr('today_insight_empty');
    }

    if (hasFeed && hasSleep) {
      return context.tr(
        'today_insight_feed_sleep',
        namedArgs: {
          'name': widget.firstName,
          'feedCount': state.feedActivities.length.toString(),
          'sleepDuration': formatSleepDuration(state.sleepActivities),
        },
      );
    }

    if (hasFeed) {
      return context.tr(
        'today_insight_feed_only',
        namedArgs: {
          'name': widget.firstName,
          'feedCount': state.feedActivities.length.toString(),
        },
      );
    }

    if (hasSleep) {
      return context.tr(
        'today_insight_sleep_only',
        namedArgs: {
          'name': widget.firstName,
          'sleepDuration': formatSleepDuration(state.sleepActivities),
        },
      );
    }

    return context.tr('today_insight_empty');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      buildWhen: (previous, current) {
        // Only rebuild when today's activities are loaded.
        // ActivityLoading is excluded to prevent teething/other bottom sheets
        // from triggering a loading spinner on this card.
        return current is ActivitiesWithDateLoaded;
      },
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
          final totalDiaper = summarizeDiaperTypes(
            state.diaperActivities,
            context,
          );

          final insightSentence = _buildInsightSentence(state, context);
          final locale = context.locale.toLanguageTag();

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
                        DateFormat.yMMMd(locale).format(DateTime.now()),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Smart insight sentence
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  child: Text(
                    insightSentence,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ),

                // Today Summary Body
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActivityColumn(
                        title: context.tr('feed'),
                        imgUrl: 'assets/images/feed_icon.png',
                        noDataEmoji: '🍼',
                        activities: state.feedActivities,
                        bodyWidget: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.tr('total:'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontSize: 12.sp),
                                ),
                                Text(
                                  totalFeedAmount.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontSize: 12.sp),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  totalFeedUnit,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontSize: 12.sp),
                                ),
                              ],
                            ),
                            Text(
                              '${state.feedActivities.length} ${context.tr('times')}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      _buildActivityColumn(
                        title: context.tr('sleep'),
                        imgUrl: 'assets/images/sleep_icon.png',
                        noDataEmoji: '😴',
                        activities: state.sleepActivities,
                        bodyWidget: Column(
                          children: [
                            Text(
                              '${context.tr('total')} $sleptFormatted',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontSize: 12.sp),
                            ),
                            Text(
                              '${state.sleepActivities.length} ${context.tr('times')}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      _buildActivityColumn(
                        title: context.tr('diaper'),
                        imgUrl: 'assets/images/diaper_icon.png',
                        noDataEmoji: '👶',
                        activities: state.diaperActivities,
                        bodyWidget: Column(
                          children: [
                            if (totalDiaper.isNotEmpty)
                              Text(
                                totalDiaper,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontSize: 12.sp),
                              ),
                            Text(
                              '${state.diaperActivities.length} ${context.tr("times changed.")}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      _buildActivityColumn(
                        title: context.tr('pump'),
                        imgUrl: 'assets/images/pump_icon.png',
                        noDataEmoji: '🤱',
                        activities: state.pumpActivities,
                        bodyWidget: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.tr('total:'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontSize: 12.sp),
                                ),
                                Text(
                                  totalPumpAmount.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontSize: 12.sp),
                                ),
                                SizedBox(width: 5.w),
                                if (totalPumpUnit != null)
                                  Text(
                                    totalPumpUnit,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontSize: 12.sp),
                                  ),
                              ],
                            ),
                            Text(
                              '${state.pumpActivities.length} ${context.tr("times")}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildActivityColumn({
    required String title,
    required String imgUrl,
    required String noDataEmoji,
    required Widget bodyWidget,
    required List<ActivityModel> activities,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(150),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
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
                    '$noDataEmoji ${context.tr('no_data')}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : bodyWidget,
        ],
      ),
    );
  }
}
