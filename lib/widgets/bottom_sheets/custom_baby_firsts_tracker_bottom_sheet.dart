import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/milestone/milestone_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/milestones_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_date_time_picker.dart';
import 'package:flutter_sara_baby_tracker_and_sound/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBabyFirstsTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;

  const CustomBabyFirstsTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
  });

  @override
  State<CustomBabyFirstsTrackerBottomSheet> createState() =>
      _CustomBabyFirstsTrackerBottomSheetState();
}

class _CustomBabyFirstsTrackerBottomSheetState
    extends State<CustomBabyFirstsTrackerBottomSheet> {
  @override
  void initState() {
    context.read<MilestoneBloc>().add(LoadMilestones());
    super.initState();
  }

  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  List<MonthlyMilestonesModel>? monthlyMilestone;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MilestoneBloc, MilestoneState>(
      builder: (context, state) {
        if (state is MilestoneLoaded) {
          monthlyMilestone = state.milestones;
          debugPrint('buradayiz');
        }
        if(state is MilestoneError){
          debugPrint(state.message);
        }
        return GestureDetector(
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
                        color: AppColors.babyFirstsColor,
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
                            'Baby Firsts',
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

                    /// Body
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
                              Text('Baby firsts'),
                              TextButton(onPressed: (){
                                _onPressedAdd();
                              }, child: Text('Add'))
                            ],
                          ),

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
        );
      },
    );
  }

  void onPressedSave() {}

  _onPressedDelete(BuildContext context) {}

  void _onPressedAdd() {
    if (monthlyMilestone == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final selectedMilestones = <String>{};

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Container(
            padding: EdgeInsets.all(16.r),
            constraints: BoxConstraints(maxHeight: 600.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Baby Firsts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    )
                  ],
                ),
                Divider(),

                /// Body
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Scrollbar(
                        child: ListView.builder(
                          itemCount: monthlyMilestone!.length,
                          itemBuilder: (context, index) {
                            final monthData = monthlyMilestone![index];

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.r),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                              child: ExpansionTile(
                                title: Text(
                                  'Month ${monthData.month}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                children: monthData.milestones.map((milestone) {
                                  final isSelected =
                                  selectedMilestones.contains(milestone.titleKey);

                                  return CheckboxListTile(
                                    controlAffinity: ListTileControlAffinity.leading,
                                    title: Text(
                                      context.tr(milestone.titleKey),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    subtitle: Text(
                                      context.tr(milestone.descriptionKey),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          selectedMilestones.add(milestone.titleKey);
                                        } else {
                                          selectedMilestones.remove(milestone.titleKey);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 12.h),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton.icon(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        print('Selected Milestones: $selectedMilestones');
                        Navigator.of(context).pop();
                      },
                      label: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
