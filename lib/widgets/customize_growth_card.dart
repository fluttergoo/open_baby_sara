import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/helper_activities.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomizeGrowthCard extends StatefulWidget {
  final Color color;
  final String title;
  final String babyID;
  final String firstName;
  final String imgUrl;
  final VoidCallback voidCallback;

  const CustomizeGrowthCard({
    super.key,
    required this.color,
    required this.title,
    required this.babyID,
    required this.firstName,
    required this.imgUrl,
    required this.voidCallback,
  });

  @override
  State<CustomizeGrowthCard> createState() => _CustomizeGrowthCardState();
}

class _CustomizeGrowthCardState extends State<CustomizeGrowthCard> {
  List<ActivityModel>? growthActivities = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivitiesWithDateLoaded) {
          growthActivities = state.growthActivities;
        }
        return state is ActivityLoading
            ? Center(child: CircularProgressIndicator())
            : Card(
              color: widget.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: SizedBox(
                height: 110.h,
                child: Stack(
                  children: [
                    /// Title
                    Positioned(
                      top: 10.h,
                      left: 35.w,
                      right: 15.w,
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Weight',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  getLastWeight(growthActivities!) ??
                                      '➕\n Tap to start',textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                'Height',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                              Center(
                                child: Text(
                                  getLastHeight(growthActivities!) ??
                                      '➕\n Tap to start', textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                'Head Size',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                              Center(
                                child: Text(
                                  getLastHeadSize(growthActivities!) ??
                                      '➕\n Tap to start', textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),

                    // Sol alt icon (asset image)
                    Positioned(

                      top: 10.h,
                      bottom: 10.h,

                      child: Image.asset(
                        widget.imgUrl,
                        height: 40.h,
                        width: 40.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }
}
