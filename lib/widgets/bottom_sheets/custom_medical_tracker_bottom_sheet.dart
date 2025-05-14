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

  const CustomMedicalTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
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
                        child: Icon(Icons.arrow_back, color: Colors.deepPurple),
                      ),
                      Text(
                        'Medical Tracker',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Medications'),
                          TextButton(
                            onPressed: () {
                              showMedicationDialog(
                                buildContext: context,
                                onAdd: (selectedList) {
                                  selectedMedications = selectedList!;
                                      setState(() {

                                      });
                                },
                              );
                            },
                            child: Text('Add'),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      if (selectedMedications.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text('Your Medication(s)'),
                        Divider(color: Colors.grey.shade300),


                        ...selectedMedications.map((med) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Column(
                              children: [
                                Row(
                                  children: [

                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red,size: 16.sp,),
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
                                        hintText: 'Amount',
                                        controller: med.controller,
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) => med.amount = val,


                                      ),
                                    ),

                                    SizedBox(width: 10.w),

                                    // Unit dropdown
                                    DropdownButton<String>(
                                      value: med.unit,
                                      items: ['drops', 'mg', 'mL','tabs','tsp','none']
                                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit, style: Theme.of(context).textTheme.bodyMedium,)))
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
    final bool hasValidMedications = selectedMedications.any((med) =>
    (med.amount != null && med.amount!.isNotEmpty) &&
        (med.unit != null && med.unit!.isNotEmpty));


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
      activityID: Uuid().v4(),
      activityType: activityName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'startTimeHour': selectedDatetime?.hour,
        'startTimeMin': selectedDatetime?.minute,
        'notes': notesController.text,
        if (hasValidMedications)
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

    context.read<ActivityBloc>().add(AddActivity(activityModel: activityModel));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => NavigationWrapper()),
    );

  }

  _onPressedDelete(BuildContext context) {}
}
