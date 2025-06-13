import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/medication/medication_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/medication_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/medication_list_and_add_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomMedicalTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomMedicalTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
  });

  @override
  State<CustomMedicalTrackerBottomSheet> createState() =>
      _CustomMedicalTrackerBottomSheetState();
}

class _CustomMedicalTrackerBottomSheetState
    extends State<CustomMedicalTrackerBottomSheet> {
  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();

  List<MedicationModel> selectedMedications = [];

  @override
  void initState() {
    context.read<MedicationBloc>().add(FetchMedications());
    super.initState();
    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;
      selectedDatetime = widget.existingActivity!.activityDateTime;
      notesController.text = data['notes'] ?? '';
      if (data['medications'] != null) {
        selectedMedications =
            (data['medications'] as List)
                .map(
                  (e) => MedicationModel(
                    name: e['name'] ?? '',
                    amount: e['amount'] ?? '',
                    unit: e['unit'] ?? 'none',
                  ),
                )
                .toList();
      }
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
                      color: AppColors.medicalColor,
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
                          context.tr('medical_tracker'),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(context.tr('medications')),
                            TextButton(
                              onPressed: () {
                                showMedicationDialog(
                                  buildContext: context,
                                  onAdd: (selectedList) {
                                    selectedMedications = selectedList!;
                                    setState(() {});
                                  },
                                );
                              },
                              child: Text(context.tr('add')),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade300),

                        if (selectedMedications.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Text(context.tr('your_medication')),
                          Divider(color: Colors.grey.shade300),

                          ...selectedMedications.map((med) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 16.sp,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedMedications.remove(med);
                                          });
                                        },
                                      ),
                                      Expanded(flex: 2, child: Text(med.name)),

                                      SizedBox(width: 10.w),

                                      // Amount input
                                      Expanded(
                                        flex: 3,
                                        child: CustomTextFormField(
                                          hintText: context.tr('amount'),
                                          controller: med.controller,
                                          keyboardType: TextInputType.number,
                                          onChanged: (val) => med.amount = val,
                                        ),
                                      ),

                                      SizedBox(width: 10.w),

                                      // Unit dropdown
                                      DropdownButton<String>(
                                        value: med.unit,
                                        items:
                                            [
                                                  'drops',
                                                  'mg',
                                                  'mL',
                                                  'tabs',
                                                  'tsp',
                                                  'none',
                                                ]
                                                .map(
                                                  (unit) => DropdownMenuItem(
                                                    value: context.tr(unit),
                                                    child: Text(
                                                      context.tr(unit),
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            med.unit = val!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.grey.shade300),
                                ],
                              ),
                            );
                          }).toList(),
                        ],

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
    final bool hasValidMedications = selectedMedications.any(
          (med) => (med.amount != null && med.amount!.isNotEmpty) &&
          (med.unit != null && med.unit!.isNotEmpty),
    );

    if (!hasValidMedications) {
      showCustomFlushbar(
        context,
        'Warning',
        'Please enter a medication.',
        Icons.warning_outlined,
      );
      return;
    }

    final activityName = ActivityType.medication.name;

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
        'medications': selectedMedications
            .where((med) =>
        (med.amount != null && med.amount!.isNotEmpty) &&
            (med.unit != null && med.unit!.isNotEmpty))
            .map((med) => {
          'name': med.name,
          'amount': med.amount,
          'unit': med.unit,
        })
            .toList(),
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
      selectedMedications.clear();
    });

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
