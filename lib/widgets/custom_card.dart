import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/models/activity_model.dart';

class CustomCard extends StatefulWidget {
  final Color color;
  final String title;
  final String babyID;
  final String firstName;
  final String imgUrl;
  final VoidCallback voidCallback;


  const CustomCard({
    super.key,
    required this.color,
    required this.title,
    required this.babyID,
    required this.firstName, required this.imgUrl, required this.voidCallback,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  String lastSleepActivityText = '';
  String lastSleepActivityTimeText = '';
  String lastPumpActivityText='';
  String lastPumpActivityTimeText='';
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
  builder: (context, state) {
    if (state is SleepActivityLoaded) {
      final ActivityModel? lastSleepActivity =
          state.activityModel;
      getFormatLastSleepActivity(lastSleepActivity);
    }
    if (state is PumpActivityLoaded) {
      final ActivityModel? lastPumpActivity=state.activityModel;
      getFormatLastPumpActivity(lastPumpActivity);
    }
    return Card(
      color: widget.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SizedBox(
        height: 110.h,
        child: Stack(
          children: [
            /// Title
            Positioned(
              top: 6.h,
              left: 10.w,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),

            /// Add new activity icon
            Positioned(
              top: 4.h,
              right: 6.w,
              child: CircleAvatar(
                radius: 16.r,
                backgroundColor: Theme.of(context).primaryColor,
                child: IconButton(
                  onPressed: widget.voidCallback,
                  icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
                ),
              ),
            ),

            // Sol alt icon (asset image)
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

            // Icon'un yanındaki metin
            Positioned(
              bottom: 4.h,
              left: 45.w,
              right: 10.w,
              child: Column(children: [
                widget.title == 'Sleep' ? getLastUpdated() : SizedBox(),
                widget.title == 'Pump' ? getLastPumpUpdated() : SizedBox(),
              ]),
            ),
          ],
        ),
      ),
    );
  },
);
  }

  void getFormatLastSleepActivity(ActivityModel? lastSleepActivity) {
    if (lastSleepActivity != null) {
      final startTime = TimeOfDay(
        hour: lastSleepActivity.data['startTimeHour'],
        minute: lastSleepActivity.data['startTimeMin'],
      );
      lastSleepActivityTimeText = startTime.format(context);
      final int durationOfMileSeconds = lastSleepActivity.data['totalTime'];
      final duration = Duration(milliseconds: durationOfMileSeconds);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      String durationTime = '${hours}h ${minutes}m';

      lastSleepActivityText = '$durationTime sleep';
    } else {
      lastSleepActivityText = '0';
    }
  }

  getLastUpdated() {
    if (lastSleepActivityText == '0') {
      return Align(
        alignment: Alignment.center,
        child: Text(
          'No sleep tracked.\nTap + to add.',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: Colors.black87,
          ),
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          text: 'Last Updated\n',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '$lastSleepActivityTimeText\n',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 11.sp,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: lastSleepActivityText,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }
  }

  void getFormatLastPumpActivity(ActivityModel? lastPumpActivity) {
    if (lastPumpActivity != null) {
      final startTime = TimeOfDay(
        hour: lastPumpActivity.data['totalEndTimeHour'] ?? lastPumpActivity.data['leftSideEndTimeHour'],
        minute: lastPumpActivity.data['totalEndTimeMin'] ?? lastPumpActivity.data['leftSideEndTimeMin'],
      );
      lastPumpActivityTimeText = startTime.format(context);
      final double amount=  lastPumpActivity.data['totalAmount'] ?? 0.0;
      final String unit = lastPumpActivity.data['totalUnit'] ?? 'mL';

      lastPumpActivityText = '$amount $unit was pumped';
    } else {
      lastSleepActivityText = '0';
    }
  }

  getLastPumpUpdated() {
    if (lastSleepActivityText == '0') {
      return Align(
        alignment: Alignment.center,
        child: Text(
          'No pump tracked.\nTap + to add.',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: Colors.black87,
          ),
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          text: 'Last Updated\n',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '$lastPumpActivityTimeText\n',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 11.sp,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: lastPumpActivityText,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }
  }
}
