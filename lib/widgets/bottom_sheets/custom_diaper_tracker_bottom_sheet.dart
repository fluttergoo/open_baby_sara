import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/app/routes/navigation_wrapper.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/activity/activity_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/build_custom_snack_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_check_box_tile.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_show_flush_bar.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/dirty_detail_options.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/wet_dirty_dry_selector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomDiaperTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomDiaperTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomDiaperTrackerBottomSheet> createState() =>
      _CustomDiaperTrackerBottomSheetState();
}

class _CustomDiaperTrackerBottomSheetState
    extends State<CustomDiaperTrackerBottomSheet> {
  TextEditingController notesController = TextEditingController();
  String textTimeAndDate = '';
  DateTime? selectedDatetime =DateTime.now();
  List<String> selectedMain = [];
  List<String> selectedTextures = [];
  List<String> selectedColors = [];
  bool isBlowout = false;
  bool isDiaperRush = false;
  bool isBloodInStool = false;


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
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: 600.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 12.r,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.diaperColor,
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
                        context.tr("diaper_tracker"),
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
                          context.tr("save"),
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

                // Body: SCROLLABLE
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
                          Text(context.tr("time")),
                          CustomDateTimePicker(
                            initialText: 'initialText',
                            onDateTimeSelected: (selected) {
                              selectedDatetime=selected;
                            },
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),
                      Text(context.tr("select_diaper_condition")),
                      SizedBox(height: 10.h),
                      WetDirtyDrySelector(
                        onChanged: (selectedValue) {
                          setState(() {
                            selectedMain = selectedValue;
                          });
                        },
                      ),
                      SizedBox(height: 5.h),

                      if (selectedMain.contains('Dirty'))
                        Divider(color: Colors.grey.shade300),
                      if (selectedMain.contains('Dirty'))
                        DirtyDetailOptions(
                          onChanged: ({
                            required List<String> selectedTextures,
                            required List<String> selectedColors,
                          }) {
                            this.selectedTextures = selectedTextures;
                            this.selectedColors = selectedColors;
                          },
                        ),

                      Divider(color: Colors.grey.shade300),
                      Text(context.tr("additional_observations")),
                      customCheckboxTile(
                        label: context.tr("blowout"),
                        value: isBlowout,
                        onChanged: (val) => setState(() => isBlowout = val),
                      ),
                      customCheckboxTile(
                        label: context.tr("diaper_rush"),
                        value: isDiaperRush,
                        onChanged: (val) => setState(() => isDiaperRush = val),
                      ),
                      customCheckboxTile(
                        label: context.tr("blood_in_stool"),
                        value: isBloodInStool,
                        onChanged:
                            (val) => setState(() => isBloodInStool = val),
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
    );
  }

  void onPressedSave() {
    final activityName = ActivityType.diaper.name;
    if (selectedMain.isEmpty) {
      showCustomFlushbar(
        context,
        context.tr("warning"),
        context.tr("please_choose_diaper_condition"),
        Icons.warning_outlined,
      );
    } else {
      final activityModel = ActivityModel(
        activityID: Uuid().v4(),
        activityType: activityName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        data: {
          'activityDay' : selectedDatetime?.toIso8601String(),
          'startTimeHour': selectedDatetime?.hour,
          'startTimeMin': selectedDatetime?.minute,
          'notes': notesController.text,
          'mainSelection': selectedMain,
          'textures': selectedTextures,
          'colors': selectedColors,
          'isBlowout': isBlowout,
          'isDiaperRush': isDiaperRush,
          'isBloodInStool': isBloodInStool,
        },
        isSynced: false,
        createdBy: widget.firstName,
        babyID: widget.babyID,
      );
      try{
        context.read<ActivityBloc>().add(AddActivity(activityModel: activityModel));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => NavigationWrapper()),
        );
      }catch(e){
        showCustomFlushbar(
          context,
          context.tr("warning"),
          'Error ${e.toString()}',
          Icons.warning_outlined,
        );
      }

    }
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      selectedMain.clear();
      selectedTextures.clear();
      selectedColors.clear();
      isBlowout = false;
      isDiaperRush = false;
      isBloodInStool = false;
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
