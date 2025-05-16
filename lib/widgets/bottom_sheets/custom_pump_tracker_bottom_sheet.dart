import 'dart:ffi';

import 'package:another_flushbar/flushbar.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_left_side_timer/pump_left_side_timer_bloc.dart'
    as pumpLeft;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_right_side_timer/pump_right_side_timer_bloc.dart'
    as pumpRight;
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_total_timer/pump_total_timer_bloc.dart' as pumpTotal;
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/pump_left_side_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/pump_right_side_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/pump_total_timer.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/unit_input_field_with_toggle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../../blocs/activity/activity_bloc.dart';
import '../build_custom_snack_bar.dart';

class CustomPumpTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomPumpTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomPumpTrackerBottomSheet> createState() =>
      _CustomPumpTrackerBottomSheetState();
}

class _CustomPumpTrackerBottomSheetState
    extends State<CustomPumpTrackerBottomSheet>
    with SingleTickerProviderStateMixin {
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

  TimeOfDay? totalStartTime;
  TimeOfDay? totalEndTime;
  Duration? totalTotalTime;
  double? totalAmout;
  String? totalUnit;
  DateTime? selectedDatetime = DateTime.now();


  TextEditingController notesController = TextEditingController();
  TextEditingController notesTotalController = TextEditingController();

  late final TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                      'Pump Tracker',
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
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => NavigationWrapper(),
                          ),
                        );
                      },
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
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                indicatorColor: Colors.deepPurple,
                tabs: const <Widget>[
                  Tab(text: 'Total'),
                  Tab(text: 'Left/Right Side'),
                ],
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
      leftSideStartTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (leftSideStartTime != null) {
        context.read<pumpLeft.PumpLeftSideTimerBloc>().add(
          pumpLeft.SetStartTimeTimer(
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
        context.read<pumpRight.PumpRightSideTimerBloc>().add(
          pumpRight.SetStartTimeTimer(
            startTime: rightSideStartTime,
            activityType: 'rightPumpTimer',
          ),
        );
      }
    } else if (side=='total') {
      totalStartTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
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
      leftSideEndTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (leftSideEndTime != null) {
        context.read<pumpLeft.PumpLeftSideTimerBloc>().add(
          pumpLeft.SetEndTimeTimer(
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
        context.read<pumpRight.PumpRightSideTimerBloc>().add(
          pumpRight.SetEndTimeTimer(
            endTime: rightSideEndTime!,
            activityType: 'rightPumpTimer',
          ),
        );
      }
    }
    else if (side == 'total') {
      totalEndTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  void onPressedSave() {
    if (_tabController.index==1) {
      final activityName = ActivityType.pumpLeftRight.name;
      if (leftSideStartTime !=null && leftSideAmout !=null && leftSideTotalTime !=null ) {
        try {
          final activityModel = ActivityModel(
            activityID: Uuid().v4(),
            activityType: activityName ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            data: {
              'activityDay' : selectedDatetime?.toIso8601String(),
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
          context.read<ActivityBloc>().add(
            AddActivity(activityModel: activityModel),
          );
        } catch (e, stack) {
          print('HATA YAKALANDI: $e');
          print(stack);
        }
      }  else {
        Flushbar(
          titleText: Text(
            'Warning',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          margin: EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          messageText: Text(
            'Please enter start, end time or amount',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          icon: Icon(Icons.warning_outlined, color: Colors.white),
          duration: Duration(seconds: 3),
        ).show(context);
      }

    }  else if (_tabController.index==0) {
      final activityName = ActivityType.pumpTotal.name;

      if (totalAmout !=null && totalStartTime !=null && totalEndTime !=null) {
        try {
          final activityModel = ActivityModel(
            activityID: Uuid().v4(),
            activityType: activityName ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            data: {
              'activityDay' : selectedDatetime?.toIso8601String(),
              'totalStartTimeHour':totalStartTime?.hour,
              'totalStartTimeMin':totalStartTime?.minute,
              'totalEndTimeHour':totalEndTime?.hour,
              'totalEndTimeMin':totalEndTime?.minute,
              'totalTime':totalTotalTime?.inMilliseconds,
              'totalAmount':totalAmout,
              'totalUnit':totalUnit,
              'notes': notesTotalController.text,
            },
            isSynced: false,
            createdBy: widget.firstName,
            babyID: widget.babyID,
          );
          context.read<ActivityBloc>().add(
            AddActivity(activityModel: activityModel),
          );
        } catch (e, stack) {
          print('HATA YAKALANDI: $e');
          print(stack);
        }
      }  else {
        Flushbar(
          titleText: Text(
            'Warning',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          margin: EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          messageText: Text(
            'Please enter start, end time or amount',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          icon: Icon(Icons.warning_outlined, color: Colors.white),
          duration: Duration(seconds: 3),
        ).show(context);
      }

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
      }
      else if (side == 'total') {
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
    context.read<pumpLeft.PumpLeftSideTimerBloc>().add(
      pumpLeft.ResetTimer(activityType: 'leftPumpTimer'),
    );
    context.read<pumpRight.PumpRightSideTimerBloc>().add(
      pumpRight.ResetTimer(activityType: 'rightPumpTimer'),
    );
    context.read<pumpTotal.PumpTotalTimerBloc>().add(
      pumpTotal.ResetTimer(activityType: 'pumpTotalTimer',),
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
                      'Left Side',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    PumpLeftSideTimer(size: 120, activityType: 'leftPumpTimer'),
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
                    PumpRightSideTimer(
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
            BlocBuilder<pumpTotal.PumpTotalTimerBloc, pumpTotal.PumpTotalTimerState>(
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
                  totalEndTime=null;
                  totalStartTime=null;
                  totalTotalTime=null;
                }
                return Column(
                  children: [
                    SizedBox(height: 16.h),
                    buildTimeInfo('Start Time', totalStartTime?.format(context) ?? 'Add',
                          () {_onPressedShowTimePicker(context, 'total');},
                    ),
                    buildTimeInfo(
                      'End Time',
                      totalEndTime?.format(context) ?? 'Add',
                      () {
                        _onPressedEndTimeShowPicker(context, 'total');
                      },
                    ),
                    buildTimeInfo(
                      'Total Time',
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
                        debugPrint('Buradayim $value $unit');
                      },
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
                      controller: notesTotalController,
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
