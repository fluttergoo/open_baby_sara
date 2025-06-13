import 'dart:ffi';

import 'package:another_flushbar/flushbar.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_left_side_timer/pump_left_side_timer_bloc.dart'
    as pumpLeft;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_right_side_timer/pump_right_side_timer_bloc.dart'
    as pumpRight;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_total_timer/pump_total_timer_bloc.dart'
    as pumpTotal;
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/pump_left_side_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/pump_right_side_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/pump_total_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/unit_input_field_with_toggle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../../blocs/activity/activity_bloc.dart';
import '../build_custom_snack_bar.dart';

class CustomPumpTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomPumpTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
  });

  @override
  State<CustomPumpTrackerBottomSheet> createState() =>
      _CustomPumpTrackerBottomSheetState();
}

class _CustomPumpTrackerBottomSheetState
    extends State<CustomPumpTrackerBottomSheet>
    with SingleTickerProviderStateMixin {
  DateTime? leftSideStartTime;
  DateTime? leftSideEndTime;
  Duration? leftSideTotalTime;
  DateTime? rightSideStartTime;
  DateTime? rightSideEndTime;
  Duration? rightSideTotalTime;

  double? leftSideAmout;
  String? leftSideUnit;
  double? rightSideAmout;
  String? rightSideUnit;

  DateTime? totalStartTime;
  DateTime? totalEndTime;
  Duration? totalTotalTime;
  double? totalAmout;
  String? totalUnit;
  DateTime? selectedDatetime = DateTime.now();

  TextEditingController notesController = TextEditingController();
  TextEditingController notesTotalController = TextEditingController();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.isEdit && widget.existingActivity != null) {
      selectedDatetime = widget.existingActivity!.activityDateTime;
      final data = widget.existingActivity!.data;

      if (widget.existingActivity!.activityType == ActivityType.pumpTotal.name) {
        totalStartTime = _fromHourMinute(data['totalStartTimeHour'], data['totalStartTimeMin']);
        totalEndTime = _fromHourMinute(data['totalEndTimeHour'], data['totalEndTimeMin']);
        totalTotalTime = Duration(milliseconds: data['totalTime'] ?? 0);
        totalAmout = data['totalAmount']?.toDouble();
        totalUnit = data['totalUnit'];
        notesTotalController.text = data['notes'] ?? '';
        _tabController.index = 0;
      } else {
        leftSideStartTime = _fromHourMinute(data['leftSideStartTimeHour'], data['leftSideStartTimeMin']);
        leftSideEndTime = _fromHourMinute(data['leftSideEndTimeHour'], data['leftSideEndTimeMin']);
        leftSideTotalTime = Duration(milliseconds: data['leftSideTotalTime'] ?? 0);
        leftSideAmout = data['leftSideAmount']?.toDouble();
        leftSideUnit = data['leftSideUnit'];

        rightSideStartTime = _fromHourMinute(data['rightSideStartTimeHour'], data['rightSideStartTimeMin']);
        rightSideEndTime = _fromHourMinute(data['rightSideEndTimeHour'], data['rightSideEndTimeMin']);
        rightSideTotalTime = Duration(milliseconds: data['rightSideTotalTime'] ?? 0);
        rightSideAmout = data['rightSideAmount']?.toDouble();
        rightSideUnit = data['rightSideUnit'];
        notesController.text = data['notes'] ?? '';
        _tabController.index = 1;
      }
    }
  }

  DateTime? _fromHourMinute(int? hour, int? min) {
    if (hour == null || min == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, min);
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityAdded) {
          showCustomFlushbar(
            context,
            context.tr('success'),
            context.tr('activity_was_added'),
            Icons.add_task_outlined,
            color: Colors.green,
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
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
                  color: AppColors.pumpColor,
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
                      context.tr("pump_tracker"),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),

                    // Save button
                    TextButton(
                      onPressed: () {
                        onPressedSave();
                      },
                      child: Text(
                        widget.isEdit ? context.tr('update'):
                        context.tr('save'),                        style: Theme.of(
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
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.zero,
                  labelColor: Colors.purple[700],
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.sp,
                  ),
                  tabs: [
                    Tab(
                      height: 36,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timelapse, size: 16),
                          SizedBox(width: 4.w),
                          Text(context.tr("total")),
                        ],
                      ),
                    ),
                    Tab(
                      height: 36,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.compare_arrows, size: 16),
                          SizedBox(width: 4.w),
                          Text(context.tr("left_right_side")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  physics: BouncingScrollPhysics(),
                  controller: _tabController,
                  children: <Widget>[_totalPump(), _leftAndRightPump()],
                ),
              ),

              // Body (you can customize this)
            ],
          ),
        ),
      ),
    );
  }

  void _onPressedShowTimePicker(BuildContext context, String side) async {
    if (side == 'left') {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final now = DateTime.now();
        leftSideStartTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
          0,
        );
      }
      if (leftSideStartTime != null) {
        context.read<pumpLeft.PumpLeftSideTimerBloc>().add(
          pumpLeft.SetStartTimeTimer(
            startTime: leftSideStartTime,
            activityType: 'leftPumpTimer',
          ),
        );
      }
    } else if (side == 'right') {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final now = DateTime.now();
        rightSideStartTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
          0,
        );
      }
      if (rightSideStartTime != null) {
        context.read<pumpRight.PumpRightSideTimerBloc>().add(
          pumpRight.SetStartTimeTimer(
            startTime: rightSideStartTime,
            activityType: 'rightPumpTimer',
          ),
        );
      }
    } else if (side == 'total') {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final now = DateTime.now();
        totalStartTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
          0,
        );
      }

      if (totalStartTime != null) {
        context.read<pumpTotal.PumpTotalTimerBloc>().add(
          pumpTotal.SetStartTimeTimer(
            startTime: leftSideStartTime,
            activityType: 'pumpTotalTimer',
          ),
        );
      }
    }
  }

  void _onPressedEndTimeShowPicker(BuildContext context, String side) async {
    if (side == 'left') {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final now = DateTime.now();
        leftSideEndTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
          0,
        );
      }

      if (leftSideEndTime != null) {
        context.read<pumpLeft.PumpLeftSideTimerBloc>().add(
          pumpLeft.SetEndTimeTimer(
            endTime: leftSideEndTime!,
            activityType: 'leftPumpTimer',
          ),
        );
      }
    } else if (side == 'right') {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final now = DateTime.now();
        rightSideEndTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
          0,
        );
        if (rightSideEndTime != null) {
          context.read<pumpRight.PumpRightSideTimerBloc>().add(
            pumpRight.SetEndTimeTimer(
              endTime: rightSideEndTime!,
              activityType: 'rightPumpTimer',
            ),
          );
        }
      } else if (side == 'total') {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(DateTime.now()),
        );

        if (pickedTime != null) {
          final now = DateTime.now();
          totalEndTime = DateTime(
            now.year,
            now.month,
            now.day,
            pickedTime.hour,
            pickedTime.minute,
            0,
          );

          if (totalEndTime != null) {
            context.read<pumpTotal.PumpTotalTimerBloc>().add(
              pumpTotal.SetEndTimeTimer(
                endTime: rightSideEndTime!,
                activityType: 'pumpTotalTimer',
              ),
            );
          }
        }
      }
    }
  }

  ActivityModel? _buildTotalPumpActivity() {
    if (totalAmout == null || totalStartTime == null || totalEndTime == null) {
      return null;
    }

    return ActivityModel(
      activityID: Uuid().v4(),
      activityType: ActivityType.pumpTotal.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime!,
      data: {
        'activityDay': selectedDatetime?.toIso8601String(),
        'totalStartTimeHour': totalStartTime?.hour,
        'totalStartTimeMin': totalStartTime?.minute,
        'totalEndTimeHour': totalEndTime?.hour,
        'totalEndTimeMin': totalEndTime?.minute,
        'totalTime': totalTotalTime?.inMilliseconds,
        'totalAmount': totalAmout,
        'totalUnit': totalUnit,
        'notes': notesTotalController.text,
      },
      isSynced: false,
      createdBy: widget.firstName,
      babyID: widget.babyID,
    );
  }

  ActivityModel? _buildLeftRightPumpActivity() {
    final bool hasLeftSideData =
        leftSideStartTime != null &&
        leftSideEndTime != null &&
        leftSideTotalTime != null;
    final bool hasRightSideData =
        rightSideStartTime != null &&
        rightSideTotalTime != null &&
        rightSideEndTime != null;

    if (!hasLeftSideData && !hasRightSideData) {
      return null;
    }
    return ActivityModel(
      activityID: Uuid().v4(),
      activityType: ActivityType.pumpLeftRight.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime!,
      data: {
        'leftSideStartTimeHour': leftSideStartTime?.hour ?? 0,
        'leftSideStartTimeMin': leftSideStartTime?.minute ?? 0,
        'leftSideEndTimeHour': leftSideEndTime?.hour ?? 0,
        'leftSideEndTimeMin': leftSideEndTime?.minute ?? 0,
        'leftSideTotalTime': leftSideTotalTime?.inMilliseconds ?? 0,
        'leftSideAmount': leftSideAmout ?? 0,
        'leftSideUnit': leftSideUnit ?? '',
        'rightSideStartTimeHour': rightSideStartTime?.hour ?? 0,
        'rightSideStartTimeMin': rightSideStartTime?.minute ?? 0,
        'rightSideEndTimeHour': rightSideEndTime?.hour ?? 0,
        'rightSideEndTimeMin': rightSideEndTime?.minute ?? 0,
        'rightSideTotalTime': rightSideTotalTime?.inMilliseconds ?? 0,
        'rightSideAmount': rightSideAmout ?? 0,
        'rightSideUnit': rightSideUnit ?? '',
        'totalTime':
            (leftSideTotalTime ?? Duration.zero).inMilliseconds +
            (rightSideTotalTime ?? Duration.zero).inMilliseconds,
        'totalAmount': (leftSideAmout ?? 0) + (rightSideAmout ?? 0),
        'totalUnit': rightSideUnit ?? leftSideUnit,
        'notes': notesController.text,
      },
      isSynced: false,
      createdBy: widget.firstName,
      babyID: widget.babyID,
    );
  }

  void onPressedSave() {
    ActivityModel? activity;

    if (_tabController.index == 0) {
      activity = _buildTotalPumpActivity();
    } else if (_tabController.index == 1) {
      activity = _buildLeftRightPumpActivity();
    }

    if (activity != null) {
      final activityToSave = activity.copyWith(
        activityID: widget.isEdit ? widget.existingActivity!.activityID : activity.activityID,
        createdAt: widget.isEdit ? widget.existingActivity!.createdAt : activity.createdAt,
        updatedAt: DateTime.now(),
      );

      if (widget.isEdit) {
        context.read<ActivityBloc>().add(UpdateActivity(activityModel: activityToSave));
      } else {
        context.read<ActivityBloc>().add(AddActivity(activityModel: activityToSave));
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => NavigationWrapper()));

      context.read<pumpLeft.PumpLeftSideTimerBloc>().add(pumpLeft.ResetTimer(activityType: 'leftPumpTimer'));
      context.read<pumpRight.PumpRightSideTimerBloc>().add(pumpRight.ResetTimer(activityType: 'rightPumpTimer'));
      context.read<pumpTotal.PumpTotalTimerBloc>().add(pumpTotal.ResetTimer(activityType: 'pumpTotalTimer'));
    } else {
      showCustomFlushbar(
        context,
        context.tr("warning"),
        context.tr("please_enter_start_end_time_or_amount"),
        Icons.warning_outlined,
        color: Colors.redAccent,
      );
    }
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
        context.read<pumpLeft.PumpLeftSideTimerBloc>().add(
          pumpLeft.SetDurationTimer(
            duration: setDuration,
            activityType: 'leftPumpTimer',
          ),
        );
      } else if (side == 'right') {
        context.read<pumpRight.PumpRightSideTimerBloc>().add(
          pumpRight.SetDurationTimer(
            duration: setDuration,
            activityType: 'rightPumpTimer',
          ),
        );
      } else if (side == 'total') {
        context.read<pumpTotal.PumpTotalTimerBloc>().add(
          pumpTotal.SetDurationTimer(
            duration: setDuration,
            activityType: 'pumpTotalTimer',
          ),
        );
      }
    }
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

  void _onPressedDelete(BuildContext context) {
    setState(() {
      totalStartTime = null;
      totalEndTime = null;
      totalTotalTime = null;
      totalAmout = null;
      totalUnit = null;
      notesTotalController.clear();

      leftSideStartTime = null;
      leftSideEndTime = null;
      leftSideTotalTime = null;
      leftSideAmout = null;
      leftSideUnit = null;

      rightSideStartTime = null;
      rightSideEndTime = null;
      rightSideTotalTime = null;
      rightSideAmout = null;
      rightSideUnit = null;
      notesController.clear();
    });

    context.read<pumpLeft.PumpLeftSideTimerBloc>().add(
      pumpLeft.ResetTimer(activityType: 'leftPumpTimer'),
    );
    context.read<pumpRight.PumpRightSideTimerBloc>().add(
      pumpRight.ResetTimer(activityType: 'rightPumpTimer'),
    );
    context.read<pumpTotal.PumpTotalTimerBloc>().add(
      pumpTotal.ResetTimer(activityType: 'pumpTotalTimer'),
    );
    showCustomFlushbar(
      context,
      color: Colors.greenAccent,
      context.tr("info"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }

  _leftAndRightPump() {
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
                      context.tr("left_side"),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    PumpLeftSideTimer(size: 140, activityType: 'leftPumpTimer'),
                  ],
                ),
                Container(height: 120.h, width: 1, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      context.tr("right_side"),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    PumpRightSideTimer(
                      size: 140,
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
                  pumpLeft.PumpLeftSideTimerBloc,
                  pumpLeft.PumpLeftSideTimerState
                >(
                  builder: (context, state) {
                    if (state is pumpLeft.TimerStopped &&
                        state.activityType == 'leftPumpTimer') {
                      leftSideEndTime = state.endTime;
                      leftSideTotalTime = state.duration;
                      if (state.startTime != null) {
                        leftSideStartTime = state.startTime;
                      }
                    }
                    if (state is pumpLeft.TimerRunning &&
                        state.activityType == 'leftPumpTimer') {
                      leftSideEndTime = null;
                      leftSideStartTime = state.startTime;
                      leftSideTotalTime = state.duration;
                    }

                    if (state is pumpLeft.TimerReset) {
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
                            context.tr("start_time"),
                            leftSideStartTime != null
                                ? DateFormat(
                                  'HH:mm:ss',
                                ).format(leftSideStartTime!)
                                : context.tr("add"),
                            () {
                              _onPressedShowTimePicker(context, 'left');
                            },
                          ),
                          buildTimeInfo(
                            context.tr("end_time"),
                            leftSideEndTime != null
                                ? DateFormat(
                                  'HH:mm:ss',
                                ).format(leftSideEndTime!)
                                : context.tr("add"),
                            () {
                              _onPressedEndTimeShowPicker(context, 'left');
                            },
                          ),
                          buildTimeInfo(
                            context.tr("total_time"),
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
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                /// RIGHT SIDE
                BlocBuilder<
                  pumpRight.PumpRightSideTimerBloc,
                  pumpRight.PumpRightSideTimerState
                >(
                  builder: (context, state) {
                    if (state is pumpRight.TimerStopped &&
                        state.activityType == 'rightPumpTimer') {
                      rightSideEndTime = state.endTime;
                      rightSideTotalTime = state.duration;
                      if (state.startTime != null) {
                        rightSideStartTime = state.startTime;
                      }
                    }
                    if (state is pumpRight.TimerRunning &&
                        state.activityType == 'rightPumpTimer') {
                      rightSideEndTime = null;
                      rightSideStartTime = state.startTime;
                      rightSideTotalTime = state.duration;
                    }

                    if (state is pumpRight.TimerReset) {
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
                            context.tr("start_time"),
                            rightSideStartTime != null
                                ? DateFormat(
                                  'HH:mm:ss',
                                ).format(rightSideStartTime!)
                                : context.tr("add"),

                            () => _onPressedShowTimePicker(context, 'right'),
                          ),
                          buildTimeInfo(
                            context.tr("end_time"),

                            rightSideEndTime != null
                                ? DateFormat(
                                  'HH:mm:ss',
                                ).format(rightSideEndTime!)
                                : context.tr("add"),

                            () => _onPressedEndTimeShowPicker(context, 'right'),
                          ),
                          buildTimeInfo(
                            context.tr("total_time"),
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
                context.tr("notes:"),
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
              '${context.tr("created_by")} ${widget.firstName}',
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
                context.tr("reset"),
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

  _totalPump() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PumpTotalTimer(size: 140, activityType: 'pumpTotalTimer'),
            BlocBuilder<
              pumpTotal.PumpTotalTimerBloc,
              pumpTotal.PumpTotalTimerState
            >(
              builder: (context, state) {
                if (state is pumpTotal.TimerStopped &&
                    state.activityType == 'pumpTotalTimer') {
                  totalEndTime = state.endTime;
                  totalTotalTime = state.duration;
                  if (state.startTime != null) {
                    totalStartTime = state.startTime;
                  }
                }
                if (state is pumpTotal.TimerRunning &&
                    state.activityType == 'pumpTotalTimer') {
                  totalEndTime = null;
                  totalStartTime = state.startTime;
                  totalTotalTime = state.duration;
                }

                if (state is pumpTotal.TimerReset) {
                  totalEndTime = null;
                  totalStartTime = null;
                  totalTotalTime = null;
                }
                return Column(
                  children: [
                    SizedBox(height: 16.h),
                    buildTimeInfo(
                      context.tr("start_time"),
                      totalStartTime != null
                          ? DateFormat('HH:mm:ss').format(totalStartTime!)
                          : context.tr("add"),
                      () {
                        _onPressedShowTimePicker(context, 'total');
                      },
                    ),
                    buildTimeInfo(
                      context.tr("end_time"),
                      totalEndTime != null
                          ? DateFormat('HH:mm:ss').format(totalEndTime!)
                          : context.tr("add"),
                      () {
                        _onPressedEndTimeShowPicker(context, 'total');
                      },
                    ),
                    buildTimeInfo(
                      context.tr("total_time"),
                      totalTotalTime != null
                          ? formatDuration(totalTotalTime!)
                          : '00:00',
                      () {
                        _onPressedShowDurationSet(context, 'total');
                      },
                    ),
                    Divider(color: Colors.grey.shade300),

                    UnitInputFieldWithToggle(
                      onChanged: (value, unit) {
                        totalAmout = value;
                        totalUnit = unit;
                      },
                    ),
                    Divider(color: Colors.grey.shade300),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.tr("notes:"),
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(fontSize: 16.sp),
                      ),
                    ),

                    SizedBox(height: 5.h),
                    CustomTextFormField(
                      hintText: '',
                      isNotes: true,
                      controller: notesTotalController,
                    ),
                    SizedBox(height: 5.h),

                    Divider(color: Colors.grey.shade300),

                    SizedBox(height: 20.h),

                    Text(
                      '${context.tr("created_by")} ${widget.firstName}',
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
                        context.tr("reset"),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
