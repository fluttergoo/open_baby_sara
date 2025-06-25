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

class CustomGrowthDevelopmentTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomGrowthDevelopmentTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
  });

  @override
  State<CustomGrowthDevelopmentTrackerBottomSheet> createState() =>
      _CustomGrowthDevelopmentState();
}

class _CustomGrowthDevelopmentState
    extends State<CustomGrowthDevelopmentTrackerBottomSheet> {
  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  double? weight;
  String? weightUnit;
  double? height;
  String? heightUnit;
  double? headSize;
  String? headSizeUnit;

  @override
  void initState() {
    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;
      selectedDatetime = widget.existingActivity!.activityDateTime;
      notesController.text = data['notes'] ?? '';
      weight = (data['weight'] as num?)?.toDouble();
      weightUnit = data['weightUnit'];
      height = (data['height'] as num?)?.toDouble();
      heightUnit = data['heightUnit'];
      headSize = (data['headSize'] as num?)?.toDouble();
      headSizeUnit = data['headSizeUnit'];
    } else {
      selectedDatetime = DateTime.now();
    }    super.initState();
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
                    title: context.tr('growth_tracker'),
                    onBack: () => Navigator.of(context).pop(),
                    onSave: () => onPressedSave(),
                    saveText: widget.isEdit ? context.tr('update') : context.tr('save'),
                    backgroundColor: AppColors.growthColor,
                  ),

                  //Body
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
                          title: context.tr('add_weight'),
                          selectedMeasurementOfUnit:
                              MeasurementOfUnitNames.weight,
                          onChanged: (val, unit) {
                            weight = val;
                            weightUnit = unit;
                          },
                        ),
                        Divider(color: Colors.grey.shade300),
                        CustomInputFieldWithToggle(
                          title: context.tr('add_height'),
                          selectedMeasurementOfUnit:
                              MeasurementOfUnitNames.height,
                          onChanged: (val, unit) {
                            height = val;
                            heightUnit = unit;
                          },
                        ),
                        Divider(color: Colors.grey.shade300),
                        CustomInputFieldWithToggle(
                          title: context.tr('add_head_size'),
                          selectedMeasurementOfUnit:
                              MeasurementOfUnitNames.height,
                          onChanged: (val, unit) {
                            headSize = val;
                            headSizeUnit = unit;
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
    final activityName = ActivityType.growth.name;

    if (weight == null && height == null && headSize == null) {
      showCustomFlushbar(
        context,
        'Warning',
        'Please enter growth information',
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
        'height': height,
        'heightUnit': heightUnit,
        'weight': weight,
        'weightUnit': weightUnit,
        'headSize': headSize,
        'headSizeUnit': headSizeUnit,
      },
      isSynced: false,
      createdBy: widget.firstName,
      babyID: widget.babyID,
    );

    try {
      if (widget.isEdit) {
        context.read<ActivityBloc>().add(UpdateActivity(activityModel: activityModel));
      } else {
        context.read<ActivityBloc>().add(AddActivity(activityModel: activityModel));
      }

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
  _onPressedDelete(BuildContext context) {
    setState(() {
      weight = null;
      weightUnit = null;
      height = null;
      heightUnit = null;
      headSize = null;
      headSizeUnit = null;
      notesController.clear();
      selectedDatetime = DateTime.now();
    });

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
