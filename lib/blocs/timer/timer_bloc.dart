import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/timer_repository.dart';
import 'package:meta/meta.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final TimerRepository _timerRepository = getIt<TimerRepository>();

  Timer? _timer;
  Duration _duration = Duration.zero;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  TimerBloc() : super(TimerInitial()) {
    on<TimerEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<StartSleepTimer>((event, emit) {
      _timer?.cancel();
      _startTime ??= TimeOfDay.now();
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month,now.day,_startTime!.hour, _startTime!.minute);

      _timerRepository.saveTimerStart(dateTime);

      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        add(Tick());
      });
      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      }
      emit(TimerRunning(duration: _duration, startTime: _startTime));
    });
    on<Tick>((event, emit) {
      _duration += Duration(seconds: 1);
      emit(TimerRunning(duration: _duration, startTime: _startTime));
    });
    on<SetTimer>((event, emit) {
      _startTime = event.setTimer;

      if (_startTime != null) {
        final now = DateTime.now();
        final selectedStart = DateTime(
          now.year,
          now.month,
          now.day,
          _startTime!.hour,
          _startTime!.minute,
        );
        final current = DateTime.now();

        if (selectedStart.isBefore(current)) {
          _duration = current.difference(selectedStart);
          _timerRepository.saveTimerStart(selectedStart);

        } else {
          _duration = Duration.zero;
        }
      } else {
        _duration = Duration.zero;
      }
      emit(TimerRunning(duration: _duration, startTime: _startTime));
    });

    on<StopSleepTimer>((event, emit) async{
      _timer!.cancel();

      _endTime = TimeOfDay.now();

      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      }
      await _timerRepository.stopTimer();

      emit(TimerStopped(duration: _duration, endTime: _endTime));
    });
    on<SetEndTimer>((event, emit) {
      _endTime = event.setTimer;

      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      }

      emit(TimerStopped(duration: _duration, endTime: _endTime));
    });

    on<CancelTimer>((event, emit) async{
      _timer?.cancel(); // Stop the timer
      _timer = null;
      _duration = Duration.zero;
      _startTime = null;
      _endTime = null;

      await _timerRepository.clearTimer();

      emit(TimerReset());
    });

    on<LoadTimerFromLocalDatabase>((event,emit)async{
      final data= await _timerRepository.loadTimer();
      if (data !=null && data['isRunning']==1) {
        final getTime=DateTime.parse(data['startTime']);

        _startTime=TimeOfDay(hour: getTime.hour, minute: getTime.minute);
        _endTime=null;
        _duration=DateTime.now().difference(getTime);
        
        _timer = Timer.periodic(Duration(seconds: 1), (_) {
          add(Tick());
        });
        emit(TimerRunning(duration: _duration,startTime: _startTime));
      }  else{
        emit(TimerInitial());
      }
    });
  }

  Duration _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      start.hour,
      start.minute,
    );
    var endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      end.hour,
      end.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1)); // Night spillover
    }

    return endDateTime.difference(startDateTime);
  }
}
