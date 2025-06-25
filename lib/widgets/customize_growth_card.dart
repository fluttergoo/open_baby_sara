import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/utils/helper_activities.dart';

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                /// Left Image
                Image.asset(
                  widget.imgUrl,
                  height: 40.h,
                  width: 40.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 12.w),

                /// Weight, Height, Head Size Columns
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn(context.tr('weight'), getLastWeight(growthActivities!, context)),
                      _buildInfoColumn(context.tr('height'), getLastHeight(growthActivities!, context)),
                      _buildInfoColumn(context.tr('head_size'), getLastHeadSize(growthActivities!, context)),
                    ],
                  ),
                ),

                /// Add Button
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    onPressed: widget.voidCallback,
                    icon: Icon(Icons.add, color: Colors.white, size: 16.sp),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String title, String? value) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value ?? "➕",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}
