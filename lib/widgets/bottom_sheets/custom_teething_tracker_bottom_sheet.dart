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
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_teeth_selector.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomTeethingTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomTeethingTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomTeethingTrackerBottomSheet> createState() =>
      _CustomTeethingTrackerBottomSheetState();
}

class _CustomTeethingTrackerBottomSheetState
    extends State<CustomTeethingTrackerBottomSheet> {
  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  bool isErupted = false;
  bool isShed = false;
  String? teethingIsoNumber;
  List<String>? initilizeTeeth;

  @override
  void initState() {
    context.read<ActivityBloc>().add(
      FetchToothIsoNumber(
        babyID: widget.babyID,
        activityType: ActivityType.teething.name,
      ),
    );
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

      child: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state is FetchToothIsoNumberLoaded) {
            initilizeTeeth = state.toothIsoNumber;
            debugPrint('tamamdir ');

            debugPrint(initilizeTeeth!.length.toString());
          }

          return state is ActivityLoading
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    height: 600.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
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
                              color: AppColors.teethingColor,
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
                                  'Teething',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Body
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.only(
                                left: 16.r,
                                right: 16.r,
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                    20,
                                top: 16,
                              ),
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Baby firsts'),
                                    TextButton(
                                      onPressed: () {
                                        _onPressedAdd();
                                      },
                                      child: Text('Add'),
                                    ),
                                  ],
                                ),

                                CustomTeethSelector(
                                  key: ValueKey(initilizeTeeth?.join(',')),
                                  onSave: null,
                                  isShowDetailTooth: true,
                                  initilizeTeeth: initilizeTeeth,
                                  isColor: false,
                                  isMultiSelect: false,
                                ),
                                Divider(color: Colors.grey.shade300),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                SizedBox(height: 5.h),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Notes:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(fontSize: 16.sp),
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
              );
        },
      ),
    );
  }

  void onPressedSave() {
    final activityName = ActivityType.teething.name;

    if (teethingIsoNumber == null || isErupted == false && isShed == false) {
      showCustomFlushbar(
        context,
        'Warning',
        'Please enter teething information',
        Icons.warning_outlined,
      );
    } else {
      final activityModel = ActivityModel(
        activityID: Uuid().v4(),
        activityType: activityName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        data: {
          'startTimeHour': selectedDatetime?.hour,
          'startTimeMin': selectedDatetime?.minute,
          'notes': notesController.text,
          'teethingIsoNumber': teethingIsoNumber,
          isErupted == true ? 'isErupted' : 'isShed': true,
        },
        isSynced: false,
        createdBy: widget.firstName,
        babyID: widget.babyID,
      );
      try {
        context.read<ActivityBloc>().add(
          AddActivity(activityModel: activityModel),
        );

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
  }

  _onPressedDelete(BuildContext context) {}

  void _onPressedAdd() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                //padding: EdgeInsets.all(16.r),
                constraints: BoxConstraints(maxHeight: 600.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //header
                    Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.r,
                        vertical: 12.r,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teethingColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Teething',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
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
                          CustomTeethSelector(
                            onSave: (List<String> listName) {
                              teethingIsoNumber = listName.last.toString();
                            },
                            isShowDetailTooth: false,
                            isColor: true,
                            isMultiSelect: false,
                          ),
                          Divider(color: Colors.grey.shade300),
                          customCheckboxTile(
                            label: "Erupted",
                            value: isErupted,
                            onChanged: (val) {
                              setState(() {
                                isErupted = val;
                                isShed = false;
                              });
                            },
                          ),
                          Divider(color: Colors.grey.shade300),
                          customCheckboxTile(
                            label: "Shed",
                            value: isShed,
                            onChanged: (val) {
                              setState(() {
                                isShed = val;
                                isErupted = false;
                              });
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/*
  ListTile(
                      leading: SizedBox(
                        width: 100,
                        height: 100,
                        child: TeethSelector(
                          showPrimary: true,
                          showPermanent: false,
                          multiSelect: false,
                          initiallySelected: ['61'],
                          selectedColor: Colors.transparent,
                          unselectedColor: Colors.transparent, // diğerleri görünmesin
                          colorized: {'61': Colors.purple},
                          StrokedColorized: {'61': Colors.purple}, // ✅ doğru yazım
                          defaultStrokeColor: Colors.grey,
                          defaultStrokeWidth: 1.5,
                          onChange: (_) {},
                          notation: (_) => '',
                        ),
                      ),
                      title: SizedBox(
                        width: 150,
                        height: 150,
                        child: TeethSelector(
                          showPrimary: true,
                          showPermanent: false,
                          multiSelect: false,
                          initiallySelected: ['61'],
                          selectedColor: Colors.transparent,
                          unselectedColor: Colors.transparent, // diğerleri görünmesin
                          colorized: {'61': Colors.purple},
                          StrokedColorized: {'61': Colors.purple}, // ✅ doğru yazım
                          defaultStrokeColor: Colors.grey,
                          defaultStrokeWidth: 1.5,
                          onChange: (_) {},
                          notation: (_) => '',
                        ),
                      ),
                      subtitle: const Text("Typically erupts between 8–12 months"),
                    ),

 */
