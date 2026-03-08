import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/core/utils/helper_activities.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/models/activity_model.dart';

class CustomCard extends StatefulWidget {
  final Color color;
  final String title;
  final String babyID;
  final String firstName;
  final String imgUrl;
  final VoidCallback voidCallback;
  final ActivityModel? activityModel;
  final bool? isActivityRunning;
  final String activityType;

  const CustomCard({
    super.key,
    required this.color,
    required this.title,
    required this.babyID,
    required this.firstName,
    required this.imgUrl,
    required this.voidCallback,
    this.activityModel,
    this.isActivityRunning,
    required this.activityType,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  List<ActivityModel>? feedActivities;
  List<ActivityModel>? sleepActivities;
  List<ActivityModel>? diaperActivities;
  List<ActivityModel>? pumpActivities;
  List<ActivityModel>? babyFirstsActivities;
  List<ActivityModel>? teethingActivities;
  List<ActivityModel>? medicationActivities;
  List<ActivityModel>? doctorVisitActivities;
  List<ActivityModel>? vaccinationActivities;
  List<ActivityModel>? feverActivities;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      buildWhen: (previous, current) {
        // Only rebuild for relevant states.
        // ActivityLoading is intentionally excluded — teething bottom sheet
        // emits TeethingLoading (not ActivityLoading) to avoid affecting cards.
        return current is SleepActivityLoaded ||
            current is PumpActivityLoaded ||
            current is ActivitiesWithDateLoaded;
      },
      builder: (context, state) {
        if (state is ActivitiesWithDateLoaded) {
          feedActivities = state.feedActivities;
          sleepActivities = state.sleepActivities;
          pumpActivities = state.pumpActivities;
          diaperActivities = state.diaperActivities;
          babyFirstsActivities = state.babyFirstsActivities;
          teethingActivities = state.teethingActivities;
          medicationActivities = state.medicationActivities;
          doctorVisitActivities = state.doctorVisitActivities;
          vaccinationActivities = state.vaccinationActivities;
          feverActivities = state.feverActivities;
        }

        return Card(
          color: widget.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: SizedBox(
            height: 110.h,
            child: Stack(
              children: [
                // Title
                Positioned(
                  top: 6.h,
                  left: 10.w,
                  right: 30.w,
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),

                // Add new activity icon
                Positioned(
                  top: 4.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: widget.voidCallback,
                    child: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                      size: 32.sp,
                    ),
                  ),
                ),

                // Bottom-left asset icon
                Positioned(
                  bottom: 10.h,
                  left: 6.w,
                  child: Image.asset(
                    widget.imgUrl,
                    height: 40.h,
                    width: 40.w,
                    fit: BoxFit.contain,
                  ),
                ),

                // Last activity summary text
                Positioned(
                  bottom: 8.h,
                  left: 45.w,
                  right: 5.w,
                  child: _buildLastActivityText(context, widget.activityType),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLastActivityText(BuildContext context, String activityType) {
    final isRunning = widget.isActivityRunning ?? false;
    final String? displayText;

    switch (activityType) {
      case 'sleep':
        displayText =
            sleepActivities != null
                ? getLastSleepSummary(sleepActivities!, isRunning, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'breastFeed':
        displayText =
            feedActivities != null
                ? getLastFeedSummary(feedActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'pumpTotal':
        displayText =
            pumpActivities != null
                ? getLastPumpSummary(pumpActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'diaper':
        displayText =
            diaperActivities != null
                ? getLastDiaperSummary(diaperActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'babyFirsts':
        displayText =
            babyFirstsActivities != null
                ? getLastBabyFirstsSummary(babyFirstsActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'teething':
        displayText =
            teethingActivities != null
                ? getLastTeethingSummary(teethingActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'medication':
        displayText =
            medicationActivities != null
                ? getLastMedicationSummary(medicationActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'doctorVisit':
        displayText =
            doctorVisitActivities != null
                ? getLastDoctorVisitSummary(doctorVisitActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'vaccination':
        displayText =
            vaccinationActivities != null
                ? getLastVaccinationSummary(vaccinationActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      case 'fever':
        displayText =
            feverActivities != null
                ? getLastFeverSummary(feverActivities!, context)
                : '➕ ${context.tr('tap_to_start_only')}';
        break;

      default:
        displayText = '➕ ${context.tr('tap_to_start_only')}';
    }

    return Text(
      displayText ?? '➕ ${context.tr('tap_to_start_only')}',
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontSize: 10.sp),
    );
  }
}
