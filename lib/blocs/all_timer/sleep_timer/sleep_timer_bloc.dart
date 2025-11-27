import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/repositories/timer_repository.dart';
import 'package:meta/meta.dart';

part 'sleep_timer_event.dart';

part 'sleep_timer_state.dart';

class SleepTimerBloc extends Bloc<SleepTimerEvent, SleepTimerState> {
  final TimerRepository _timerRepository = getIt<TimerRepository>();

  Timer? _timer;
  Duration _duration = Duration.zero;
  DateTime? _startTime;
  DateTime? _endTime;

  SleepTimerBloc() : super(SleepTimerInitial()) {
    on<SleepTimerEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<StartTimer>((event, emit) {
      _timer?.cancel();
      
      // Eğer event'te timerStart varsa onu kullan, yoksa _startTime varsa onu kullan, yoksa şu anki zamanı kullan
      if (event.timerStart != null) {
        _startTime = event.timerStart;
      } else {
        _startTime ??= DateTime.now();
      }
      
      // Timer repository'ye kaydet
      _timerRepository.saveTimerStart(_startTime!, event.activityType);

      // Duration'ı başlat - eğer endTime varsa hesapla, yoksa sıfırdan başla
      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      } else {
        _duration = Duration.zero;
      }

      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (!isClosed) {
          add(Tick(activityType: event.activityType));
        }
      });

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
      // Timer çalışıyorsa durdur
      _timer?.cancel();
      
      _startTime = event.startTime;

      if (_startTime != null) {
        // Eğer endTime varsa, duration'ı hesapla
        if (_endTime != null) {
          _duration = _calculateDuration(_startTime!, _endTime!);
        } else {
          // EndTime yoksa ve startTime geçmişteyse, şu anki zamana kadar olan süreyi hesapla
          final current = DateTime.now();
          if (_startTime!.isBefore(current)) {
            _duration = current.difference(_startTime!);
          } else {
            _duration = Duration.zero;
          }
        }
      } else {
        _duration = Duration.zero;
      }

      // EndTime yoksa şu anki zamanı kullan
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
      _timer?.cancel();

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
      // Timer çalışıyorsa durdur
      _timer?.cancel();
      
      _endTime = event.endTime;

      if (_startTime != null && _endTime != null) {
        _duration = _calculateDuration(_startTime!, _endTime!);
      } else {
        _duration = Duration.zero;
      }

      emit(
        TimerStopped(
          duration: _duration,
          endTime: _endTime,
          startTime: _startTime,
          activityType: event.activityType,
        ),
      );
    });
    on<SetDurationTimer>((event, emit) {
      // Timer çalışıyorsa durdur
      _timer?.cancel();
      
      // Eğer endTime zaten varsa onu kullan, yoksa şu anki zamanı kullan
      _endTime ??= DateTime.now();

      // StartTime'ı endTime'dan duration çıkararak hesapla
      if (_endTime != null) {
        _startTime = _endTime!.subtract(event.duration);
      } else {
        _startTime = null;
      }

      _duration = event.duration;

      emit(
        TimerStopped(
          duration: _duration,
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
        // Tarihli DateTime'ı direkt kullan
        final getTime = DateTime.parse(data['startTime']);
        _startTime = getTime;
        _endTime = null;
        
        // Duration'ı şu anki zamandan başlangıç zamanına kadar hesapla
        _duration = DateTime.now().difference(getTime);

        _timer = Timer.periodic(Duration(seconds: 1), (_) {
          if (!isClosed) {
            add(Tick(activityType: event.activityType));
          }
        });
        emit(
          TimerRunning(
            duration: _duration,
            startTime: _startTime,
            activityType: event.activityType,
          ),
        );
      } else {
        emit(SleepTimerInitial());
      }
    });
  }

  Duration _calculateDuration(DateTime start, DateTime end) {
    // Artık tam tarihli DateTime'lar kullanıldığı için direkt farkı hesapla
    // Eğer end start'tan önceyse (gece yarısını geçmişse), bir gün ekle
    if (end.isBefore(start)) {
      // Gece yarısını geçmiş durum - end'e bir gün ekle
      return end.add(const Duration(days: 1)).difference(start);
    }
    
    return end.difference(start);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  DateTime? _calculateStartTime(DateTime endTime, Duration duration) {
    // Artık tam tarihli DateTime kullanıldığı için direkt çıkar
    return endTime.subtract(duration);
  }
}
