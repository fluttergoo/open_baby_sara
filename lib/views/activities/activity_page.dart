import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/baby/baby_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/timer/timer_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/baby_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_avatar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_sleep_tracker_bottom_sheet.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/timer_circle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {
  ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<BabyModel> babiesList = [];
  String? dropdownValue;

  TimeOfDay? timerStart;
  TimeOfDay? timerEnd;
  String? timerStartText = 'Add';
  String? timerEndText = 'Add';
  TimeOfDay? start;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    context.read<BabyBloc>().add(LoadBabies());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BabyBloc, BabyState>(
      listener: (context, state) {},
      child: BlocBuilder<BabyBloc, BabyState>(
        builder: (context, state) {
          if (state is BabyLoaded) {
            babiesList = state.babies;
          }
          return Scaffold(
            resizeToAvoidBottomInset: true,
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
                          CustomAvatar(
                            size: 60.sp,
                            imageUrl:
                                state is BabyLoaded
                                    ? state.selectedBaby?.imageUrl
                                    : null,
                          ),
                          SizedBox(width: 2.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<BabyModel>(
                                value:
                                    state is BabyLoaded
                                        ? state.selectedBaby
                                        : null,
                                items:
                                    babiesList.map((baby) {
                                      return DropdownMenuItem(
                                        value: baby,
                                        child: Text(baby.firstName),
                                      );
                                    }).toList(),
                                onChanged: (newBaby) {
                                  if (newBaby != null) {
                                    context.read<BabyBloc>().add(
                                      SelectBaby(selectBabyModel: newBaby),
                                    );
                                  }
                                },
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Colors.black,
                                    fontSize: 14.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          state is BabyLoaded
                                              ? calculateBabyAge(
                                                state.selectedBaby!.dateTime,
                                              )
                                              : 'unknown',
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
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
                                          Icon(
                                            Icons
                                                .baby_changing_station_outlined,
                                            size: 28.sp,
                                          ),
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
                        children: [
                          ///
                          /// Feed Activity
                          ///
                          Card(
                            color: AppColors.feedColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: SizedBox(
                              height: 110.h,
                              child: Stack(
                                children: [
                                  // Başlık (sol üst)
                                  Positioned(
                                    top: 6.h,
                                    left: 10.w,
                                    child: Text(
                                      'Feed',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),

                                  // Sağ üstte "+" ikonu
                                  Positioned(
                                    top: 4.h,
                                    right: 6.w,
                                    child: CircleAvatar(
                                      radius: 16.r,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),

                                  // Sol alt icon (asset image)
                                  Positioned(
                                    bottom: 10.h,
                                    left: 6.w,
                                    child: Image.asset(
                                      'assets/images/feed_icon.png',
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
                                    child: Column(
                                      children: [
                                        Text(
                                          'Last Updated:',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '500 ML sleepdasdasdsaddsadasdsdaadssda',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 10.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ///
                          /// Pump Activity
                          ///
                          Card(
                            color: AppColors.pumpColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: SizedBox(
                              height: 110.h,
                              child: Stack(
                                children: [
                                  // Başlık (sol üst)
                                  Positioned(
                                    top: 6.h,
                                    left: 10.w,
                                    child: Text(
                                      'Pump',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),

                                  // Sağ üstte "+" ikonu
                                  Positioned(
                                    top: 4.h,
                                    right: 6.w,
                                    child: CircleAvatar(
                                      radius: 16.r,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),

                                  // Sol alt icon (asset image)
                                  Positioned(
                                    bottom: 10.h,
                                    left: 6.w,
                                    child: Image.asset(
                                      'assets/images/pump_icon.png',
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
                                    child: Column(
                                      children: [
                                        Text(
                                          'Last Updated:',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '1 hr 38 mins sleepdasdasdsaddsadasdsdaadssda',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 10.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Card(
                            color: AppColors.diaperColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: SizedBox(
                              height: 110.h,
                              child: Stack(
                                children: [
                                  // Başlık (sol üst)
                                  Positioned(
                                    top: 6.h,
                                    left: 10.w,
                                    child: Text(
                                      'Diaper',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),

                                  // Sağ üstte "+" ikonu
                                  Positioned(
                                    top: 4.h,
                                    right: 6.w,
                                    child: CircleAvatar(
                                      radius: 16.r,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),

                                  // Sol alt icon (asset image)
                                  Positioned(
                                    bottom: 10.h,
                                    left: 6.w,
                                    child: Image.asset(
                                      'assets/images/diaper_icon.png',
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
                                    child: Column(
                                      children: [
                                        Text(
                                          'Last Updated:',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '11:30 - Changed',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 10.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ///
                          /// Sleep Activity
                          ///
                          Card(
                            color: AppColors.sleepColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: SizedBox(
                              height: 110.h,
                              child: Stack(
                                children: [
                                  // Başlık (sol üst)
                                  Positioned(
                                    top: 6.h,
                                    left: 10.w,
                                    child: Text(
                                      'Sleep',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),

                                  // Sağ üstte "+" ikonu
                                  Positioned(
                                    top: 4.h,
                                    right: 6.w,
                                    child: CircleAvatar(
                                      radius: 16.r,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20.r),
                                                  ),
                                            ),
                                            builder:
                                                (context) =>
                                                    CustomSleepTrackerBottomSheet(),
                                          );
                                          // showSleepTrackerBottomSheet(context);
                                        },
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
                                    bottom: 10.h,
                                    left: 6.w,
                                    child: Image.asset(
                                      'assets/images/sleep_icon.png',
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
                                    child: Column(
                                      children: [
                                        Text(
                                          'Last Updated:',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '11:30 - Changed',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 10.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Weight',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Weight',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String calculateBabyAge(DateTime birthDate) {
    debugPrint(birthDate.toString());
    final now = DateTime.now();

    if (birthDate.isAfter(now)) {
      return "0 day";
    }

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      final lastDayOfPreviousMonth = DateTime(now.year, now.month, 0).day;
      days += lastDayOfPreviousMonth;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    int totalMonths = years * 12 + months;

    String age = '';
    if (totalMonths > 0) {
      age += '$totalMonths month${totalMonths > 1 ? 's' : ''}';
    }

    if (days > 0) {
      if (age.isNotEmpty) age += ' ';
      age += '$days day${days > 1 ? 's' : ''}';
    }

    return age.isEmpty ? '0 day' : age;
  }

  void showSleepTrackerBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 600.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
                decoration: BoxDecoration(
                  color: AppColors.sleepColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.arrow_back, color: Colors.deepPurple),
                    ),

                    // Title
                    Text(
                      'Sleep Tracker',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),

                    // Save button
                    TextButton(
                      onPressed: () {
                        // TODO: Save logic
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body (you can customize this)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BlocBuilder<TimerBloc, TimerState>(
                    builder: (context, state) {
                      if (state is TimerStopped) {
                        endTime = state.endTime;
                      }
                      if (state is TimerRunning) {
                        endTime = null;
                        start = state.startTime;
                      }

                      if (state is TimerReset) {
                        start = null;
                        endTime = null;
                      }

                      return Column(
                        children: [
                          Text('Start Time - End Time Picker Placeholder'),
                          SizedBox(height: 16),
                          TimerCircle(),
                          SizedBox(height: 32.h),
                          Divider(color: Colors.grey.shade300),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Start Time'),
                              TextButton(
                                onPressed: () {
                                  _onPressedShowTimePicker(context);
                                },
                                child:
                                    start != null
                                        ? Text(start!.format(context))
                                        : Text('Add'),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey.shade300),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('End Time'),
                              TextButton(
                                onPressed: () {
                                  _onPressedEndTimeShowPicker(context);
                                },
                                child:
                                    endTime != null
                                        ? Text(endTime!.format(context))
                                        : Text('Add'),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey.shade300),

                          Divider(color: Colors.grey.shade300),

                          TextButton(
                            onPressed: () {
                              _onPressedDelete(context);
                            },
                            child: Text('Reset'),
                          ),
                          Divider(color: Colors.grey.shade300),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPressedShowTimePicker(BuildContext context) async {
    start = await showTimePicker(
      context: context,
      initialTime:
          timerStart ??
          TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
    );
    if (start != null) {
      context.read<TimerBloc>().add(SetTimer(setTimer: start));
    }
  }

  void _onPressedEndTimeShowPicker(BuildContext context) async {
    endTime = await showTimePicker(
      context: context,
      initialTime:
          timerEnd ??
          TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
    );
    if (endTime != null) {
      context.read<TimerBloc>().add(SetEndTimer(setTimer: endTime!));
    }
  }

  void _onPressedDelete(BuildContext context) {
    context.read<TimerBloc>().add(CancelTimer());
  }
}
