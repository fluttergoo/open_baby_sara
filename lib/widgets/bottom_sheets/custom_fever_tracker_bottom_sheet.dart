import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_bottom_sheet_header.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_input_field_with_toggle.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomFeverTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomFeverTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
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
  void initState() {
    if (widget.isEdit && widget.existingActivity != null) {
      final activity = widget.existingActivity!;
      selectedDatetime = activity.activityDateTime;
      notesController.text = activity.data['notes'] ?? '';
      temperature = (activity.data['temperature'] as num?)?.toDouble();
      temperatureUnit = activity.data['temperatureUnit'];
    } else {
      selectedDatetime = DateTime.now();
    }
    super.initState();
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
                  CustomSheetHeader(
                    title: context.tr('fever_tracker'),
                    onBack: () => Navigator.of(context).pop(),
                    onSave: () => onPressedSave(),
                    saveText: widget.isEdit ? context.tr('update') : context.tr('save'),
                    backgroundColor: AppColors.feverTrackerColor,
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
                            Text(context.tr('time')),
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
                          title: context.tr('enter_baby_temperature'),
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
      ),
    );
  }

  void onPressedSave() {
    final activityName = ActivityType.fever.name;

    if (temperature == null) {
      showCustomFlushbar(
        context,
        context.tr('warning'),
        context.tr('please_enter_a_temperature'),
        Icons.warning_outlined,
      );
      return;
    }

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
        'startTimeHour': selectedDatetime?.hour,
        'startTimeMin': selectedDatetime?.minute,
        'notes': notesController.text,
        'temperature': temperature,
        'temperatureUnit': temperatureUnit,
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
  }
  _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      notesController.clear();
      temperature = null;
      temperatureUnit = null;
    });

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
