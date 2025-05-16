import 'package:another_flushbar/flushbar.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/sleep_timer/sleep_timer_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/sleep_timer_circle.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomSleepTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  Duration? duration;

  CustomSleepTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomSleepTrackerBottomSheet> createState() =>
      _CustomSleepTrackerBottomSheetState();
}

class _CustomSleepTrackerBottomSheetState
    extends State<CustomSleepTrackerBottomSheet> {
  TimeOfDay? start;
  TimeOfDay? endTime;
  String? totalSleepTime;
  DateTime? selectedDatetime = DateTime.now();


  TextEditingController notesController = TextEditingController();

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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 12.r,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sleepColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.deepPurple,
                        ),
                      ),

                      // Title
                      Text(
                        'Sleep Tracker',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
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

                // Body (you can customize this)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<SleepTimerBloc, SleepTimerState>(
                      builder: (context, state) {
                        if (state is TimerStopped) {
                          endTime = state.endTime;
                          widget.duration = state.duration;
                          totalSleepTime = formatDuration(state.duration);
                          if (state.startTime !=null) {
                            start=state.startTime;
                          }
                        }
                        if (state is TimerRunning) {
                          endTime = null;
                          start = state.startTime;
                          widget.duration=state.duration;
                        }

                        if (state is TimerReset) {
                          start = null;
                          endTime = null;
                        }

                        return Column(
                          children: [
                            /// Text('Start Time - End Time Picker Placeholder'),
                            SizedBox(height: 16),
                            SleepTimerCircle(activityType: 'sleepTimer'),
                            SizedBox(height: 32.h),
                            Divider(color: Colors.grey.shade300),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Sleep Time'),
                                TextButton(
                                  onPressed: () {
                                    // _onPressedEndTimeShowPicker(context);
                                    _onPressedShowDurationSet(context);
                                  },
                                  child:
                                      totalSleepTime != null
                                          ? Text(totalSleepTime!)
                                          : Text('00:00'),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            SizedBox(height: 5.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Notes:',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(fontSize: 16.sp),
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
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall!.copyWith(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPressedShowTimePicker(BuildContext context) async {
    start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (start != null) {
      context.read<SleepTimerBloc>().add(
        SetStartTimeTimer( startTime:start, activityType: 'sleepTimer'),
      );
    }
  }

  void _onPressedEndTimeShowPicker(BuildContext context) async {
    endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (endTime != null) {
      context.read<SleepTimerBloc>().add(
        SetEndTimeTimer( activityType: 'sleepTimer', endTime: endTime!),
      );
    }
  }

  void _onPressedDelete(BuildContext context) {
    context.read<SleepTimerBloc>().add(ResetTimer(activityType: 'sleepTimer'));
  }

  void onPressedSave() {
    final activityName = ActivityType.sleep.name;
    if (start != null || endTime != null) {
      try {
        final activityModel = ActivityModel(
          activityID: Uuid().v4(),
          activityType: activityName ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          data: {
            'activityDay' : selectedDatetime?.toIso8601String(),
            'startTimeHour': start?.hour,
            'startTimeMin': start?.minute,
            'endTimeHour': endTime?.hour,
            'endTimeMin': endTime?.minute,
            'totalTime': widget.duration?.inMilliseconds,
            'notes': notesController.text,
          },
          isSynced: false,
          createdBy: widget.firstName,
          babyID: widget.babyID,
        );
        context.read<ActivityBloc>().add(
          AddActivity(activityModel: activityModel),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => NavigationWrapper()),
        );
        context.read<SleepTimerBloc>().add(ResetTimer(activityType: 'sleepTimer'));
      } catch (e, stack) {
        print('HATA YAKALANDI: $e');
        print(stack);
      }
    } else {
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
          'Please enter start or end time',
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

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  void _onPressedShowDurationSet(BuildContext context) async {
    final setDuration = await showDurationPicker(
      context: context,
      initialTime: widget.duration ?? Duration(hours: 0, minutes: 0),
      baseUnit: BaseUnit.minute, // minute / hour / second
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
    if (setDuration != null) {
      context.read<SleepTimerBloc>().add(
        SetDurationTimer(duration: setDuration, activityType: 'sleepTimer'),
      );
    }
  }
}
