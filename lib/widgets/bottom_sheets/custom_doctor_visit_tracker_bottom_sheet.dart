import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';

class CustomDoctorVisitTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomDoctorVisitTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomDoctorVisitTrackerBottomSheet> createState() =>
      _CustomDoctorVisitTrackerBottomSheetState();
}

class _CustomDoctorVisitTrackerBottomSheetState
    extends State<CustomDoctorVisitTrackerBottomSheet> {
  DateTime selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  TextEditingController diagnosisController = TextEditingController();

  final List<String> dropdownItemReason = [
    'Check-up',
    'Vaccination',
    'Illness / Sick Visit',
    'Injury',
    'Developmental Concern',
    'Other',
  ];

  final List<String> dropdownItemReaction = [
    'Calm',
    'Cried briefly',
    'Cried a lot',
    'Sleepy',
    'Fussy',
    'Feverish',
    'Normal / Active',
    'Other',
  ];

  late String selectedReason;
  late String selectedReaction;

  @override
  void initState() {

    super.initState();
    selectedReason = dropdownItemReason.first;
    selectedReaction = dropdownItemReaction.first;
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
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                    color: AppColors.doctorVisitColor,
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
                        context.tr('doctor_visit'),
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
                          context.tr('save'),
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
                          Text(context.tr('visit_time')),
                          SizedBox(width: 20.w),
                          CustomDateTimePicker(
                            initialText: context.tr('select_visit_time'),
                            onDateTimeSelected: (selected) {
                              selectedDatetime = selected;
                            },
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      // Baby Reaction
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 3, child: Text(context.tr('baby_reaction'))),
                          SizedBox(width: 20.w,),
                          Expanded(flex: 2,
                            child: DropdownButton<String>(
                              value: selectedReaction,
                              items:
                                  dropdownItemReaction
                                      .map(
                                        (reaction) => DropdownMenuItem<String>(
                                          value: reaction,
                                          child: Text(
                                            context.tr('baby_reaction'),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedReaction = val;
                                  });
                                }
                              },
                              isExpanded: true,
                              underline: SizedBox(),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      // Visit Reason
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:3,
                              child: Text(context.tr('visit_reason'))),
                          SizedBox(width: 20.w,),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<String>(
                              value: selectedReason,
                              items:
                                  dropdownItemReason
                                      .map(
                                        (reason) => DropdownMenuItem<String>(
                                          value: reason,
                                          child: Text(
                                            context.tr(reason),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedReason = val;
                                  });
                                }
                              },
                              isExpanded: true,
                              underline: SizedBox(),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      // Diagnosis
                      SizedBox(height: 5.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${context.tr('diagnosis')}:',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.copyWith(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      CustomTextFormField(
                        hintText: '',
                        isNotes: true,
                        controller: diagnosisController,
                      ),
                      Divider(color: Colors.grey.shade300),

                      // Notes
                      SizedBox(height: 5.h),
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
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 20.h),

                      // Footer
                      Center(
                        child: Text(
                          '${context.tr("created_by")} ${widget.firstName}',
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
    if (selectedReason.isEmpty ||
        selectedReaction.isEmpty ||
        diagnosisController.text.trim().isEmpty) {
      showCustomFlushbar(
        context,
        'Warning',
        'Please fill Reason, Diagnosis, and Reaction.',
        Icons.warning_outlined,
      );
      return;
    }

    final activityName = ActivityType.doctorVisit.name;

    final activity = ActivityModel(
      activityID: const Uuid().v4(),
      activityType: activityName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'activityDay' : selectedDatetime.toIso8601String(),
        'startTimeHour': selectedDatetime.hour,
        'startTimeMin': selectedDatetime.minute,
        'reason': selectedReason,
        'reaction': selectedReaction,
        'diagnosis': diagnosisController.text.trim(),
        'notes': notesController.text.trim(),
      },
      isSynced: false,
      babyID: widget.babyID,
      createdBy: widget.firstName,
    );

    context.read<ActivityBloc>().add(AddActivity(activityModel: activity));
    Navigator.of(context).pop();
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      selectedReason = dropdownItemReason.first;
      selectedReaction = dropdownItemReaction.first;
      diagnosisController.clear();
      notesController.clear();
    });

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
