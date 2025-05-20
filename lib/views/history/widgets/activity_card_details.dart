import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ActivityCardDetails extends StatelessWidget {
  final ActivityModel activity;
  final String? summary;
  final String iconPath;

  const ActivityCardDetails({
    super.key,
    required this.activity,
    this.summary,
    required this.iconPath,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final activityDayStr = activity.data['activityDay'] as String?;
    final activityDay =
        activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;

    final formattedDate =
        activityDay != null ? DateFormat('MMM d').format(activityDay) : '--';
    final formattedTime =
        activityDay != null ? DateFormat('h:mm a').format(activityDay) : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// Date Column (left side)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            SizedBox(width: 20.w),

            /// Icon and details (right side)
            Expanded(
              child: Row(
                children: [
                  Image.asset(iconPath, height: 40.sp, width: 40.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toBeginningOfSentenceCase(activity.activityType) ??
                              activity.activityType,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
