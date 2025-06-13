import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
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
                      left: 15.w,
                      right: 15.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr('weight'),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Center(
                                child: Text(
                                  getLastWeight(growthActivities!, context) ??
                                      "➕\n${context.tr('tap_to_start_only')}",
                                  textAlign: TextAlign.center,

                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontSize: 10.sp),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                context.tr('height'),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Center(
                                child: Text(
                                  getLastHeight(growthActivities!, context) ??
                                      context.tr('tap_to_start'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontSize: 10.sp),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                context.tr('head_size'),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Center(
                                child: Text(
                                  getLastHeadSize(growthActivities!, context) ??
                                      context.tr('tap_to_start'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontSize: 10.sp),
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
