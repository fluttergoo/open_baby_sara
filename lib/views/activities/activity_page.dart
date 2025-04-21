import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_avatar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///
                /// Avatar Image, Age, 3 dots.
                ///
                Row(
                  children: [
                    CustomAvatar(size: 50.sp),
                    SizedBox(width: 2.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fatma Sara',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Age: ',
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: Colors.black, fontSize: 14.sp),
                            children: [
                              TextSpan(
                                text: '18 Months',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall!.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.today_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.more_horiz_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                ///
                /// Today Summary
                ///
                SizedBox(
                  width: double.infinity,
                  height: 120.h,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Today\'s Summary',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              Spacer(),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(DateTime.now()),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          SizedBox(
                            height: 60.h,
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.baby_changing_station_outlined,
                                      size: 28.sp,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '6 Times',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
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
                  ),
                ),

                SizedBox(height: 10.h),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Track New Activity',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),

                SizedBox(height: 10.h),


                ///
                /// Track New Activity
                ///
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 6.w,
                  mainAxisSpacing: 6.h,
                  childAspectRatio: 1.6,
                  children: List.generate(4, (index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Text('Box ${index + 1}'),
                          Icon(Icons.baby_changing_station_outlined, size: 28.sp),
                          SizedBox(height: 8.h),
                          Text('6 Times', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }),
                ),

                SizedBox(height: 10.h),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Growth & Development',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),

                SizedBox(height: 10.h),

                ///
                /// Growth and Development
                ///
                SizedBox(
                  width: double.infinity,
                  height: 80.h,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Weight',
                                      style:
                                      Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '6 Times',
                                      style:
                                      Theme.of(context).textTheme.bodyMedium,
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
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 80.h,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Weight',
                                      style:
                                      Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '6 Times',
                                      style:
                                      Theme.of(context).textTheme.bodyMedium,
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
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
