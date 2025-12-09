import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/navigation_wrapper.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/blocs/medication/medication_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/core/utils/shared_prefs_helper.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/models/medication_model.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/widgets/custom_bottom_sheet_header.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:open_baby_sara/widgets/medication_list_and_add_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomMedicalTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  final bool isEdit;
  final ActivityModel? existingActivity;

  const CustomMedicalTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.isEdit = false,
    this.existingActivity,
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
    super.initState();
    context.read<MedicationBloc>().add(FetchMedications());
    
    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;
      selectedDatetime = widget.existingActivity!.activityDateTime;
      notesController.text = data['notes'] ?? '';
      if (data['medications'] != null) {
        selectedMedications =
            (data['medications'] as List)
                .map(
                  (e) {
                    final med = MedicationModel(
                      name: e['name'] ?? '',
                      amount: e['amount'] ?? '',
                      unit: e['unit'] ?? 'mg',
                    );
                    // Initialize controller for existing medications
                    med.controller = TextEditingController(text: med.amount);
                    return med;
                  },
                )
                .toList();
      }
    } else {
      // New record mode - load temporarily saved notes
      Future.microtask(() async {
        final savedNotes = await SharedPrefsHelper.getMedicalTrackerNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty) {
          notesController.text = savedNotes;
        }
      });
    }
    
    // Listen to notes changes and save temporarily
    notesController.addListener(_onNotesChanged);
    
    getIt<AnalyticsService>().logScreenView('MedicalActivityTracker');
  }

  void _onNotesChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveMedicalTrackerNotes(widget.babyID, notesController.text);
    }
  }

  @override
  void dispose() {
    // Remove notes listener
    notesController.removeListener(_onNotesChanged);
    // Dispose controllers
    notesController.dispose();
    // Dispose medication controllers
    for (var med in selectedMedications) {
      med.controller?.dispose();
    }
    super.dispose();
  }

  void _showError(String message) {
    showCustomFlushbar(
      context,
      context.tr('warning') ?? 'Warning',
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
        // Clear notes cache on successful save
        if (!widget.isEdit) {
          SharedPrefsHelper.clearMedicalTrackerNotes(widget.babyID);
        }
        
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
                    title: context.tr('medical_tracker'),
                    onBack: () => Navigator.of(context).pop(),
                    onSave: () => onPressedSave(),
                    saveText:
                        widget.isEdit
                            ? context.tr('update')
                            : context.tr('save'),
                    backgroundColor: AppColors.medicalColor,
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
                              key: ValueKey('medical_time_${selectedDatetime?.millisecondsSinceEpoch}'),
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
                            Text(context.tr('medications')),
                            TextButton(
                              onPressed: () {
                                showMedicationDialog(
                                  buildContext: context,
                                  onAdd: (selectedList) {
                                    if (selectedList != null && selectedList.isNotEmpty) {
                                      setState(() {
                                        // Initialize controllers for new medications
                                        for (var med in selectedList) {
                                          if (med.controller == null) {
                                            med.controller = TextEditingController();
                                          }
                                        }
                                        selectedMedications = selectedList;
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

                        if (selectedMedications.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Text(context.tr('your_medication')),
                          Divider(color: Colors.grey.shade300),

                          ...selectedMedications.map((med) {
                            // Ensure controller exists
                            if (med.controller == null) {
                              med.controller = TextEditingController(text: med.amount);
                            }
                            
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
                                          size: 16.sp,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            med.controller?.dispose();
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
                                          hintText: context.tr('amount'),
                                          controller: med.controller,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (val) {
                                            med.amount = val;
                                          },
                                        ),
                                      ),

                                      SizedBox(width: 10.w),

                                      // Unit dropdown
                                      DropdownButton<String>(
                                        value: med.unit.isEmpty ? 'mg' : med.unit,
                                        items:
                                            [
                                                  'drops',
                                                  'mg',
                                                  'mL',
                                                  'tabs',
                                                  'tsp',
                                                  'none',
                                                ]
                                                .map(
                                                  (unit) => DropdownMenuItem(
                                                    value: context.tr(unit),
                                                    child: Text(
                                                      context.tr(unit),
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            med.unit = val ?? 'mg';
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
    // Validation: Check if at least one medication is selected
    if (selectedMedications.isEmpty) {
      _showError(context.tr("please_enter_medication") ?? 
          "Please enter a medication");
      return;
    }

    // Validation: Check if all medications have amount and unit
    final invalidMedications = selectedMedications.where(
      (med) => 
          (med.amount.isEmpty) ||
          (med.unit.isEmpty || med.unit == 'none'),
    ).toList();

    if (invalidMedications.isNotEmpty) {
      _showError(context.tr("please_enter_amount_and_unit") ?? 
          "Please enter amount and unit for all medications");
      return;
    }

    // Validation: Check date
    if (selectedDatetime == null) {
      _showError(context.tr("please_select_time") ?? 
          "Please select a time");
      return;
    }

    final now = DateTime.now();
    if (selectedDatetime!.isAfter(now)) {
      _showError(context.tr("date_in_future") ?? 
          "Date cannot be in the future");
      return;
    }

    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (selectedDatetime!.isBefore(oneYearAgo)) {
      _showError(context.tr("date_too_old") ?? 
          "Date cannot be more than 1 year ago");
      return;
    }

    final activityName = ActivityType.medication.name;

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
        'startTimeHour': selectedDatetime!.hour,
        'startTimeMin': selectedDatetime!.minute,
        'notes': notesController.text.trim(),
        'medications':
            selectedMedications
                .where(
                  (med) =>
                      med.amount.isNotEmpty &&
                      med.unit.isNotEmpty && med.unit != 'none',
                )
                .map(
                  (med) => {
                    'name': med.name,
                    'amount': med.amount,
                    'unit': med.unit,
                  },
                )
                .toList(),
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
    }

    // BlocListener will handle closing the bottom sheet after state is emitted
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      selectedDatetime = DateTime.now();
      notesController.clear();
      // Dispose medication controllers
      for (var med in selectedMedications) {
        med.controller?.dispose();
      }
      selectedMedications.clear();
    });

    // Clear notes cache
    if (!widget.isEdit) {
      SharedPrefsHelper.clearMedicalTrackerNotes(widget.babyID);
    }

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }
}
