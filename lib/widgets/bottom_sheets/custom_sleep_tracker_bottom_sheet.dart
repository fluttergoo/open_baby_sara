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

      // Eski veriler için uyumluluk: startTimeDate ve endTimeDate varsa kullan, yoksa activityDateTime'dan tarih al
      if (data['startTimeDate'] != null) {
        start = DateTime.parse(data['startTimeDate']);
      } else {
        // Eski veri formatı - sadece saat/dakika var, activityDateTime'dan tarih al
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
        // Eski veri formatı - sadece saat/dakika var, activityDateTime'dan tarih al
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
      // Yeni kayıt modu - timer state'ini kontrol et
      // Eğer timer çalışıyorsa, timer'dan start time'ı al
      Future.microtask(() async {
        final sleepBloc = context.read<SleepTimerBloc>();
        final currentState = sleepBloc.state;
        
        // Geçici olarak kaydedilmiş notes'u yükle
        final savedNotes = await SharedPrefsHelper.getSleepTrackerNotes(widget.babyID);
        if (savedNotes != null && savedNotes.isNotEmpty) {
          notesController.text = savedNotes;
        }
        
        if (currentState is TimerRunning && currentState.activityType == 'sleepTimer') {
          // Timer çalışıyorsa, timer'dan start time'ı al
          if (currentState.startTime != null) {
            setState(() {
              start = currentState.startTime;
              selectedDatetime = currentState.startTime;
              widget.duration = currentState.duration;
              totalSleepTime = formatDuration(currentState.duration);
              // End time null - timer çalışırken end time yok
              endTime = null;
            });
          }
        } else if (currentState is TimerStopped && currentState.activityType == 'sleepTimer') {
          // Timer durmuşsa, state'ten değerleri al
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

    // Notes değişikliklerini dinle ve kaydet
    notesController.addListener(() {
      if (!widget.isEdit) {
        // Sadece yeni kayıt modunda geçici olarak kaydet
        SharedPrefsHelper.saveSleepTrackerNotes(widget.babyID, notesController.text);
      }
    });

    getIt<AnalyticsService>().logScreenView('SleepActivityTracker');
  }

  @override
  void dispose() {
    // Timer'ı durdurma - timer gerçek bir timer gibi çalışmalı
    // Kullanıcı başka sayfaya gidebilir, uygulamayı kapatabilir, timer çalışmaya devam eder
    // Sadece controller'ı dispose et
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
                    // Timer'ı durdurma - timer gerçek bir timer gibi çalışmalı
                    // Kullanıcı başka sayfaya gidebilir, timer çalışmaya devam eder
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
                          // State değişikliklerini yönet - sadece ilgili state'lerde güncelle
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            
                            if (state is TimerStopped && state.activityType == 'sleepTimer') {
                              // Timer durduğunda state'ten değerleri al
                              bool needsUpdate = false;
                              if (state.endTime != null && endTime != state.endTime) {
                                endTime = state.endTime;
                                needsUpdate = true;
                              }
                              if (state.startTime != null && start != state.startTime) {
                                start = state.startTime;
                                needsUpdate = true;
                              }
                              if (widget.duration != state.duration) {
                                widget.duration = state.duration;
                                totalSleepTime = formatDuration(state.duration);
                                needsUpdate = true;
                              }
                              if (needsUpdate) {
                                setState(() {});
                              }
                            } else if (state is TimerRunning && state.activityType == 'sleepTimer') {
                              // Timer çalışırken sadece start time'ı güncelle
                              // End time null olmalı çünkü timer henüz bitmemiş
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
                              // Reset durumunda her şeyi temizle
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

                          // Start ve end time her ikisi de varsa ve timer durmuşsa total sleep time'ı hesapla
                          // Timer çalışırken bu hesaplamayı yapma çünkü timer kendi duration'ını yönetiyor
                          if (state is TimerStopped && start != null && endTime != null) {
                            final calculatedDuration = endTime!.difference(start!);
                            // Eğer duration henüz set edilmemişse veya farklıysa güncelle
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
                                    onDateTimeSelected: (selected) {
                                      // Timer çalışıyorsa, manuel moda geç (timer'ı durdur)
                                      final currentState = context.read<SleepTimerBloc>().state;
                                      final isTimerRunning = currentState is TimerRunning && 
                                                             currentState.activityType == 'sleepTimer';
                                      
                                      // End time varsa kontrol et
                                      if (endTime != null) {
                                        if (selected.isAfter(endTime!)) {
                                          _showError(context.tr("end_time_before_start"));
                                          return;
                                        }
                                        // Aralık bir günü geçiyorsa uyarı ver
                                        final difference = endTime!.difference(selected);
                                        if (difference.inHours > 24) {
                                          _showError(context.tr("sleep_duration_exceeds_one_day") ?? 
                                              "Sleep duration cannot exceed 24 hours");
                                          return;
                                        }
                                        // Total sleep time'ı hesapla (timer durmuşsa)
                                        if (!isTimerRunning) {
                                          _calculateAndUpdateTotalSleepTime(selected, endTime!);
                                        }
                                      }
                                      
                                      setState(() {
                                        start = selected;
                                        selectedDatetime = selected;
                                      });
                                      
                                      // SetStartTimeTimer event'i timer'ı durduracak (manuel moda geçiş)
                                      context.read<SleepTimerBloc>().add(
                                        SetStartTimeTimer(
                                          startTime: start,
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
                                        key: ValueKey('end_time_${endTime?.millisecondsSinceEpoch}_${isTimerRunning}'),
                                        initialText: 'initialText',
                                        initialDateTime: endTime,
                                        enabled: !isTimerRunning, // Timer çalışırken disabled
                                        onDateTimeSelected: (selected) {
                                          // Timer çalışıyorsa, manuel moda geç (timer'ı durdur)
                                          final currentState = context.read<SleepTimerBloc>().state;
                                          final isRunning = currentState is TimerRunning && 
                                                             currentState.activityType == 'sleepTimer';
                                          
                                          if (isRunning) {
                                            // Timer çalışırken end time seçilemez
                                            return;
                                          }
                                          
                                          if (start != null && selected.isBefore(start!)) {
                                            _showError(context.tr("end_time_before_start"));
                                            return;
                                          }
                                          final now = DateTime.now();
                                          if (selected.isAfter(now)) {
                                            _showError(context.tr("end_time_in_future"));
                                            return;
                                          }
                                          
                                          // Start time varsa kontrol et ve total sleep time'ı hesapla
                                          if (start != null) {
                                            // Aralık bir günü geçiyorsa uyarı ver
                                            final difference = selected.difference(start!);
                                            if (difference.inHours > 24) {
                                              _showError(context.tr("sleep_duration_exceeds_one_day") ?? 
                                                  "Sleep duration cannot exceed 24 hours");
                                              return;
                                            }
                                            // Total sleep time'ı hesapla (timer durmuşsa)
                                            _calculateAndUpdateTotalSleepTime(start!, selected);
                                          }
                                          
                                          setState(() {
                                            endTime = selected;
                                            selectedDatetime = selected;
                                          });
                                          
                                          // SetEndTimeTimer event'i timer'ı durduracak (manuel moda geçiş)
                                          context.read<SleepTimerBloc>().add(
                                            SetEndTimeTimer(
                                              activityType: 'sleepTimer',
                                              endTime: endTime!,
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

  void _calculateAndUpdateTotalSleepTime(DateTime startTime, DateTime endTime) {
    // Timer çalışıyorsa bu hesaplamayı yapma - timer kendi duration'ını yönetiyor
    final currentState = context.read<SleepTimerBloc>().state;
    if (currentState is TimerRunning) {
      return;
    }
    
    final difference = endTime.difference(startTime);
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

    if (endTime == null) {
      Navigator.of(context).pop();
      return;
    }

    if (start == null || widget.duration == null) {
      _showError(context.tr("please_complete_all_fields"));
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

      // Kayıt başarılı olduğunda geçici notes'u temizle
      if (!widget.isEdit) {
        await SharedPrefsHelper.clearSleepTrackerNotes(widget.babyID);
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => NavigationWrapper()));

      context.read<SleepTimerBloc>().add(
        ResetTimer(activityType: 'sleepTimer'),
      );
      _onPressedDelete(context);
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
      context.read<SleepTimerBloc>().add(
        SetDurationTimer(duration: setDuration, activityType: 'sleepTimer'),
      );
    }
  }
}
