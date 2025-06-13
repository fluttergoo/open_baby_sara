import 'package:another_flushbar/flushbar.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/sleep_timer/sleep_timer_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/all_timers/sleep_timer_circle.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomSleepTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  Duration? duration;
  final ActivityModel? existingActivity;
  final bool isEdit;


  CustomSleepTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.existingActivity,
    this.isEdit = false,
  });

  @override
  State<CustomSleepTrackerBottomSheet> createState() =>
      _CustomSleepTrackerBottomSheetState();
}

class _CustomSleepTrackerBottomSheetState
    extends State<CustomSleepTrackerBottomSheet> {
  DateTime? start;
  DateTime? endTime;
  String? totalSleepTime;
  DateTime? selectedDatetime = DateTime.now();

  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;

      selectedDatetime = widget.existingActivity!.activityDateTime;
      notesController.text = data['notes'] ?? '';

      start = DateTime(
        selectedDatetime!.year,
        selectedDatetime!.month,
        selectedDatetime!.day,
        data['startTimeHour'] ?? 0,
        data['startTimeMin'] ?? 0,
      );

      endTime = DateTime(
        selectedDatetime!.year,
        selectedDatetime!.month,
        selectedDatetime!.day,
        data['endTimeHour'] ?? 0,
        data['endTimeMin'] ?? 0,
      );

      final totalMs = data['totalTime'];
      if (totalMs != null) {
        widget.duration = Duration(milliseconds: totalMs);
        totalSleepTime = formatDuration(widget.duration!);
      }


      context.read<SleepTimerBloc>().add(
        SetDurationTimer(duration: widget.duration ?? Duration.zero, activityType: 'sleepTimer'),
      );
      
      context.read<SleepTimerBloc>().add(StopTimer(activityType: 'sleepTimer'));
      context.read<SleepTimerBloc>().add(
        SetDurationTimer(duration: widget.duration ?? Duration.zero, activityType: 'sleepTimer'),
      );
    }
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
                        child: Icon(Icons.arrow_back, color: Colors.deepPurple),
                      ),

                      // Title
                      Text(
                        context.tr('sleep_tracker'),
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
                          widget.isEdit
                              ? context.tr('update')
                              : context.tr('save'),
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
                          if (state.startTime != null) {
                            start = state.startTime;
                          }
                        }
                        if (state is TimerRunning) {
                          endTime = null;
                          start = state.startTime;
                          widget.duration = state.duration;
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr("start_time")),
                                TextButton(
                                  onPressed: () {
                                    _onPressedShowTimePicker(context);
                                  },
                                  child:
                                      start != null
                                          ? Text(
                                            DateFormat(
                                              'HH:mm:ss',
                                            ).format(start!),
                                          )
                                          : Text(context.tr("add")),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr("end_time")),
                                TextButton(
                                  onPressed: () {
                                    _onPressedEndTimeShowPicker(context);
                                  },
                                  child:
                                      endTime != null
                                          ? Text(
                                            DateFormat(
                                              'HH:mm:ss',
                                            ).format(endTime!),
                                          )
                                          : Text(context.tr("add")),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr("total_sleep_time")),
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
                                context.tr("notes:"),
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
                              '${context.tr("created_by")} ${widget.firstName}',
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
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      start = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
        0,
      );

      context.read<SleepTimerBloc>().add(
        SetStartTimeTimer(startTime: start, activityType: 'sleepTimer'),
      );
    }
  }

  void _onPressedEndTimeShowPicker(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final selected = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (start != null) {
        if (selected.isBefore(start!)) {
          _showError(context.tr("end_time_before_start"));
          return;
        }
      }

      if (selected.isAfter(now)) {
        _showError(context.tr("end_time_in_future"));
        return;
      }

      endTime = selected;

      context.read<SleepTimerBloc>().add(
        SetEndTimeTimer(activityType: 'sleepTimer', endTime: endTime!),
      );
    }
  }

  void _showError(String message) {
    showCustomFlushbar(context, context.tr("warning"), message, Icons.warning);
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      start = null;
      endTime = null;
      totalSleepTime = null;
      notesController.clear();
      widget.duration = null;
      selectedDatetime = DateTime.now();
    });

    context.read<SleepTimerBloc>().add(ResetTimer(activityType: 'sleepTimer'));

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }

  void onPressedSave() {
    final activityName = ActivityType.sleep.name;

    if (endTime == null) {
      Navigator.of(context).pop();
      return;
    }

    if (start == null || widget.duration == null) {
      _showError(context.tr("please_complete_all_fields"));
      return;
    }

    try {
      final activityModel = ActivityModel(
        activityID: widget.isEdit
            ? widget.existingActivity!.activityID
            : const Uuid().v4(),
        activityType: activityName,
        createdAt: widget.isEdit
            ? widget.existingActivity!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
        activityDateTime: selectedDatetime!,
        data: {
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

      if (widget.isEdit) {
        context.read<ActivityBloc>().add(UpdateActivity(activityModel: activityModel));
      } else {
        context.read<ActivityBloc>().add(AddActivity(activityModel: activityModel));
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => NavigationWrapper()),
      );

      context.read<SleepTimerBloc>().add(
        ResetTimer(activityType: 'sleepTimer'),
      );
    } catch (e, stack) {
      print(stack);
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
