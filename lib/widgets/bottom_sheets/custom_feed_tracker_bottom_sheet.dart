import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/breasfeed_left_side_timer/breasfeed_left_side_timer_bloc.dart'
    as leftBreastfeed;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/breastfeed_right_side_timer/breastfeed_right_side_timer_bloc.dart'
    as rightBreastfeed;
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/breastfeed_left_side_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/breastfeed_right_side_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/formula_breastmilk_selector.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/unit_input_field_with_toggle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomFeedTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomFeedTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomFeedTrackerBottomSheet> createState() =>
      _CustomFeedTrackerBottomSheetState();
}

class _CustomFeedTrackerBottomSheetState
    extends State<CustomFeedTrackerBottomSheet>
    with SingleTickerProviderStateMixin {
  TextEditingController notesBottleFeedController = TextEditingController();
  late final TabController _tabController;
  String? selectedMainActivity;
  DateTime selectedDatetime = DateTime.now();

  double? feedAmout;
  String? feedUnit;
  TimeOfDay? leftSideStartTime;
  TimeOfDay? leftSideEndTime;
  Duration? leftSideTotalTime;
  TimeOfDay? rightSideStartTime;
  TimeOfDay? rightSideEndTime;
  Duration? rightSideTotalTime;

  double? leftSideAmout;
  String? leftSideUnit;
  double? rightSideAmout;
  String? rightSideUnit;
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityAdded) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(buildCustomSnackBar(state.message));
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),

        child: Container(
          height: 600.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 12.r,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.feedColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back, color: Colors.deepPurple),
                      ),
                      Text(
                        'Feed Tracker',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: onPressedSave,
                        child: Text(
                          'Save',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar.secondary(
                  controller: _tabController,

                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  indicatorColor: Colors.deepPurple,
                  tabs: const <Widget>[
                    Tab(text: 'Breastfeed'),
                    Tab(text: 'Bottle Feed'),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    controller: _tabController,
                    children: <Widget>[
                      customBreastFeedTracker(),
                      customBottlerFeedTracker(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onPressedSave() {
    if (_tabController.index == 1) {
      final activityName = ActivityType.bottleFeed.name;
      if (feedAmout == null || selectedMainActivity == null) {
        showCustomFlushbar(
          context,
          'Warning',
          'Please enter feed information',
          Icons.warning_outlined,
        );
      } else {
        final activityModel = ActivityModel(
          activityID: Uuid().v4(),
          activityType: activityName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          data: {
            'activityDay' : selectedDatetime.toIso8601String(),
            'startTimeHour': selectedDatetime?.hour,
            'startTimeMin': selectedDatetime?.minute,
            'notes': notesBottleFeedController.text,
            'mainSelection': selectedMainActivity,
            'totalAmount':feedAmout,
            'totalUnit': feedUnit,
          },
          isSynced: false,
          createdBy: widget.firstName,
          babyID: widget.babyID,
        );
        try {
          context.read<ActivityBloc>().add(
            AddActivity(activityModel: activityModel),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => NavigationWrapper()),
          );
        } catch (e) {
          showCustomFlushbar(
            context,
            'Warning',
            'Error ${e.toString()}',
            Icons.warning_outlined,
          );
        }
      }
    } else if (_tabController.index==0) {
      final activityName = ActivityType.breastFeed.name;
      if (leftSideStartTime ==null && leftSideAmout ==null && leftSideTotalTime ==null) {
        showCustomFlushbar(
          context,
          'Warning',
          'Burasi Please enter feed information',
          Icons.warning_outlined,
        );
      } else {
        final activityModel = ActivityModel(
          activityID: Uuid().v4(),
          activityType: activityName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          data: {
            'activityDay' : selectedDatetime.toIso8601String(),
            'leftSideStartTimeHour':leftSideStartTime?.hour??0,
            'leftSideStartTimeMin':leftSideStartTime?.minute??0,
            'leftSideEndTimeHour':leftSideEndTime?.hour??0,
            'leftSideEndTimeMin':leftSideEndTime?.minute??0,
            'leftSideTotalTime':leftSideTotalTime?.inMilliseconds??0,
            'leftSideAmount':leftSideAmout??0,
            'leftSideUnit':leftSideUnit??'',
            'rightSideStartTimeHour': rightSideStartTime?.hour??0,
            'rightSideStartTimeMin': rightSideStartTime?.minute??0,
            'rightSideEndTimeHour': rightSideEndTime?.hour??0,
            'rightSideEndTimeMin': rightSideEndTime?.minute??0,
            'rightSideTotalTime': rightSideTotalTime?.inMilliseconds??0,
            'rightSideAmount':rightSideAmout??0,
            'rightSideUnit':rightSideUnit??'',
            'totalTime':(leftSideTotalTime ?? Duration.zero).inMilliseconds +
                (rightSideTotalTime ?? Duration.zero).inMilliseconds,
            'totalAmount':(leftSideAmout ?? 0) + (rightSideAmout ?? 0),
            'totalUnit':rightSideUnit ?? leftSideUnit,
            'notes': notesController.text,
          },
          isSynced: false,
          createdBy: widget.firstName,
          babyID: widget.babyID,
        );
        try {
          context.read<ActivityBloc>().add(
            AddActivity(activityModel: activityModel),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => NavigationWrapper()),
          );
        } catch (e) {
          showCustomFlushbar(
            context,
            'Warning',
            'Error ${e.toString()}',
            Icons.warning_outlined,
          );
        }
      }
    }
  }

  _onPressedDelete(BuildContext context) async {}

  Widget customBottlerFeedTracker() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16.r,
        right: 16.r,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Time'),
              CustomDateTimePicker(
                initialText: 'initialText',
                onDateTimeSelected: (selected) {
                  selectedDatetime = selected;
                },
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 10.h),
          Text('Feeding Type'),
          SizedBox(height: 5.h),
          FormulaBreastmilkSelector(
            onChanged: (selectedValue) {
              setState(() {
                selectedMainActivity = selectedValue;
              });
            },
          ),
          SizedBox(height: 10.h),
          Divider(color: Colors.grey.shade300),
          UnitInputFieldWithToggle(
            onChanged: (value, unit) {
              feedAmout = value;
              feedUnit = unit;
            },
          ),
          Divider(color: Colors.grey.shade300),
          Text(
            'Notes:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(fontSize: 16.sp),
          ),
          CustomTextFormField(
            hintText: '',
            isNotes: true,
            controller: notesBottleFeedController,
          ),
          Divider(color: Colors.grey.shade300),

          SizedBox(height: 20.h),
          Center(
            child: Text(
              'Created by ${widget.firstName}',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: TextButton(
              onPressed: () => _onPressedDelete(context),
              child: Text(
                'Reset',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeInfo(String label, String value, VoidCallback onPressed) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade300),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            TextButton(onPressed: onPressed, child: Text(value)),
          ],
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  void _onPressedShowTimePicker(BuildContext context, String side) async {
    if (side == 'left') {
      leftSideStartTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (leftSideStartTime != null) {
        context.read<leftBreastfeed.BreasfeedLeftSideTimerBloc>().add(
          leftBreastfeed.SetStartTimeTimer(
            startTime: leftSideStartTime,
            activityType: 'leftPumpTimer',
          ),
        );
      }
    } else if (side == 'right') {
      rightSideStartTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (rightSideStartTime != null) {
        context.read<rightBreastfeed.BreastfeedRightSideTimerBloc>().add(
          rightBreastfeed.SetStartTimeTimer(
            startTime: rightSideStartTime,
            activityType: 'rightPumpTimer',
          ),
        );
      }
    }
  }

  void _onPressedEndTimeShowPicker(BuildContext context, String side) async {
    if (side == 'left') {
      leftSideEndTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (leftSideEndTime != null) {
        context.read<leftBreastfeed.BreasfeedLeftSideTimerBloc>().add(
          leftBreastfeed.SetEndTimeTimer(
            endTime: leftSideEndTime!,
            activityType: 'leftPumpTimer',
          ),
        );
      }
    } else if (side == 'right') {
      rightSideEndTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (rightSideEndTime != null) {
        context.read<rightBreastfeed.BreastfeedRightSideTimerBloc>().add(
          rightBreastfeed.SetEndTimeTimer(
            endTime: rightSideEndTime!,
            activityType: 'rightPumpTimer',
          ),
        );
      }
    }
  }

  void _onPressedShowDurationSet(BuildContext context, String side) async {
    final setDuration = await showDurationPicker(
      context: context,
      initialTime: Duration(hours: 0, minutes: 0),
      baseUnit: BaseUnit.minute, // minute / hour / second
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
    if (setDuration != null) {
      if (side == 'left') {
        context.read<leftBreastfeed.BreasfeedLeftSideTimerBloc>().add(
          leftBreastfeed.SetDurationTimer(
            duration: setDuration,
            activityType: 'leftPumpTimer',
          ),
        );
      } else if (side == 'right') {
        context.read<rightBreastfeed.BreastfeedRightSideTimerBloc>().add(
          rightBreastfeed.SetDurationTimer(
            duration: setDuration,
            activityType: 'rightPumpTimer',
          ),
        );
      }
    }
  }

  customBreastFeedTracker() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Text('Start Time - End Time Picker Placeholder'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Left Side',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    BreastfeedLeftSideTimer(
                      size: 120,
                      activityType: 'leftPumpTimer',
                    ),
                  ],
                ),
                Container(height: 120.h, width: 1, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      'Right Side',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    BreastfeedRightSideTimer(
                      size: 120,
                      activityType: 'rightPumpTimer',
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// LEFT SIDE
                BlocBuilder<
                  leftBreastfeed.BreasfeedLeftSideTimerBloc,
                  leftBreastfeed.BreasfeedLeftSideTimerState
                >(
                  builder: (context, state) {
                    if (state is leftBreastfeed.TimerStopped &&
                        state.activityType == 'leftPumpTimer') {
                      leftSideEndTime = state.endTime;
                      leftSideTotalTime = state.duration;
                      if (state.startTime != null) {
                        leftSideStartTime = state.startTime;
                      }
                    }
                    if (state is leftBreastfeed.TimerRunning &&
                        state.activityType == 'leftPumpTimer') {
                      leftSideEndTime = null;
                      leftSideStartTime = state.startTime;
                      leftSideTotalTime = state.duration;
                    }

                    if (state is leftBreastfeed.TimerReset) {
                      rightSideEndTime = null;
                      rightSideStartTime = null;
                      rightSideTotalTime = null;
                      leftSideEndTime = null;
                      leftSideStartTime = null;
                      leftSideTotalTime = null;
                    }
                    return Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          buildTimeInfo(
                            'Start Time',
                            leftSideStartTime?.format(context) ?? 'Add',
                            () {
                              _onPressedShowTimePicker(context, 'left');
                            },
                          ),
                          buildTimeInfo(
                            'End Time',
                            leftSideEndTime?.format(context) ?? 'Add',
                            () {
                              _onPressedEndTimeShowPicker(context, 'left');
                            },
                          ),
                          buildTimeInfo(
                            'Total Time',
                            leftSideTotalTime != null
                                ? formatDuration(leftSideTotalTime!)
                                : '00:00',
                            () {
                              _onPressedShowDurationSet(context, 'left');
                            },
                          ),
                          Divider(color: Colors.grey.shade300),

                          UnitInputFieldWithToggle(
                            onChanged: (value, unit) {
                              leftSideAmout = value;
                              leftSideUnit = unit;
                              debugPrint('Buradayim $value $unit');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Container(width: 1, height: 160.h, color: Colors.grey.shade300),

                /// RIGHT SIDE
                BlocBuilder<
                  rightBreastfeed.BreastfeedRightSideTimerBloc,
                  rightBreastfeed.BreastfeedRightSideTimerState
                >(
                  builder: (context, state) {
                    if (state is rightBreastfeed.TimerStopped &&
                        state.activityType == 'rightPumpTimer') {
                      rightSideEndTime = state.endTime;
                      rightSideTotalTime = state.duration;
                      if (state.startTime != null) {
                        rightSideStartTime = state.startTime;
                      }
                    }
                    if (state is rightBreastfeed.TimerRunning &&
                        state.activityType == 'rightPumpTimer') {
                      rightSideEndTime = null;
                      rightSideStartTime = state.startTime;
                      rightSideTotalTime = state.duration;
                    }

                    if (state is rightBreastfeed.TimerReset) {
                      rightSideEndTime = null;
                      rightSideStartTime = null;
                      rightSideTotalTime = null;
                      rightSideAmout = null;
                      rightSideUnit = null;
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          buildTimeInfo(
                            'Start Time',
                            rightSideStartTime?.format(context) ?? 'Add',
                            () => _onPressedShowTimePicker(context, 'right'),
                          ),
                          buildTimeInfo(
                            'End Time',
                            rightSideEndTime?.format(context) ?? 'Add',
                            () => _onPressedEndTimeShowPicker(context, 'right'),
                          ),
                          buildTimeInfo(
                            'Total Time',
                            rightSideTotalTime != null
                                ? formatDuration(rightSideTotalTime!)
                                : '00:00',
                            () => _onPressedShowDurationSet(context, 'right'),
                          ),
                          Divider(color: Colors.grey.shade300),
                          UnitInputFieldWithToggle(
                            onChanged: (value, unit) {
                              setState(() {
                                rightSideAmout = value;
                                rightSideUnit = unit;
                              });
                              debugPrint('Right side value: $value $unit');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notes:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontSize: 16.sp),
              ),
            ),

            SizedBox(height: 5.h),
            CustomTextFormField(
              hintText: '',
              isNotes: true,
              controller: notesController,
            ),
            SizedBox(height: 5.h),

            Divider(color: Colors.grey.shade300),

            SizedBox(height: 20.h),

            Text(
              'Created by ${widget.firstName}',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 10.h),

            TextButton(
              onPressed: () {
                _onPressedDelete(context);
              },
              child: Text(
                'Reset',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
