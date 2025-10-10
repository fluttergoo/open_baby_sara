import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/repositories/timer_repository.dart';
import 'package:meta/meta.dart';

part 'breasfeed_left_side_timer_event.dart';
part 'breasfeed_left_side_timer_state.dart';

class BreasfeedLeftSideTimerBloc
    extends Bloc<BreasfeedLeftSideTimerEvent, BreasfeedLeftSideTimerState> {
  final TimerRepository _timerRepository = getIt<TimerRepository>();

  Timer? _timer;
  Duration _duration = Duration.zero;
  DateTime? _startTime;
  DateTime? _endTime;

  BreasfeedLeftSideTimerBloc() : super(BreasfeedLeftSideTimerInitial()) {
    on<BreasfeedLeftSideTimerEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<StartTimer>((event, emit) {
      _timer?.cancel();
      _startTime ??= DateTime.now();
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _startTime!.hour,
        _startTime!.minute,
        _startTime!.second,
      );
      _timerRepository.saveTimerStart(dateTime, event.activityType);

      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (!isClosed) {
          add(Tick(activityType: event.activityType));
        }
      });
      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      }
      emit(
        TimerRunning(
          duration: _duration,
          startTime: _startTime,
          activityType: event.activityType,
        ),
      );
    });

    on<Tick>((event, emit) {
      _duration += Duration(seconds: 1);
      emit(
        TimerRunning(
          duration: _duration,
          startTime: _startTime,
          activityType: event.activityType,
        ),
      );
    });

    on<SetStartTimeTimer>((event, emit) {
      _startTime = event.startTime;

      if (_startTime != null) {
        final now = DateTime.now();
        final selectedStart = DateTime(
          now.year,
          now.month,
          now.day,
          _startTime!.hour,
          _startTime!.minute,
          _startTime!.second,
        );
        final current = DateTime.now();

        if (selectedStart.isBefore(current)) {
          _duration = current.difference(selectedStart);
          _timerRepository.saveTimerStart(selectedStart, event.activityType);
        } else {
          _duration = Duration.zero;
        }
      } else {
        _duration = Duration.zero;
      }
      _endTime ??= DateTime.now();

      emit(
        TimerStopped(
          duration: _duration,
          startTime: _startTime,
          activityType: event.activityType,
          endTime: _endTime,
        ),
      );
    });

    on<StopTimer>((event, emit) async {
      _timer!.cancel();

      _endTime = DateTime.now();

      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      }
      await _timerRepository.stopTimer(event.activityType);

      emit(
        TimerStopped(
          duration: _duration,
          endTime: _endTime,
          activityType: event.activityType,
        ),
      );
    });
    on<SetEndTimeTimer>((event, emit) {
      _endTime = event.endTime;

      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      }

      emit(
        TimerStopped(
          duration: _duration,
          endTime: _endTime,
          activityType: event.activityType,
        ),
      );
    });
    on<SetDurationTimer>((event, emit) {
      _endTime = DateTime.now();

      _startTime = _calculateStartTime(_endTime!, event.duration);

      emit(
        TimerStopped(
          duration: event.duration,
          activityType: event.activityType,
          endTime: _endTime,
          startTime: _startTime,
        ),
      );
    });

    on<ResetTimer>((event, emit) async {
      _timer?.cancel(); // Stop the timer
      _timer = null;
      _duration = Duration.zero;
      _startTime = null;
      _endTime = null;

      await _timerRepository.clearTimer(event.activityType);

      emit(TimerReset());
    });

    on<LoadTimerFromLocalDatabase>((event, emit) async {
      _timer?.cancel();
      final data = await _timerRepository.loadTimer(event.activityType);
      if (data != null && data['isRunning'] == 1) {
        final getTime = DateTime.parse(data['startTime']);

        _startTime = DateTime(
          getTime.year,
          getTime.month,
          getTime.day,
          getTime.hour,
          getTime.minute,
          getTime.second,
        );
        _endTime = null;
        _duration = DateTime.now().difference(getTime);

        _timer = Timer.periodic(Duration(seconds: 1), (_) {
          add(Tick(activityType: event.activityType));
        });
        emit(
          TimerRunning(
            duration: _duration,
            startTime: _startTime,
            activityType: event.activityType,
          ),
        );
      } else {
        emit(BreasfeedLeftSideTimerInitial());
      }
    });
  }

  Duration _calculateDuration(DateTime start, DateTime end) {
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      start.hour,
      start.minute,
      start.second,
    );
    var endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      end.hour,
      end.minute,
      end.second,
    );

    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1)); // Night spillover
    }

    return endDateTime.difference(startDateTime);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  DateTime? _calculateStartTime(DateTime endTime, Duration duration) {
    final now = DateTime.now();

    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
      endTime.second,
    );

    final startDateTime = endDateTime.subtract(duration);

    return DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
      startDateTime.hour,
      startDateTime.minute,
      startDateTime.second,
    );
  }
}
