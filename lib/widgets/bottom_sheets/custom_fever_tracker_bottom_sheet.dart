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

class CustomFeverTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomFeverTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
  });

  @override
  State<CustomFeverTrackerBottomSheet> createState() =>
      _CustomFeverTrackerBottomSheetState();
}

class _CustomFeverTrackerBottomSheetState
    extends State<CustomFeverTrackerBottomSheet> {
  DateTime? selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  double? temperature;
  String? temperatureUnit;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.existingActivity != null) {
      final activity = widget.existingActivity!;
      final data = activity.data;
      
      // Backward compatibility: use feverTimeDate if available, otherwise use activityDateTime
      if (data['feverTimeDate'] != null) {
        selectedDatetime = DateTime.parse(data['feverTimeDate']);
      } else {
        selectedDatetime = activity.activityDateTime;
      }
      
      notesController.text = data['notes'] ?? '';
      temperature = (data['temperature'] as num?)?.toDouble();
      temperatureUnit = data['temperatureUnit'];
    } else {
      selectedDatetime = DateTime.now();
      
      // New record mode - load temporarily saved notes
      Future.microtask(() async {
        final savedNotes = await SharedPrefsHelper.getFeverTrackerNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty) {
          notesController.text = savedNotes;
        }
      });
    }

    // Listen to notes changes and save
    notesController.addListener(_onNotesChanged);

    getIt<AnalyticsService>().logScreenView('FeverActivityTracker');
  }

  void _onNotesChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveFeverTrackerNotes(widget.babyID, notesController.text);
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

  void _showError(String message) {
    showCustomFlushbar(
      context,
      context.tr('warning'),
      message,
      Icons.warning_outlined,
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
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  CustomSheetHeader(
                    title: context.tr('fever_tracker'),
                    onBack: () => Navigator.of(context).pop(),
                    onSave: () => onPressedSave(),
                    saveText:
                        widget.isEdit
                            ? context.tr('update')
                            : context.tr('save'),
                    backgroundColor: AppColors.feverTrackerColor,
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
                              key: ValueKey('fever_time_${selectedDatetime?.millisecondsSinceEpoch}'),
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
                          key: ValueKey('temperature_${temperature}_${temperatureUnit}'),
                          title: context.tr('enter_baby_temperature'),
                          selectedMeasurementOfUnit:
                              MeasurementOfUnitNames.temperature,
                          initialValue: temperature,
                          initialUnit: temperatureUnit,
                          onChanged: (val, unit) {
                            setState(() {
                              temperature = val;
                              temperatureUnit = unit;
                            });
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
    final activityName = ActivityType.fever.name;

    // Scenario 3.1: Temperature validation
    if (temperature == null) {
      _showError(context.tr('please_enter_a_temperature') ?? 
          'Please enter a temperature');
      return;
    }

    // Scenario 3.2: Temperature unit validation
    if (temperatureUnit == null || temperatureUnit!.isEmpty) {
      _showError(context.tr('please_select_temperature_unit') ?? 
          'Please select a temperature unit');
      return;
    }

    // Scenario 3.3: Future date check
    if (selectedDatetime == null) {
      _showError(context.tr("please_complete_all_fields") ?? 
          "Please complete all fields");
      return;
    }

    final now = DateTime.now();
    if (selectedDatetime!.isAfter(now)) {
      _showError(context.tr("date_in_future") ?? 
          "Date cannot be in the future");
      return;
    }

    // Scenario 3.4: Too old date check (1 year ago)
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (selectedDatetime!.isBefore(oneYearAgo)) {
      _showError(context.tr("date_too_old") ?? 
          "Date cannot be more than 1 year ago");
      return;
    }

    // Build activity data with full DateTime format
    final activityData = <String, dynamic>{
      // Backward compatibility: keep old format for existing records
      'startTimeHour': selectedDatetime!.hour,
      'startTimeMin': selectedDatetime!.minute,
      // New format: full DateTime ISO string
      'feverTimeDate': selectedDatetime!.toIso8601String(),
      'notes': notesController.text,
      'temperature': temperature,
      'temperatureUnit': temperatureUnit,
    };

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
      data: activityData,
      isSynced: false,
      createdBy: widget.firstName,
      babyID: widget.babyID,
    );

    if (widget.isEdit) {
      context.read<ActivityBloc>().add(
        UpdateActivity(activityModel: activityModel),
      );
    } else {
      context.read<ActivityBloc>().add(
        AddActivity(activityModel: activityModel),
      );
      
      // Clear temporary notes after successful save
      SharedPrefsHelper.clearFeverTrackerNotes(widget.babyID);
    }

    // BlocListener will handle closing the bottom sheet after state is emitted
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      notesController.clear();
      temperature = null;
      temperatureUnit = null;
    });

    // Clear temporary notes
    if (!widget.isEdit) {
      SharedPrefsHelper.clearFeverTrackerNotes(widget.babyID);
    }

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
