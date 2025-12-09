import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/widgets/custom_bottom_sheet_header.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/core/utils/shared_prefs_helper.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';

class CustomDoctorVisitTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomDoctorVisitTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
  });

  @override
  State<CustomDoctorVisitTrackerBottomSheet> createState() =>
      _CustomDoctorVisitTrackerBottomSheetState();
}

class _CustomDoctorVisitTrackerBottomSheetState
    extends State<CustomDoctorVisitTrackerBottomSheet> {
  DateTime selectedDatetime = DateTime.now();
  TextEditingController notesController = TextEditingController();
  TextEditingController diagnosisController = TextEditingController();

  final List<String> dropdownItemReason = [
    'Check-up',
    'Vaccination',
    'Illness / Sick Visit',
    'Injury',
    'Developmental Concern',
    'Other',
  ];

  final List<String> dropdownItemReaction = [
    'Calm',
    'Cried briefly',
    'Cried a lot',
    'Sleepy',
    'Fussy',
    'Feverish',
    'Normal / Active',
    'Other',
  ];

  late String selectedReason;
  late String selectedReaction;

  @override
  void initState() {
    super.initState();
    selectedReason = dropdownItemReason.first;
    selectedReaction = dropdownItemReaction.first;
    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;
      // Backward compatibility: use visitTimeDate if available, otherwise use activityDateTime
      if (data['visitTimeDate'] != null) {
        selectedDatetime = DateTime.parse(data['visitTimeDate']);
      } else {
        selectedDatetime = widget.existingActivity!.activityDateTime;
      }
      selectedReason = data['reason'] ?? dropdownItemReason.first;
      selectedReaction = data['reaction'] ?? dropdownItemReaction.first;
      diagnosisController.text = data['diagnosis'] ?? '';
      notesController.text = data['notes'] ?? '';
    } else {
      // New record mode - load temporarily saved notes and diagnosis
      Future.microtask(() async {
        final savedNotes = await SharedPrefsHelper.getDoctorVisitNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty) {
          notesController.text = savedNotes;
        }
        
        final savedDiagnosis = await SharedPrefsHelper.getDoctorVisitDiagnosis(widget.babyID);
        if (savedDiagnosis != null && savedDiagnosis.isNotEmpty) {
          diagnosisController.text = savedDiagnosis;
        }
      });
    }
    
    // Listen to notes and diagnosis changes and save temporarily
    notesController.addListener(_onNotesChanged);
    diagnosisController.addListener(_onDiagnosisChanged);
    
    getIt<AnalyticsService>().logScreenView('DoctorVisitActivityTracker');
  }

  void _onNotesChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveDoctorVisitNotes(widget.babyID, notesController.text);
    }
  }

  void _onDiagnosisChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveDoctorVisitDiagnosis(widget.babyID, diagnosisController.text);
    }
  }

  @override
  void dispose() {
    // Remove listeners
    notesController.removeListener(_onNotesChanged);
    diagnosisController.removeListener(_onDiagnosisChanged);
    // Dispose controllers
    notesController.dispose();
    diagnosisController.dispose();
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
                  title: context.tr('doctor_visit'),
                  onBack: () => Navigator.of(context).pop(),
                  onSave: () => onPressedSave(),
                  saveText:
                      widget.isEdit ? context.tr('update') : context.tr('save'),
                  backgroundColor: AppColors.doctorVisitColor,
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
                          Text(context.tr('visit_time')),
                          SizedBox(width: 20.w),
                          CustomDateTimePicker(
                            key: ValueKey('visit_time_${selectedDatetime.millisecondsSinceEpoch}'),
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

                      // Baby Reaction
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(context.tr('baby_reaction')),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<String>(
                              value: selectedReaction,
                              items:
                                  dropdownItemReaction
                                      .map(
                                        (reaction) => DropdownMenuItem<String>(
                                          value: reaction,
                                          child: Text(
                                            context.tr(reaction),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedReaction = val;
                                  });
                                }
                              },
                              isExpanded: true,
                              underline: SizedBox(),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      // Visit Reason
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(context.tr('visit_reason')),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<String>(
                              value: selectedReason,
                              items:
                                  dropdownItemReason
                                      .map(
                                        (reason) => DropdownMenuItem<String>(
                                          value: reason,
                                          child: Text(
                                            context.tr(reason),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedReason = val;
                                  });
                                }
                              },
                              isExpanded: true,
                              underline: SizedBox(),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      // Diagnosis
                      SizedBox(height: 5.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${context.tr('diagnosis')}:',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.copyWith(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      CustomTextFormField(
                        hintText: '',
                        isNotes: true,
                        controller: diagnosisController,
                      ),
                      Divider(color: Colors.grey.shade300),

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
    // Validation: Reason and reaction must be selected
    if (selectedReason.isEmpty || selectedReaction.isEmpty) {
      _showError(context.tr('please_fill_reason') ?? 
          "Please select reason and reaction");
      return;
    }

    // Validation: Date cannot be in the future
    final now = DateTime.now();
    if (selectedDatetime.isAfter(now)) {
      _showError(context.tr("date_in_future") ?? 
          "Date cannot be in the future");
      return;
    }

    // Validation: Date cannot be more than 1 year ago
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (selectedDatetime.isBefore(oneYearAgo)) {
      _showError(context.tr("date_too_old") ?? 
          "Date cannot be more than 1 year ago");
      return;
    }

    final activityName = ActivityType.doctorVisit.name;

    final activity = ActivityModel(
      activityID:
          widget.isEdit
              ? widget.existingActivity!.activityID
              : const Uuid().v4(),
      activityType: activityName,
      createdAt:
          widget.isEdit ? widget.existingActivity!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      activityDateTime: selectedDatetime,
      data: {
        // Backward compatibility: keep hour/minute for old format
        'startTimeHour': selectedDatetime.hour,
        'startTimeMin': selectedDatetime.minute,
        // New format: full DateTime ISO string
        'visitTimeDate': selectedDatetime.toIso8601String(),
        'reason': selectedReason,
        'reaction': selectedReaction,
        'diagnosis': diagnosisController.text.trim(),
        'notes': notesController.text.trim(),
      },
      isSynced: false,
      babyID: widget.babyID,
      createdBy: widget.firstName,
    );

    if (widget.isEdit) {
      context.read<ActivityBloc>().add(UpdateActivity(activityModel: activity));
    } else {
      context.read<ActivityBloc>().add(AddActivity(activityModel: activity));
      
      // Clear temporarily saved notes and diagnosis after successful save
      SharedPrefsHelper.clearDoctorVisitNotes(widget.babyID);
      SharedPrefsHelper.clearDoctorVisitDiagnosis(widget.babyID);
    }
  }

  void _showError(String message) {
    showCustomFlushbar(context, context.tr("warning"), message, Icons.warning);
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      selectedReason = dropdownItemReason.first;
      selectedReaction = dropdownItemReaction.first;
      diagnosisController.clear();
      notesController.clear();
    });

    // Clear temporarily saved notes and diagnosis
    if (!widget.isEdit) {
      SharedPrefsHelper.clearDoctorVisitNotes(widget.babyID);
      SharedPrefsHelper.clearDoctorVisitDiagnosis(widget.babyID);
    }

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
