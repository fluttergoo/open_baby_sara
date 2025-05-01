import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/activity_reposityory.dart';
import 'package:meta/meta.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {

  final ActivityRepository _activityRepository = getIt<ActivityRepository>();
  Timer? _syncTimer;



  ActivityBloc() : super(ActivityInitial()) {
    on<AddActivity>((event, emit) {
      try{
        _activityRepository.saveLocallyActivity(event.activityModel);
        emit(ActivityAdded());
      }catch(e){
        emit(ActivityError(e.toString()));
      }
    });
    on<StartAutoSync>((event,emit){
      _syncTimer?.cancel();
      _syncTimer=Timer.periodic(Duration(seconds: 1), (_)async{
        try{
            final  connectivityResult=Connectivity().checkConnectivity();
            if (connectivityResult != ConnectivityResult.none) {
              await _activityRepository.syncActivities();
            }  

        }catch(e){
          debugPrint(e.toString());
        }
      });
    });

    on<FetchActivitySleepLoad>((event,emit)async{
      final result=await _activityRepository.fetchLastSleepActivity(event.babyID);
      emit(SleepActivityLoaded(activityModel: result));
    });
  }
}
