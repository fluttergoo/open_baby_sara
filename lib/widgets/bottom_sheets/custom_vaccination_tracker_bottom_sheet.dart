import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/navigation_wrapper.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/blocs/vaccination/vaccination_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/core/utils/shared_prefs_helper.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/widgets/custom_bottom_sheet_header.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:open_baby_sara/widgets/show_dialog_add_vaccination.dart';
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
  DateTime selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  List<String> selectedVaccinations = [];

  @override
  void initState() {
    super.initState();
    
    context.read<VaccinationBloc>().add(FetchVaccination());
    
    if (widget.isEdit && widget.existingActivity != null) {
      final activity = widget.existingActivity!;
      final data = activity.data;
      
      // Backward compatibility: use vaccinationTimeDate if available, otherwise use activityDateTime
      if (data['vaccinationTimeDate'] != null) {
        selectedDatetime = DateTime.parse(data['vaccinationTimeDate']);
      } else {
        selectedDatetime = activity.activityDateTime;
      }
      
      notesController.text = data['notes'] ?? '';
      
      // Handle both old and new format for vaccinations
      if (data['medications'] != null) {
        final medications = data['medications'] as List<dynamic>;
        selectedVaccinations = medications
            .map((e) => e is Map ? e['name'].toString() : e.toString())
            .toList();
      } else if (data['vaccinations'] != null) {
        final vaccinations = data['vaccinations'] as List<dynamic>;
        selectedVaccinations = vaccinations
            .map((e) => e is Map ? e['name'].toString() : e.toString())
            .toList();
      }
    } else {
      // New record mode - load temporarily saved notes
      Future.microtask(() async {
        final savedNotes = await SharedPrefsHelper.getVaccinationTrackerNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty && mounted) {
          setState(() {
            notesController.text = savedNotes;
          });
        }
      });
    }
    
    // Listen to notes changes and save temporarily
    notesController.addListener(_onNotesChanged);
    
    getIt<AnalyticsService>().logScreenView('VaccinationActivityTracker');
  }

  void _onNotesChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveVaccinationTrackerNotes(widget.babyID, notesController.text);
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
      context.tr('warning') ?? 'Warning',
      message,
      Icons.warning_outlined,
      color: Colors.orange,
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
                  title: context.tr('vaccination_tracker'),
                  onBack: () => Navigator.of(context).pop(),
                  onSave: () => onPressedSave(),
                  saveText:
                      widget.isEdit ? context.tr('update') : context.tr('save'),
                  backgroundColor: AppColors.vaccineColor,
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
                      // Time picker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.tr('time')),
                          SizedBox(width: 20.w),
                          CustomDateTimePicker(
                            key: ValueKey('vaccination_time_${selectedDatetime.millisecondsSinceEpoch}'),
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
                      
                      // Vaccinations
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.tr('vaccinations')),
                          TextButton(
                            onPressed: () {
                              showDialogAddAndVaccination(
                                buildContext: context,
                                onAdd: (selectedList) {
                                  if (selectedList != null) {
                                    setState(() {
                                      selectedVaccinations = selectedList;
                                    });
                                  }
                                },
                              );
                            },
                            child: Text(context.tr('add')),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      // Selected vaccinations list
                      if (selectedVaccinations.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          context.tr('your_vaccination') ?? 'Your Vaccinations',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ...selectedVaccinations.map((vaccination) {
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
                                        size: 20.sp,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          selectedVaccinations.remove(vaccination);
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        vaccination,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontSize: 15.sp,
                                        ),
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

                      // Notes
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
                      
                      // Footer
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
    // Validation: At least one vaccination must be selected (Scenario 3.1)
    if (selectedVaccinations.isEmpty) {
      _showError(context.tr('please_enter_a_vaccination') ?? 
          "Please enter a vaccination");
      return;
    }

    // Validation: Date cannot be in the future (Scenario 3.2)
    final now = DateTime.now();
    if (selectedDatetime.isAfter(now)) {
      _showError(context.tr("date_in_future") ?? 
          "Date cannot be in the future");
      return;
    }

    // Validation: Date cannot be more than 1 year ago (Scenario 3.3)
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (selectedDatetime.isBefore(oneYearAgo)) {
      _showError(context.tr("date_too_old") ?? 
          "Date cannot be more than 1 year ago");
      return;
    }

    final activityModel = ActivityModel(
      activityID:
          widget.isEdit
              ? widget.existingActivity!.activityID
              : const Uuid().v4(),
      activityType: ActivityType.vaccination.name,
      createdAt:
          widget.isEdit ? widget.existingActivity!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime,
      data: {
        // Backward compatibility: keep hour/minute for old format
        'startTimeHour': selectedDatetime.hour,
        'startTimeMin': selectedDatetime.minute,
        // New format: full DateTime ISO string
        'vaccinationTimeDate': selectedDatetime.toIso8601String(),
        'notes': notesController.text.trim(),
        'medications': selectedVaccinations.map((e) => {'name': e}).toList(),
      },
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
      
      // Clear temporarily saved notes after successful save
      SharedPrefsHelper.clearVaccinationTrackerNotes(widget.babyID);
    }
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      notesController.clear();
      selectedVaccinations.clear();
    });

    // Clear temporarily saved notes
    if (!widget.isEdit) {
      SharedPrefsHelper.clearVaccinationTrackerNotes(widget.babyID);
    }

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
