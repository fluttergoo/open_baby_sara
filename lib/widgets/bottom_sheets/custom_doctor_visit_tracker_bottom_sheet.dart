import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/widgets/custom_bottom_sheet_header.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';

class CustomDoctorVisitTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomDoctorVisitTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
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
    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;
      selectedDatetime = widget.existingActivity!.activityDateTime;
      selectedReason = data['reason'] ?? dropdownItemReason.first;
      selectedReaction = data['reaction'] ?? dropdownItemReaction.first;
      diagnosisController.text = data['diagnosis'] ?? '';
      notesController.text = data['notes'] ?? '';
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
                CustomSheetHeader(
                  title: context.tr('doctor_visit'),
                  onBack: () => Navigator.of(context).pop(),
                  onSave: () => onPressedSave(),
                  saveText: widget.isEdit ? context.tr('update') : context.tr('save'),
                  backgroundColor: AppColors.doctorVisitColor,
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
                          Expanded(
                            flex: 3,
                            child: Text(context.tr('baby_reaction')),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<String>(
                              value: selectedReaction,
                              items:
                                  dropdownItemReaction
                                      .map(
                                        (reaction) => DropdownMenuItem<String>(
                                          value: reaction,
                                          child: Text(
                                            context.tr(reaction),
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
                          Expanded(
                            flex: 3,
                            child: Text(context.tr('visit_reason')),
                          ),
                          SizedBox(width: 20.w),
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
    if (selectedReason.isEmpty || selectedReaction.isEmpty) {
      showCustomFlushbar(
        context,
        context.tr('warning'),
        context.tr('please_fill_reason'),
        Icons.warning_outlined,
      );
      return;
    }

    final activityName = ActivityType.doctorVisit.name;

    final activity = ActivityModel(
      activityID:
          widget.isEdit
              ? widget.existingActivity!.activityID
              : const Uuid().v4(),
      activityType: activityName,
      createdAt:
          widget.isEdit ? widget.existingActivity!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime,
      data: {
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

    if (widget.isEdit) {
      context.read<ActivityBloc>().add(UpdateActivity(activityModel: activity));
    } else {
      context.read<ActivityBloc>().add(AddActivity(activityModel: activity));
    }

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
