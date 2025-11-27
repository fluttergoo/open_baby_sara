import 'package:another_flushbar/flushbar.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_baby_sara/app/routes/navigation_wrapper.dart';
import 'package:open_baby_sara/blocs/activity/activity_bloc.dart';
import 'package:open_baby_sara/blocs/all_timer/sleep_timer/sleep_timer_bloc.dart';
import 'package:open_baby_sara/core/app_colors.dart';
import 'package:open_baby_sara/core/utils/shared_prefs_helper.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';
import 'package:open_baby_sara/widgets/all_timers/sleep_timer_circle.dart';
import 'package:open_baby_sara/widgets/custom_bottom_sheet_header.dart';
import 'package:open_baby_sara/widgets/custom_date_time_picker.dart';
import 'package:open_baby_sara/widgets/custom_show_flush_bar.dart';
import 'package:open_baby_sara/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CustomSleepTrackerBottomSheet extends StatefulWidget {
  final String babyID;
  final String firstName;
  Duration? duration;
  final ActivityModel? existingActivity;
  final bool isEdit;

  CustomSleepTrackerBottomSheet({
    super.key,
    required this.babyID,
    required this.firstName,
    this.existingActivity,
    this.isEdit = false,
  });

  @override
  State<CustomSleepTrackerBottomSheet> createState() =>
      _CustomSleepTrackerBottomSheetState();
}

