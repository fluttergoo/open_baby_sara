import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTodaySummaryCard extends StatefulWidget {
  final Color color;
  final String title;
  final String babyID;
  final String firstName;
  const CustomTodaySummaryCard({super.key, required this.color, required this.title, required this.babyID, required this.firstName});

  @override
  State<CustomTodaySummaryCard> createState() => _CustomTodaySummaryCardState();
}

class _CustomTodaySummaryCardState extends State<CustomTodaySummaryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Today\'s Summary',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp
                  ),
                ),
                Spacer(),
                Text(
                  DateFormat(
                    'MMM dd, yyyy',
                  ).format(DateTime.now()),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            SizedBox(
              height: 60.h,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [

                      Image.asset('assets/images/growth_icon.png', width: 35,height: 35,),
                      SizedBox(height: 4.h),
                      Text(
                        '6 Times',
                        style:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium,
                      ),
                    ],
                  );
                },
                separatorBuilder:
                    (_, __) => SizedBox(width: 25.w),
                itemCount: 10,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
