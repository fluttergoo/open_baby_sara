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

  const CustomVaccinationTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
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
        child: Container(
          height: 600.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(child: Column(children: [

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
                    'Vaccination Tracker',
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
                      Text('Vaccinations'),
                      TextButton(
                        onPressed: () {
                          showDialogAddAndVaccination(
                            buildContext: context,
                            onAdd: (selectedList) {
                               selectedVaccinations = selectedList!;
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

                  if (selectedVaccinations.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Text('Your Vaccination(s)'),
                    Divider(color: Colors.grey.shade300),


                    ...selectedVaccinations.map((med) {
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
                                      selectedVaccinations.remove(med);
                                    });
                                  },
                                ),
                                Expanded(flex: 2, child: Text(med,style: Theme.of(context).textTheme.titleMedium,)),

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


          ])),
        ),
      ),
    );
  }

  void onPressedSave() {
    final bool hasValidMedications = selectedVaccinations.any((med) =>
    (med != null && med.isNotEmpty));

    if (!hasValidMedications) {
      showCustomFlushbar(
        context,
        'Warning',
        'Please enter a vaccination.',
        Icons.warning_outlined,
      );
      return;
    }


    final activityName = ActivityType.vaccination.name;

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
          'medications': selectedVaccinations
              .where((med) =>
          (med != null && med.isNotEmpty))
              .map((med) => {
            'name': med,}).toList(),
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
