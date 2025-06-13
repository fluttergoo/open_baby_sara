import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/vaccination/vaccination_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/show_dialog_add_vaccination.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomVaccinationTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomVaccinationTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
  });

  @override
  State<CustomVaccinationTrackerBottomSheet> createState() =>
      _CustomVaccinationTrackerBottomSheetState();
}

class _CustomVaccinationTrackerBottomSheetState
    extends State<CustomVaccinationTrackerBottomSheet> {
  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  List<String> selectedVaccinations = [];

  @override
  void initState() {
    context.read<VaccinationBloc>().add(FetchVaccination());
    if (widget.isEdit && widget.existingActivity != null) {
      final activity = widget.existingActivity!;
      selectedDatetime = activity.activityDateTime;
      notesController.text = activity.data['notes'] ?? '';
      selectedVaccinations =
          (activity.data['medications'] as List<dynamic>)
              .map((e) => e['name'].toString())
              .toList();
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
                    color: AppColors.vaccineColor,
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
                        context.tr('vaccination_tracker'),
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
                          Text(context.tr('vaccinations')),
                          TextButton(
                            onPressed: () {
                              showDialogAddAndVaccination(
                                buildContext: context,
                                onAdd: (selectedList) {
                                  selectedVaccinations = selectedList!;
                                  setState(() {});
                                },
                              );
                            },
                            child: Text(context.tr('add')),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      if (selectedVaccinations.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(context.tr('your_vaccination')),
                        Divider(color: Colors.grey.shade300),

                        ...selectedVaccinations.map((med) {
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
                                          selectedVaccinations.remove(med);
                                        });
                                      },
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        med,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
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
    );
  }

  void onPressedSave() {
    final bool hasValidMedications = selectedVaccinations.isNotEmpty;
    if (!hasValidMedications) {
      showCustomFlushbar(
        context,
        context.tr('warning'),
        context.tr('please_enter_a_vaccination'),
        Icons.warning_outlined,
      );
      return;
    }

    final activityModel = ActivityModel(
      activityID: widget.isEdit
          ? widget.existingActivity!.activityID
          : const Uuid().v4(),
      activityType: ActivityType.vaccination.name,
      createdAt: widget.isEdit
          ? widget.existingActivity!.createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime!,
      data: {
        'startTimeHour': selectedDatetime?.hour,
        'startTimeMin': selectedDatetime?.minute,
        'notes': notesController.text,
        'medications': selectedVaccinations.map((e) => {'name': e}).toList(),
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

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const NavigationWrapper()));
  }
  _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      notesController.clear();
      selectedVaccinations.clear();
    });

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
