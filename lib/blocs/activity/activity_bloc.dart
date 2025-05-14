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
      _syncTimer=Timer.periodic(Duration(days: 5), (_)async{
        try{
            final  connectivityResult= await Connectivity().checkConnectivity();
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
    on<FetchActivityPumpLoad>((event, emit)async{
      final result= await _activityRepository.fetchLastPumpActivity(event.babyID);
      emit(PumpActivityLoaded(activityModel: result));
    });
    on<FetchToothIsoNumber>((event, emit) async {
      try {
        emit(ActivityLoading());

        final List<ActivityModel>? result =
        await _activityRepository.fetchAllTypeOfActivity(event.babyID, event.activityType);

        final List<String> toothIsoNumberList = [];

        if (result != null) {
          for (final activity in result) {
            final dynamic teeth = activity.data['teethingIsoNumber'];
            if (teeth is List) {
              toothIsoNumberList.addAll(teeth.map((e) => e.toString()));
            } else if (teeth is String) {
              toothIsoNumberList.add(teeth); // tekli kayıt varsa
            }
          }
        }

        emit(FetchToothIsoNumberLoaded(toothIsoNumber: toothIsoNumberList, toothActivities: result ?? []));
      } catch (e) {
        emit(ActivityError( e.toString()));
      }
    });

  }
}
