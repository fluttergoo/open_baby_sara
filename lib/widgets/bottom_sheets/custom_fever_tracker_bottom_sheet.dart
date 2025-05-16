import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_input_field_with_toggle.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomFeverTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomFeverTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomFeverTrackerBottomSheet> createState() =>
      _CustomFeverTrackerBottomSheetState();
}

class _CustomFeverTrackerBottomSheetState
    extends State<CustomFeverTrackerBottomSheet> {
  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  double? temperature;
  String? temperatureUnit;

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
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.r,
                      vertical: 12.r,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.feverTrackerColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          'Fever Tracker',
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

                  // Body
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(
                        left: 16.r,
                        right: 16.r,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        top: 16,
                      ),
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
                        CustomInputFieldWithToggle(
                          title: 'Enter Baby’s Temperature',
                          selectedMeasurementOfUnit:
                              MeasurementOfUnitNames.temperature,
                          onChanged: (val, unit) {
                            temperature = val;
                            temperatureUnit = unit;
                          },
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
                        CustomTextFormField(
                          hintText: '',
                          isNotes: true,
                          controller: notesController,
                        ),
                        Divider(color: Colors.grey.shade300),
                        SizedBox(height: 20.h),
                        Center(
                          child: Text(
                            'Created by ${widget.firstName}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall!.copyWith(
                              fontSize: 12.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        TextButton(
                          onPressed: () => _onPressedDelete(context),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onPressedSave() {
    final activityName = ActivityType.fever.name;

    if (temperature == null) {
      showCustomFlushbar(
        context,
        'Warning',
        'Please enter a temperature.',
        Icons.warning_outlined,
      );
      return; // kayıt işlemi durdurulmalı
    }

    final activityModel = ActivityModel(
      activityID: Uuid().v4(),
      activityType: activityName,
      createdAt: selectedDatetime ?? DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'activityDay' : selectedDatetime?.toIso8601String(),
        'startTimeHour': selectedDatetime?.hour,
        'startTimeMin': selectedDatetime?.minute,
        'notes': notesController.text,
        'temperature': temperature,
        'temperatureUnit': temperatureUnit,
      },
      isSynced: false,
      createdBy: widget.firstName,
      babyID: widget.babyID, // burada düzeltme yapıldı
    );

    context.read<ActivityBloc>().add(AddActivity(activityModel: activityModel));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => NavigationWrapper()),
    );
  }

  _onPressedDelete(BuildContext context) {}
}