class _CustomSleepTrackerBottomSheetState
    extends State<CustomSleepTrackerBottomSheet> {
  DateTime? start;
  DateTime? endTime;
  String? totalSleepTime;
  DateTime? selectedDatetime = DateTime.now();

  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.existingActivity != null) {
      final data = widget.existingActivity!.data;

      selectedDatetime = widget.existingActivity!.activityDateTime;
      notesController.text = data['notes'] ?? '';

      // Backward compatibility: use startTimeDate and endTimeDate if available, otherwise get date from activityDateTime
      if (data['startTimeDate'] != null) {
        start = DateTime.parse(data['startTimeDate']);
      } else {
        // Old data format - only hour/minute available, get date from activityDateTime
        start = DateTime(
          selectedDatetime!.year,
          selectedDatetime!.month,
          selectedDatetime!.day,
          data['startTimeHour'] ?? 0,
          data['startTimeMin'] ?? 0,
        );
      }

      if (data['endTimeDate'] != null) {
        endTime = DateTime.parse(data['endTimeDate']);
      } else {
        // Old data format - only hour/minute available, get date from activityDateTime
        endTime = DateTime(
          selectedDatetime!.year,
          selectedDatetime!.month,
          selectedDatetime!.day,
          data['endTimeHour'] ?? 0,
          data['endTimeMin'] ?? 0,
        );
      }

      final totalMs = data['totalTime'];
      if (totalMs != null) {
        widget.duration = Duration(milliseconds: totalMs);
        totalSleepTime = formatDuration(widget.duration!);
      }

      Future.microtask(() {
        final sleepBloc = context.read<SleepTimerBloc>();
        sleepBloc.add(
          SetDurationTimer(
            duration: widget.duration ?? Duration.zero,
            activityType: 'sleepTimer',
          ),
        );
        sleepBloc.add(StopTimer(activityType: 'sleepTimer'));
      });
    } else {
      // New record mode - check timer state
      // If timer is running, get start time from timer
      Future.microtask(() async {
        final sleepBloc = context.read<SleepTimerBloc>();
        final currentState = sleepBloc.state;
        
        // Load temporarily saved notes
        final savedNotes = await SharedPrefsHelper.getSleepTrackerNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty) {
          notesController.text = savedNotes;
        }
        
        if (currentState is TimerRunning && currentState.activityType == 'sleepTimer') {
          // If timer is running, get start time from timer
          if (currentState.startTime != null) {
            setState(() {
              start = currentState.startTime;
              selectedDatetime = currentState.startTime;
              widget.duration = currentState.duration;
              totalSleepTime = formatDuration(currentState.duration);
              // End time is null - no end time while timer is running
              endTime = null;
            });
          }
        } else if (currentState is TimerStopped && currentState.activityType == 'sleepTimer') {
          // If timer is stopped, get values from state
          if (currentState.startTime != null) {
            setState(() {
              start = currentState.startTime;
              selectedDatetime = currentState.startTime;
            });
          }
          if (currentState.endTime != null) {
            setState(() {
              endTime = currentState.endTime;
            });
          }
          if (currentState.duration != Duration.zero) {
            setState(() {
              widget.duration = currentState.duration;
              totalSleepTime = formatDuration(currentState.duration);
            });
          }
        }
      });
    }

    // Listen to notes changes and save
    notesController.addListener(_onNotesChanged);

    getIt<AnalyticsService>().logScreenView('SleepActivityTracker');
  }

  void _onNotesChanged() {
    if (!widget.isEdit) {
      // Only save temporarily in new record mode
      SharedPrefsHelper.saveSleepTrackerNotes(widget.babyID, notesController.text);
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
      listener: (context, state) {
        if (state is ActivityAdded) {
          showCustomFlushbar(
            context,
            context.tr('success'),
            context.tr('activity_was_added'),
            Icons.add_task_outlined,
            color: Colors.green,
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                CustomSheetHeader(
                  title: context.tr('sleep_tracker'),
                  onBack: () {
                    // Don't stop timer - timer should work like a real timer
                    // User can navigate to another page, timer continues running
                    Navigator.of(context).pop();
                  },
                  onSave: () => onPressedSave(),
                  saveText:
                      widget.isEdit ? context.tr('update') : context.tr('save'),
                  backgroundColor: AppColors.sleepColor,
                ),

                // Body (you can customize this)
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(
                      left: 16.r,
                      right: 16.r,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      top: 16,
                    ),
                    children: [
                      BlocBuilder<SleepTimerBloc, SleepTimerState>(
                        builder: (context, state) {
                          // Manage state changes - only update in relevant states
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            
                            if (state is TimerStopped && state.activityType == 'sleepTimer') {
                              // Get values from state when timer is stopped
                              // Only update when actually different (prevent unnecessary rebuilds)
                              bool needsUpdate = false;
                              
                              // End time: if null in state and exists locally, set to null
                              // if exists in state and different from local, update
                              if (state.endTime == null) {
                                if (endTime != null) {
                                  endTime = null;
                                  needsUpdate = true;
                                }
                              } else {
                                if (endTime != state.endTime) {
                                  endTime = state.endTime;
                                  needsUpdate = true;
                                }
                              }
                              
                              // Start time: update from state, but only if different
                              // Since SetEndTimeTimer event now also sends start time,
                              // start time in bloc state will be correct
                              if (state.startTime == null) {
                                if (start != null) {
                                  start = null;
                                  needsUpdate = true;
                                }
                              } else {
                                // Update if state start time differs from local
                                // But only if state start time is newer or different
                                if (start != state.startTime) {
                                  start = state.startTime;
                                  needsUpdate = true;
                                }
                              }
                              
                              // Duration: update from state
                              if (widget.duration != state.duration) {
                                widget.duration = state.duration;
                                totalSleepTime = state.duration != Duration.zero 
                                    ? formatDuration(state.duration) 
                                    : null;
                                needsUpdate = true;
                              }
                              
                              if (needsUpdate) {
                                setState(() {});
                              }
                            } else if (state is TimerRunning && state.activityType == 'sleepTimer') {
                              // Only update start time while timer is running
                              // End time should be null because timer hasn't finished yet
                              bool needsUpdate = false;
                              if (state.startTime != null && start != state.startTime) {
                                start = state.startTime;
                                selectedDatetime = state.startTime;
                                needsUpdate = true;
                              }
                              if (widget.duration != state.duration) {
                                widget.duration = state.duration;
                                totalSleepTime = formatDuration(state.duration);
                                needsUpdate = true;
                              }
                              if (endTime != null) {
                                endTime = null;
                                needsUpdate = true;
                              }
                              if (needsUpdate) {
                                setState(() {});
                              }
                            } else if (state is TimerReset) {
                              // Clear everything in reset state
                              bool needsUpdate = false;
                              if (start != null) {
                                start = null;
                                needsUpdate = true;
                              }
                              if (endTime != null) {
                                endTime = null;
                                needsUpdate = true;
                              }
                              if (totalSleepTime != null) {
                                totalSleepTime = null;
                                needsUpdate = true;
                              }
                              if (widget.duration != null) {
                                widget.duration = null;
                                needsUpdate = true;
                              }
                              if (needsUpdate) {
                                setState(() {});
                              }
                            }
                          });

                          // Calculate total sleep time if both start and end time exist and timer is stopped
                          // Don't do this calculation while timer is running because timer manages its own duration
                          if (state is TimerStopped && start != null && endTime != null) {
                            final calculatedDuration = endTime!.difference(start!);
                            // Update if duration hasn't been set yet or is different
                            if (widget.duration == null || 
                                (widget.duration!.inMilliseconds - calculatedDuration.inMilliseconds).abs() > 1000) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && start != null && endTime != null) {
                                  _calculateAndUpdateTotalSleepTime(start!, endTime!);
                                }
                              });
                            }
                          }

                          return Column(
                            children: [
                              /// Text('Start Time - End Time Picker Placeholder'),
                              SizedBox(height: 16),
                              SleepTimerCircle(activityType: 'sleepTimer'),
                              SizedBox(height: 32.h),
                              Divider(color: Colors.grey.shade300),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(context.tr("start_time")),
                                  CustomDateTimePicker(
                                    key: ValueKey('start_time_${start?.millisecondsSinceEpoch}'),
                                    initialText: 'initialText',
                                    initialDateTime: start,
                                    maxDate: DateTime.now(), // Prevent future dates
                                    minDate: DateTime.now().subtract(const Duration(days: 365)), // 1 year ago limit
                                    onDateTimeSelected: (selected) {
                                      // If timer is running, switch to manual mode (stop timer)
                                      final currentState = context.read<SleepTimerBloc>().state;
                                      final isTimerRunning = currentState is TimerRunning && 
                                                             currentState.activityType == 'sleepTimer';
                                      
                                      // Future date check
                                      final now = DateTime.now();
                                      if (selected.isAfter(now)) {
                                        _showError(context.tr("date_in_future") ?? 
                                            "Start time cannot be in the future");
                                        return;
                                      }
                                      
                                      // Too old date check (1 year ago)
                                      final oneYearAgo = now.subtract(const Duration(days: 365));
                                      if (selected.isBefore(oneYearAgo)) {
                                        _showError(context.tr("date_too_old") ?? 
                                            "Date cannot be more than 1 year ago");
                                        return;
                                      }
                                      
                                      // Check if end time exists
                                      if (endTime != null) {
                                        // Start time cannot be after end time
                                        if (selected.isAfter(endTime!)) {
                                          _showError(context.tr("end_time_before_start"));
                                          return;
                                        }
                                        // Start and end time cannot be the same
                                        if (selected.isAtSameMomentAs(endTime!)) {
                                          _showError(context.tr("start_end_time_same") ?? 
                                              "Start and end time cannot be the same");
                                          return;
                                        }
                                        // Check 24 hour limit
                                        if (!_validate24HourLimit(selected, endTime, null)) {
                                          return;
                                        }
                                        // Calculate duration (only for local state, don't notify bloc)
                                        // Bloc will calculate duration with SetStartTimeTimer event
                                        if (!isTimerRunning) {
                                          final calculatedDuration = endTime!.difference(selected);
                                          widget.duration = calculatedDuration;
                                          totalSleepTime = formatDuration(calculatedDuration);
                                        }
                                      }
                                      
                                      // Update local state
                                      setState(() {
                                        start = selected;
                                        selectedDatetime = selected;
                                        // Don't change end time when start time is selected
                                        // End time should be selected manually by user
                                      });
                                      
                                      // SetStartTimeTimer event will stop timer (switch to manual mode)
                                      // Send selected value directly, not start (setState may be async)
                                      context.read<SleepTimerBloc>().add(
                                        SetStartTimeTimer(
                                          startTime: selected,
                                          activityType: 'sleepTimer',
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey.shade300),
                              BlocBuilder<SleepTimerBloc, SleepTimerState>(
                                builder: (context, timerState) {
                                  final isTimerRunning = timerState is TimerRunning && 
                                                         timerState.activityType == 'sleepTimer';
                                  
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(context.tr("end_time")),
                                      CustomDateTimePicker(
                                        // Add start time to key so picker re-renders when start time changes
                                        // This ensures minDate is displayed correctly
                                        key: ValueKey('end_time_${endTime?.millisecondsSinceEpoch}_${start?.millisecondsSinceEpoch}_${isTimerRunning}'),
                                        initialText: 'initialText',
                                        initialDateTime: endTime,
                                        enabled: !isTimerRunning, // Disabled while timer is running
                                        maxDate: DateTime.now(), // Prevent future dates
                                        // Scenario 2.3: For sleep records crossing midnight
                                        // End time cannot be before start time
                                        // If start time exists, use start time as minDate
                                        // Otherwise use 1 year ago limit
                                        minDate: start != null 
                                            ? start! // If start time exists, end time must be at least start time
                                            : DateTime.now().subtract(const Duration(days: 365)), // 1 year ago limit
                                        onDateTimeSelected: (selected) {
                                          // If timer is running, switch to manual mode (stop timer)
                                          final currentState = context.read<SleepTimerBloc>().state;
                                          final isRunning = currentState is TimerRunning && 
                                                             currentState.activityType == 'sleepTimer';
                                          
                                          if (isRunning) {
                                            // Cannot select end time while timer is running
                                            return;
                                          }
                                          
                                          // Future date check
                                          final now = DateTime.now();
                                          if (selected.isAfter(now)) {
                                            _showError(context.tr("date_in_future") ?? 
                                                "End time cannot be in the future");
                                            return;
                                          }
                                          
                                          // Too old date check (1 year ago)
                                          // But if start time exists and start time is not older than 1 year,
                                          // it's enough that end time is not older than 1 year
                                          // If start time exists, end time must be after start time (checked above)
                                          final oneYearAgo = now.subtract(const Duration(days: 365));
                                          if (selected.isBefore(oneYearAgo)) {
                                            _showError(context.tr("date_too_old") ?? 
                                                "Date cannot be more than 1 year ago");
                                            return;
                                          }
                                          
                                          if (start != null) {
                                            // Senaryo 2.3, 7.3: Gece yarısını geçen uyku kayıtları için
                                            // End time start time'dan önce olamaz (tam tarihli DateTime kontrolü)
                                            // Tam tarihli DateTime'lar kullanıldığı için isBefore() doğru çalışır
                                            // Örnek: Nov 22, 22:06 < Nov 23, 14:06 = true (doğru)
                                            if (selected.isBefore(start!)) {
                                              _showError(context.tr("end_time_before_start"));
                                              return;
                                            }
                                            // Start ve end time aynı olamaz
                                            if (selected.isAtSameMomentAs(start!)) {
                                              _showError(context.tr("start_end_time_same") ?? 
                                                  "Start and end time cannot be the same");
                                              return;
                                            }
                                            // 24 saat limitini kontrol et (tam tarihli DateTime'lar için)
                                            if (!_validate24HourLimit(start, selected, null)) {
                                              return;
                                            }
                                            // Duration'ı hesapla (sadece local state için, bloc'a bildirme)
                                            // Bloc SetEndTimeTimer event'i ile duration'ı zaten hesaplayacak
                                            // Tam tarihli DateTime'lar kullanıldığı için difference() otomatik olarak
                                            // gece yarısını geçen durumları doğru hesaplar
                                            final calculatedDuration = selected.difference(start!);
                                            widget.duration = calculatedDuration;
                                            totalSleepTime = formatDuration(calculatedDuration);
                                          }
                                          
                                          setState(() {
                                            endTime = selected;
                                            selectedDatetime = selected;
                                          });
                                          
                                          // SetEndTimeTimer event'i timer'ı durduracak (manuel moda geçiş)
                                          // Bloc bu event ile duration'ı otomatik hesaplayacak
                                          // Start time'ı da gönder ki bloc state'i doğru olsun
                                          context.read<SleepTimerBloc>().add(
                                            SetEndTimeTimer(
                                              activityType: 'sleepTimer',
                                              endTime: selected, // endTime! yerine selected kullan
                                              startTime: start, // Mevcut start time'ı gönder
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Divider(color: Colors.grey.shade300),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(context.tr("total_sleep_time")),
                                  TextButton(
                                    onPressed: () {
                                      // _onPressedEndTimeShowPicker(context);
                                      _onPressedShowDurationSet(context);
                                    },
                                    child:
                                        totalSleepTime != null
                                            ? Text(totalSleepTime!)
                                            : Text('00:00'),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey.shade300),
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
                              SizedBox(height: 5.h),

                              Divider(color: Colors.grey.shade300),

                              SizedBox(height: 20.h),

                              Text(
                                '${context.tr("created_by")} ${widget.firstName}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall!.copyWith(
                                  fontSize: 12.sp,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(height: 10.h),

                              TextButton(
                                onPressed: () {
                                  _onPressedDelete(context);
                                },
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
                          );
                        },
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


  void _showError(String message) {
    showCustomFlushbar(context, context.tr("warning"), message, Icons.warning);
  }

  /// 24 saat limitini kontrol eder
  /// Returns: true if valid, false if exceeds 24 hours
  /// Senaryo 4.2, 7.2, 7.5: 24 saat limiti kontrolü (tam 24 saat = 86400 saniye)
  bool _validate24HourLimit(DateTime? start, DateTime? end, Duration? duration) {
    // Eğer start ve end time varsa, aralarındaki farkı kontrol et
    // Tam tarihli DateTime'lar kullanıldığı için difference() otomatik olarak tarihleri hesaba katar
    if (start != null && end != null) {
      final difference = end.difference(start);
      
      // Negatif fark kontrolü (end start'tan önce olamaz)
      // Senaryo 4.1: End time start time'dan önce olamaz
      if (difference.isNegative) {
        _showError(context.tr("end_time_before_start"));
        return false;
      }
      
      // Senaryo 4.5: Start ve end time aynı olamaz (duration 0 olamaz)
      if (difference.inSeconds == 0) {
        _showError(context.tr("start_end_time_same") ?? 
            "Start and end time cannot be the same");
        return false;
      }
      
      // 24 saat limiti kontrolü (24 saatten fazla olamaz)
      // Senaryo 7.2: Tam 24 saat = 86400 saniye kontrolü
      // Senaryo 7.5: 23 saat 59 dakika kabul edilmeli
      // Tam tarihli DateTime'lar kullanıldığı için difference() otomatik olarak tarihleri hesaba katar
      // 24 saat = 86400 saniye (tam 24 saat dahil edilmez, sadece 24 saatten az olmalı)
      if (difference.inSeconds >= 86400) {
        _showError(context.tr("sleep_duration_exceeds_one_day") ?? 
            "Sleep duration cannot exceed 24 hours");
        return false;
      }
    }
    
    // Eğer duration varsa, 24 saati geçmemeli
    // Senaryo 4.2: 24 saati aşan uyku kaydı engellenmeli
    // 24 saat = 86400 saniye (tam 24 saat dahil edilmez)
    if (duration != null) {
      if (duration.inSeconds >= 86400) {
        _showError(context.tr("sleep_duration_exceeds_one_day") ?? 
            "Sleep duration cannot exceed 24 hours");
        return false;
      }
      
      // Senaryo 4.5: Duration 0 olamaz
      if (duration.inSeconds == 0) {
        _showError(context.tr("start_end_time_same") ?? 
            "Sleep duration cannot be zero");
        return false;
      }
    }
    
    return true;
  }

  /// Senaryo 2.3, 7.3: Gece yarısını geçen uyku kayıtları için duration hesaplama
  /// Tam tarihli DateTime'lar kullanıldığı için difference() otomatik olarak tarihleri hesaba katar
  void _calculateAndUpdateTotalSleepTime(DateTime startTime, DateTime endTime) {
    // Timer çalışıyorsa bu hesaplamayı yapma - timer kendi duration'ını yönetiyor
    final currentState = context.read<SleepTimerBloc>().state;
    if (currentState is TimerRunning) {
      return;
    }
    
    // Tam tarihli DateTime'lar kullanıldığı için difference() otomatik olarak tarihleri hesaba katar
    // Gece yarısını geçen durumlar için (örn: 22:00 - 07:00) difference() doğru hesaplar
    final difference = endTime.difference(startTime);
    
    // Negatif fark kontrolü (gece yarısını geçen durumlar için normal olabilir ama burada kontrol edelim)
    if (difference.isNegative) {
      // Bu durumda end time start time'dan önce, bu bir hata
      _showError(context.tr("end_time_before_start"));
      return;
    }
    
    // 24 saat limitini kontrol et
    if (!_validate24HourLimit(startTime, endTime, difference)) {
      return;
    }
    
    widget.duration = difference;
    totalSleepTime = formatDuration(difference);
    
    // Bloc'a da bildir - sadece timer durmuşsa
    context.read<SleepTimerBloc>().add(
      SetDurationTimer(
        duration: difference,
        activityType: 'sleepTimer',
      ),
    );
    
    setState(() {});
  }

  void _onPressedDelete(BuildContext context) {
    setState(() {
      start = null;
      endTime = null;
      totalSleepTime = null;
      notesController.clear();
      widget.duration = null;
      selectedDatetime = DateTime.now();
    });

    // Geçici notes'u da temizle
    if (!widget.isEdit) {
      SharedPrefsHelper.clearSleepTrackerNotes(widget.babyID);
    }

    context.read<SleepTimerBloc>().add(ResetTimer(activityType: 'sleepTimer'));

    showCustomFlushbar(
      context,
      context.tr("reset"),
      context.tr("fields_reset"),
      Icons.refresh,
    );
  }

  void onPressedSave() async {
    final activityName = ActivityType.sleep.name;
    final sleepBloc = context.read<SleepTimerBloc>();
    final currentState = sleepBloc.state;
    final isTimerRunning = currentState is TimerRunning && 
                           currentState.activityType == 'sleepTimer';

    // Eğer timer çalışıyorsa, timer'ı durdur ve end time'ı şu anki zaman olarak ayarla
    if (isTimerRunning) {
      sleepBloc.add(StopTimer(activityType: 'sleepTimer'));
      
      // Timer durduktan sonra state'i bekle
      await Future.delayed(Duration(milliseconds: 100));
      
      // State'ten güncel değerleri al
      final stoppedState = sleepBloc.state;
      if (stoppedState is TimerStopped && stoppedState.activityType == 'sleepTimer') {
        if (stoppedState.startTime != null) {
          start = stoppedState.startTime;
        }
        if (stoppedState.endTime != null) {
          endTime = stoppedState.endTime;
        }
        if (stoppedState.duration != Duration.zero) {
          widget.duration = stoppedState.duration;
          totalSleepTime = formatDuration(stoppedState.duration);
        }
      }
    }

    // Senaryo 4.4: Validation kontrolleri - Eksik alanlar
    if (start == null) {
      _showError(context.tr("please_complete_all_fields"));
      return;
    }

    if (endTime == null) {
      _showError(context.tr("please_complete_all_fields"));
      return;
    }

    if (widget.duration == null) {
      _showError(context.tr("please_complete_all_fields"));
      return;
    }

    // Senaryo 4.1: Start time end time'dan sonra olamaz (tarihler dahil)
    if (start!.isAfter(endTime!)) {
      _showError(context.tr("end_time_before_start"));
      return;
    }

    // Senaryo 4.5: Start ve end time aynı olamaz
    if (start!.isAtSameMomentAs(endTime!)) {
      _showError(context.tr("start_end_time_same") ?? 
          "Start and end time cannot be the same");
      return;
    }

    // Senaryo 4.3: Gelecekteki tarih kontrolü - start ve end time gelecekte olamaz
    final now = DateTime.now();
    if (start!.isAfter(now) || endTime!.isAfter(now)) {
      _showError(context.tr("date_in_future") ?? 
          "Start and end time cannot be in the future");
      return;
    }

    // Senaryo 7.1: Çok eski tarih kontrolü (1 yıl öncesi)
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (start!.isBefore(oneYearAgo) || endTime!.isBefore(oneYearAgo)) {
      _showError(context.tr("date_too_old") ?? 
          "Date cannot be more than 1 year ago");
      return;
    }

    // Senaryo 4.2, 7.2, 7.5: 24 saat limitini kontrol et (tarihler dahil)
    if (!_validate24HourLimit(start, endTime, widget.duration)) {
      return;
    }

    // Senaryo 4.6: Duration ile start-end aralığı uyumlu olmalı (1 dakika tolerans)
    // Senaryo 2.3, 7.3: Gece yarısını geçen durumlar için tam tarihli DateTime'lar kullanıldığı için 
    // difference() otomatik olarak tarihleri hesaba katar
    final calculatedDuration = endTime!.difference(start!);
    if (calculatedDuration.isNegative) {
      _showError(context.tr("end_time_before_start"));
      return;
    }
    
    // Duration ile calculated duration arasında 1 dakika tolerans (60000 ms)
    // Bu tolerans, kullanıcının manuel olarak seçtiği değerler ile hesaplanan değerler arasındaki 
    // küçük farkları kabul etmek için
    if ((widget.duration!.inMilliseconds - calculatedDuration.inMilliseconds).abs() > 60000) {
      _showError(context.tr("sleep_duration_mismatch") ?? 
          "Duration does not match the time difference between start and end time");
      return;
    }

    try {
      // Yeni format: Tam tarihli DateTime'ları ISO string olarak kaydet
      // Eski format ile uyumluluk için saat/dakika bilgilerini de kaydet
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
          // Yeni format: Tam tarihli DateTime'lar
          'startTimeDate': start!.toIso8601String(),
          'endTimeDate': endTime!.toIso8601String(),
          // Eski format ile uyumluluk: Saat/dakika bilgileri
          'startTimeHour': start?.hour,
          'startTimeMin': start?.minute,
          'endTimeHour': endTime?.hour,
          'endTimeMin': endTime?.minute,
          'totalTime': widget.duration?.inMilliseconds,
          'notes': notesController.text,
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

      // Kayıt başarılı olduğunda tüm geçici verileri temizle
      if (!widget.isEdit) {
        await SharedPrefsHelper.clearSleepTrackerNotes(widget.babyID);
      }

      // Timer state'ini resetle
      context.read<SleepTimerBloc>().add(
        ResetTimer(activityType: 'sleepTimer'),
      );

      // Local state'i temizle
      setState(() {
        start = null;
        endTime = null;
        totalSleepTime = null;
        notesController.clear();
        widget.duration = null;
        selectedDatetime = DateTime.now();
      });

      // Sayfayı kapat ve ana sayfaya dön
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => NavigationWrapper()));
    } catch (e, stack) {
      print(stack);
    }
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Senaryo 5.2: Duration picker'dan süre seçildiğinde start/end time otomatik hesaplama
  void _onPressedShowDurationSet(BuildContext context) async {
    final setDuration = await showDurationPicker(
      context: context,
      initialTime: widget.duration ?? Duration(hours: 0, minutes: 0),
      baseUnit: BaseUnit.minute, // minute / hour / second
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
    if (setDuration != null) {
      // Senaryo 4.2: 24 saat limitini kontrol et
      if (!_validate24HourLimit(start, endTime, setDuration)) {
        return;
      }
      
      // Senaryo 5.2: Duration seçildiğinde start ve end time'ı otomatik hesapla
      // Eğer end time varsa, start time'ı end time'dan duration çıkararak hesapla
      // Eğer start time varsa, end time'ı start time'a duration ekleyerek hesapla
      // Eğer ikisi de varsa, end time'ı start time'a duration ekleyerek güncelle
      // Eğer ikisi de yoksa, end time'ı şu anki zaman olarak ayarla ve start time'ı hesapla
      DateTime? newStart = start;
      DateTime? newEnd = endTime;
      
      if (newEnd != null) {
        // End time varsa, start time'ı hesapla
        newStart = newEnd.subtract(setDuration);
        
        // Gelecekteki tarih kontrolü
        final now = DateTime.now();
        if (newStart.isAfter(now)) {
          _showError(context.tr("date_in_future") ?? 
              "Calculated start time cannot be in the future");
          return;
        }
        
        // Çok eski tarih kontrolü
        final oneYearAgo = now.subtract(const Duration(days: 365));
        if (newStart.isBefore(oneYearAgo)) {
          _showError(context.tr("date_too_old") ?? 
              "Calculated start time cannot be more than 1 year ago");
          return;
        }
      } else if (newStart != null) {
        // Start time varsa, end time'ı hesapla
        newEnd = newStart.add(setDuration);
        
        // Gelecekteki tarih kontrolü
        final now = DateTime.now();
        if (newEnd.isAfter(now)) {
          _showError(context.tr("date_in_future") ?? 
              "Calculated end time cannot be in the future");
          return;
        }
      } else {
        // İkisi de yoksa, end time'ı şu anki zaman olarak ayarla ve start time'ı hesapla
        final now = DateTime.now();
        newEnd = now;
        newStart = now.subtract(setDuration);
        
        // Çok eski tarih kontrolü
        final oneYearAgo = now.subtract(const Duration(days: 365));
        if (newStart.isBefore(oneYearAgo)) {
          _showError(context.tr("date_too_old") ?? 
              "Calculated start time cannot be more than 1 year ago");
          return;
        }
      }
      
      // Duration'ı ve time'ları güncelle
      final oldStart = start;
      final oldEnd = endTime;
      
      setState(() {
        widget.duration = setDuration;
        totalSleepTime = formatDuration(setDuration);
        start = newStart;
        endTime = newEnd;
        selectedDatetime = newEnd;
      });
      
      // Bloc'a bildir - önce duration, sonra time'lar
      context.read<SleepTimerBloc>().add(
        SetDurationTimer(duration: setDuration, activityType: 'sleepTimer'),
      );
      
      // Eğer start time değiştiyse, bloc'a bildir
      if (newStart != null && newStart != oldStart) {
        context.read<SleepTimerBloc>().add(
          SetStartTimeTimer(
            startTime: newStart,
            activityType: 'sleepTimer',
          ),
        );
      }
      
      // Eğer end time değiştiyse, bloc'a bildir
      if (newEnd != null && newEnd != oldEnd) {
        context.read<SleepTimerBloc>().add(
          SetEndTimeTimer(
            activityType: 'sleepTimer',
            endTime: newEnd,
          ),
        );
      }
    }
  }
}
