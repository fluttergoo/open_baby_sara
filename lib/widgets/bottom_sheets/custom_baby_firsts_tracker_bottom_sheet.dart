import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/navigation_wrapper.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/blocs/milestone/milestone_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/core/utils/shared_prefs_helper.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/models/milestones_model.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/widgets/custom_bottom_sheet_header.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomBabyFirstsTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final ActivityModel? existingActivity;
  final bool isEdit;

  const CustomBabyFirstsTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.existingActivity,
    this.isEdit = false,
  });

  @override
  State<CustomBabyFirstsTrackerBottomSheet> createState() =>
      _CustomBabyFirstsTrackerBottomSheetState();
}

class _CustomBabyFirstsTrackerBottomSheetState
    extends State<CustomBabyFirstsTrackerBottomSheet> {
  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.existingActivity != null) {
      selectedDatetime = widget.existingActivity!.activityDateTime;
      notesController.text = widget.existingActivity!.data['notes'] ?? '';
      selectedMilestoneTitle = List<String>.from(
        widget.existingActivity!.data['milestoneTitle'] ?? [],
      );
      selectedMilestoneDesc = List<String>.from(
        widget.existingActivity!.data['milestoneDesc'] ?? [],
      );
    } else {
      // New record mode - load temporarily saved notes
      Future.microtask(() async {
        final savedNotes = await SharedPrefsHelper.getBabyFirstsTrackerNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty && mounted) {
          setState(() {
            notesController.text = savedNotes;
          });
        }
      });
    }

    // Listen to notes changes and save
    notesController.addListener(_onNotesChanged);

    context.read<MilestoneBloc>().add(LoadMilestones());
    getIt<AnalyticsService>().logScreenView('BabyFirstActivityTracker');
  }

  void _onNotesChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveBabyFirstsTrackerNotes(widget.babyID, notesController.text);
    }
  }

  @override
  void dispose() {
    // Remove notes listener
    notesController.removeListener(_onNotesChanged);
    // Dispose controller
    notesController.dispose();
    super.dispose();
  }

  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  List<MonthlyMilestonesModel>? monthlyMilestone;
  List<String>? selectedMilestoneTitle;
  List<String>? selectedMilestoneDesc;

  void _showError(String message) {
    showCustomFlushbar(
      context,
      context.tr('error') ?? 'Error',
      message,
      Icons.error_outline,
      color: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listenWhen: (previous, current) => 
          current is ActivityAdded || current is ActivityUpdated,
      listener: (context, state) {
        // Get root navigator context for showing flushbar
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        final rootContext = rootNavigator.context;
        
        // Close bottom sheet first
        if (mounted) {
          final bottomSheetNavigator = Navigator.of(context, rootNavigator: false);
          if (bottomSheetNavigator.canPop()) {
            bottomSheetNavigator.pop();
          }
        }
        
        // Show flushbar in root context after a short delay
        Future.delayed(const Duration(milliseconds: 150), () {
          if (rootContext.mounted) {
            final message = state is ActivityAdded
                ? context.tr('activity_was_added')
                : (context.tr('activity_was_updated') ?? context.tr('activity_was_added'));
            showCustomFlushbar(
              rootContext,
              context.tr('success'),
              message,
              Icons.add_task_outlined,
              color: Colors.green,
            );
          }
        });
      },
      child: BlocBuilder<MilestoneBloc, MilestoneState>(
        builder: (context, state) {
          if (state is MilestoneLoaded) {
            monthlyMilestone = state.milestones;
            context.read<MilestoneBloc>().add(
              LoadMilestonesTitleFromDB(babyID: widget.babyID),
            );
          }
          if (state is MilestoneError) {
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      CustomSheetHeader(
                        title: context.tr('baby_firsts'),
                        onBack: () => Navigator.of(context).pop(),
                        onSave: () => onPressedSave(),
                        saveText:
                            widget.isEdit
                                ? context.tr('update')
                                : context.tr('save'),
                        backgroundColor: AppColors.babyFirstsColor,
                      ),

                      /// Body
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.only(
                            left: 16.r,
                            right: 16.r,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 20,
                            top: 16,
                          ),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr('time')),
                                CustomDateTimePicker(
                                  key: ValueKey('baby_firsts_time_${selectedDatetime?.millisecondsSinceEpoch}'),
                                  initialText: 'initialText',
                                  initialDateTime: selectedDatetime,
                                  maxDate: DateTime.now(), // Prevent future dates
                                  minDate: DateTime.now().subtract(const Duration(days: 365)), // 1 year ago limit
                                  onDateTimeSelected: (selected) {
                                    // Future date check
                                    final now = DateTime.now();
                                    if (selected.isAfter(now)) {
                                      _showError(context.tr("date_in_future") ?? 
                                          "Date cannot be in the future");
                                      return;
                                    }
                                    
                                    // Too old date check (1 year ago)
                                    final oneYearAgo = now.subtract(const Duration(days: 365));
                                    if (selected.isBefore(oneYearAgo)) {
                                      _showError(context.tr("date_too_old") ?? 
                                          "Date cannot be more than 1 year ago");
                                      return;
                                    }
                                    
                                    setState(() {
                                      selectedDatetime = selected;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr('baby_firsts')),
                                TextButton(
                                  onPressed: () {
                                    _onPressedAdd();
                                  },
                                  child: Text(context.tr("add")),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            selectedMilestoneToggleWidget(),
                            SizedBox(height: 5.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                context.tr("notes:"),
                                style: Theme.of(context).textTheme.titleSmall!
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
        },
      ),
    );
  }

  void onPressedSave() {
    final activityName = ActivityType.babyFirsts.name;

    // Scenario 3.1: Milestone seçimi kontrolü
    if (selectedMilestoneTitle == null || 
        selectedMilestoneTitle!.isEmpty ||
        selectedMilestoneDesc == null ||
        selectedMilestoneDesc!.isEmpty) {
      _showError(context.tr("please_enter_baby_first_activity") ?? 
          "Please enter baby first activity");
      return;
    }

    // Scenario 3.2: Gelecekteki tarih kontrolü
    if (selectedDatetime == null) {
      _showError(context.tr("please_select_time") ?? 
          "Please select time");
      return;
    }

    final now = DateTime.now();
    if (selectedDatetime!.isAfter(now)) {
      _showError(context.tr("date_in_future") ?? 
          "Date cannot be in the future");
      return;
    }

    // Scenario 3.3: Çok eski tarih kontrolü (1 yıl öncesi)
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (selectedDatetime!.isBefore(oneYearAgo)) {
      _showError(context.tr("date_too_old") ?? 
          "Date cannot be more than 1 year ago");
      return;
    }

    final activityModel = ActivityModel(
      activityID:
          widget.isEdit ? widget.existingActivity!.activityID : Uuid().v4(),
      activityType: activityName,
      createdAt:
          widget.isEdit ? widget.existingActivity!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime!,
      data: {
        'startTimeHour': selectedDatetime?.hour,
        'startTimeMin': selectedDatetime?.minute,
        'notes': notesController.text,
        'milestoneTitle': selectedMilestoneTitle,
        'milestoneDesc': selectedMilestoneDesc,
      },
      isSynced: false,
      createdBy: widget.firstName,
      babyID: widget.babyID,
    );

    try {
      if (widget.isEdit) {
        context.read<ActivityBloc>().add(
          UpdateActivity(activityModel: activityModel),
        );
      } else {
        context.read<ActivityBloc>().add(
          AddActivity(activityModel: activityModel),
        );
        // Clear temporarily saved notes after successful save
        SharedPrefsHelper.clearBabyFirstsTrackerNotes(widget.babyID);
      }

      // BlocListener will handle closing the bottom sheet after state is emitted
    } catch (e) {
      _showError('Error ${e.toString()}');
    }
  }

  _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      notesController.clear();
      selectedMilestoneTitle = [];
      selectedMilestoneDesc = [];
    });

    // Clear temporarily saved notes
    if (!widget.isEdit) {
      SharedPrefsHelper.clearBabyFirstsTrackerNotes(widget.babyID);
    }

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }

  void _onPressedAdd() {
    if (monthlyMilestone == null) return;

    showDialog(
      context: context,
      builder: (context) {
        List<String> selectedMilestones = [];
        final List<String> selectedMilestonesTitle = [];
        final List<String> selectedMilestonesDesc = [];
        Set<String>? savedTitleSet;

        return BlocBuilder<MilestoneBloc, MilestoneState>(
          builder: (context, state) {
            if (state is MilestoneTitleLoadedFromDB) {
              selectedMilestones = state.milestoneTitle;
              savedTitleSet = selectedMilestones.toSet();
              debugPrint(selectedMilestones.length.toString());
            }
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
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
                          context.tr('select_baby_firsts'),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),

                    /// Date Picker in Dialog (Scenario 1.5, 5.5)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('time'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          CustomDateTimePicker(
                            key: ValueKey('dialog_time_${selectedDatetime?.millisecondsSinceEpoch}'),
                            initialText: 'initialText',
                            initialDateTime: selectedDatetime,
                            maxDate: DateTime.now(), // Prevent future dates
                            minDate: DateTime.now().subtract(const Duration(days: 365)), // 1 year ago limit
                            onDateTimeSelected: (selected) {
                              // Future date check
                              final now = DateTime.now();
                              if (selected.isAfter(now)) {
                                showCustomFlushbar(
                                  context,
                                  context.tr('error') ?? 'Error',
                                  context.tr("date_in_future") ?? 
                                      "Date cannot be in the future",
                                  Icons.error_outline,
                                  color: Colors.red,
                                );
                                return;
                              }
                              
                              // Too old date check (1 year ago)
                              final oneYearAgo = now.subtract(const Duration(days: 365));
                              if (selected.isBefore(oneYearAgo)) {
                                showCustomFlushbar(
                                  context,
                                  context.tr('error') ?? 'Error',
                                  context.tr("date_too_old") ?? 
                                      "Date cannot be more than 1 year ago",
                                  Icons.error_outline,
                                  color: Colors.red,
                                );
                                return;
                              }
                              
                              // Update main form's date (Scenario 1.5: Dialog içinde tarih seçildiğinde ana formdaki tarih güncellenmeli)
                              // Note: setState here refers to the outer widget's state since we're in a closure
                              setState(() {
                                selectedDatetime = selected;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey.shade300),

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
                                  margin: EdgeInsets.symmetric(
                                    vertical: 4.r,
                                    horizontal: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 1,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      title: Text(
                                        '${context.tr('month')} ${monthData.month}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      children:
                                          monthData.milestones.map((milestone) {
                                            final bool isPreviouslySelected;
                                            if (savedTitleSet == null) {
                                              isPreviouslySelected = false;
                                            } else {
                                              isPreviouslySelected =
                                                  savedTitleSet!.contains(
                                                    milestone.titleKey,
                                                  );
                                            }
                                            final isSelected =
                                                selectedMilestones.contains(
                                                  milestone.titleKey,
                                                );
                                            return CheckboxListTile(
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(
                                                context.tr(milestone.titleKey),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              subtitle: Text(
                                                context.tr(
                                                  milestone.descriptionKey,
                                                ),
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                              value: isSelected,
                                              onChanged:
                                                  isPreviouslySelected
                                                      ? null
                                                      : (val) {
                                                        setState(() {
                                                          if (val == true) {
                                                            selectedMilestones
                                                                .add(
                                                                  milestone
                                                                      .titleKey,
                                                                );
                                                            selectedMilestonesTitle
                                                                .add(
                                                                  milestone
                                                                      .titleKey,
                                                                );
                                                            selectedMilestonesDesc
                                                                .add(
                                                                  milestone
                                                                      .descriptionKey,
                                                                );
                                                          } else {
                                                            selectedMilestones
                                                                .remove(
                                                                  milestone
                                                                      .titleKey,
                                                                );
                                                            selectedMilestonesTitle
                                                                .remove(
                                                                  milestone
                                                                      .titleKey,
                                                                );
                                                            selectedMilestonesDesc
                                                                .remove(
                                                                  milestone
                                                                      .descriptionKey,
                                                                );
                                                          }
                                                        });
                                                      },
                                            );
                                          }).toList(),
                                    ),
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
                          child: Text(context.tr('cancel')),
                        ),
                        SizedBox(width: 10.w),
                        ElevatedButton.icon(
                          icon: Icon(Icons.check, color: Colors.white),
                          onPressed: () {
                            print(
                              '${context.tr('selected_milestones')} $selectedMilestones',
                            );
                            selectedMilestoneTitle = selectedMilestonesTitle;
                            selectedMilestoneDesc = selectedMilestonesDesc;
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          label: Text(
                            context.tr("add"),
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
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
      },
    );
  }

  Widget selectedMilestoneToggleWidget() {
    if (selectedMilestoneTitle == null || selectedMilestoneTitle!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('select_baby_firsts')),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children:
                selectedMilestoneTitle!
                    .map(
                      (title) => Chip(
                        label: Text(context.tr(title)),
                        backgroundColor: AppColors.babyFirstsColor,

                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        deleteIcon: Icon(Icons.close, size: 18.sp),
                        onDeleted: () {
                          setState(() {
                            final index = selectedMilestoneTitle!.indexOf(
                              title,
                            );
                            selectedMilestoneDesc?.removeAt(index);
                            selectedMilestoneTitle?.removeAt(index);
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
