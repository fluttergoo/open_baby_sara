import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/navigation_wrapper.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/core/utils/shared_prefs_helper.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/widgets/custom_bottom_sheet_header.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_input_field_with_toggle.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
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
    super.initState();
    
    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;
      
      // Backward compatibility: use measurementTimeDate if available, otherwise use activityDateTime
      if (data['measurementTimeDate'] != null) {
        selectedDatetime = DateTime.parse(data['measurementTimeDate']);
      } else {
        selectedDatetime = widget.existingActivity!.activityDateTime;
      }
      
      notesController.text = data['notes'] ?? '';
      weight = (data['weight'] as num?)?.toDouble();
      weightUnit = data['weightUnit'];
      height = (data['height'] as num?)?.toDouble();
      heightUnit = data['heightUnit'];
      headSize = (data['headSize'] as num?)?.toDouble();
      headSizeUnit = data['headSizeUnit'];
    } else {
      // New record mode - load temporarily saved notes
      selectedDatetime = DateTime.now();
      Future.microtask(() async {
        final savedNotes = await SharedPrefsHelper.getGrowthTrackerNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty) {
          setState(() {
            notesController.text = savedNotes;
          });
        }
      });
    }
    
    // Listen to notes changes and save
    notesController.addListener(_onNotesChanged);
    
    getIt<AnalyticsService>().logScreenView('GrowthDevelopmentActivityTracker');
  }

  void _onNotesChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveGrowthTrackerNotes(widget.babyID, notesController.text);
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
                    saveText:
                        widget.isEdit
                            ? context.tr('update')
                            : context.tr('save'),
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
                              key: ValueKey('growth_time_${selectedDatetime?.millisecondsSinceEpoch}'),
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

  void _showError(String message) {
    showCustomFlushbar(context, context.tr("warning"), message, Icons.warning);
  }

  void onPressedSave() async {
    final activityName = ActivityType.growth.name;

    // Scenario 3.1: At least one measurement required
    if (weight == null && height == null && headSize == null) {
      _showError(context.tr("please_enter_growth_information") ?? 
          "Please enter growth information");
      return;
    }

    // Scenario 3.2: Future date check
    final now = DateTime.now();
    if (selectedDatetime == null || selectedDatetime!.isAfter(now)) {
      _showError(context.tr("date_in_future") ?? 
          "Date cannot be in the future");
      return;
    }

    // Scenario 3.3: Too old date check (1 year ago)
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (selectedDatetime!.isBefore(oneYearAgo)) {
      _showError(context.tr("date_too_old") ?? 
          "Date cannot be more than 1 year ago");
      return;
    }

    final activityModel = ActivityModel(
      activityID:
          widget.isEdit
              ? widget.existingActivity!.activityID
              : const Uuid().v4(),
      activityType: activityName,
      createdAt:
          widget.isEdit ? widget.existingActivity!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime!,
      data: {
        // New format: Full DateTime objects
        'measurementTimeDate': selectedDatetime!.toIso8601String(),
        // Backward compatibility: Hour/minute info
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
        context.read<ActivityBloc>().add(
          UpdateActivity(activityModel: activityModel),
        );
      } else {
        context.read<ActivityBloc>().add(
          AddActivity(activityModel: activityModel),
        );
      }

      // Clear all temporary data when save is successful
      if (!widget.isEdit) {
        await SharedPrefsHelper.clearGrowthTrackerNotes(widget.babyID);
      }

      // BlocListener will handle closing the bottom sheet after state is emitted
    } catch (e) {
      showCustomFlushbar(
        context,
        'Warning',
        'Error ${e.toString()}',
        Icons.warning_outlined,
      );
    }
  }

  _onPressedDelete(BuildContext context) async {
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

    // Clear temporary notes
    if (!widget.isEdit) {
      await SharedPrefsHelper.clearGrowthTrackerNotes(widget.babyID);
    }

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
