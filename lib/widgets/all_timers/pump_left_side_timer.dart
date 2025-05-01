import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/blocs/all_timer/pump_left_side_timer/pump_left_side_timer_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PumpLeftSideTimer extends StatefulWidget {
  final double size;
  final String activityType;

  const PumpLeftSideTimer({
    super.key,
    this.size = 140,
    required this.activityType,
  });

  @override
  State<PumpLeftSideTimer> createState() => _PumpLeftSideTimerState();
}

class _PumpLeftSideTimerState extends State<PumpLeftSideTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool _isRunning = false;

  late AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PumpLeftSideTimerBloc>().add(
      LoadTimerFromLocalDatabase(activityType: widget.activityType),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed && _isRunning) {
        _animationController.forward();
      }
    });
  }

  void _startTimer() {
    context.read<PumpLeftSideTimerBloc>().add(
      StartTimer(activityType: widget.activityType),
    );
    _isRunning = true;
    _animationController.forward();
  }

  void _stopTimer() {
    context.read<PumpLeftSideTimerBloc>().add(
      StopTimer(activityType: widget.activityType),
    );
    _timer?.cancel();
    _isRunning = false;
    _animationController.stop();
    _animationController.value = 1.0;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.remainder(60).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PumpLeftSideTimerBloc, PumpLeftSideTimerState>(
      builder: (context, state) {
        if (state is TimerRunning &&
            state.activityType == widget.activityType) {
          _duration = state.duration;
          _isRunning = true;
          _animationController.forward();
        }
        if (state is TimerStopped &&
            state.activityType == widget.activityType) {
          _duration = state.duration;
          _isRunning = false;
          _animationController.stop();
          _animationController.value = 1.0;
        }
        if (state is TimerReset) {
          _duration = Duration.zero;
          _timer?.cancel();
          _isRunning = false;
          _animationController.stop();
          _animationController.value = 1.0;
        }

        return Column(
          children: [
            Center(
              child: ScaleTransition(
                scale: _animationController,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRunning ? _stopTimer() : _startTimer();
                    });
                  },
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _isRunning
                ? Text(
                  'Tab to end',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
                : Text(
                  'Tab to start',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
          ],
        );
      },
    );
  }
}
