import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/timer/timer_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/timer_circle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSleepTrackerBottomSheet extends StatefulWidget {
  const CustomSleepTrackerBottomSheet({super.key});

  @override
  State<CustomSleepTrackerBottomSheet> createState() =>
      _CustomSleepTrackerBottomSheetState();
}

class _CustomSleepTrackerBottomSheetState
    extends State<CustomSleepTrackerBottomSheet> {
  TimeOfDay? start;
  TimeOfDay? endTime;

  TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
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
                          /// Text('Start Time - End Time Picker Placeholder'),
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
                          SizedBox(height: 5.h),
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
                          CustomTextFormField(hintText: '', isNotes: true),
                          SizedBox(height: 5.h),

                          Divider(color: Colors.grey.shade300),

                          SizedBox(height: 20.h),

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
    );
  }

  void _onPressedShowTimePicker(BuildContext context) async {
    start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (start != null) {
      context.read<TimerBloc>().add(SetTimer(setTimer: start));
    }
  }

  void _onPressedEndTimeShowPicker(BuildContext context) async {
    endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (endTime != null) {
      context.read<TimerBloc>().add(SetEndTimer(setTimer: endTime!));
    }
  }

  void _onPressedDelete(BuildContext context) {
    context.read<TimerBloc>().add(CancelTimer());
  }
}
