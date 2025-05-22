import 'package:bloc/bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/relaxing_sound_repository.dart';
import 'package:meta/meta.dart';

part 'sound_relaxing_event.dart';

part 'sound_relaxing_state.dart';

class SoundRelaxingBloc extends Bloc<SoundRelaxingEvent, SoundRelaxingState> {
  final RelaxingSoundRepository _relaxingSoundRepository =
      getIt<RelaxingSoundRepository>();

  SoundRelaxingBloc() : super(SoundRelaxingInitial()) {
    on<SoundRelaxingEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<SaveSound>((event, emit) async {
      emit(SoundRelaxingLoading());
      try {
        final result = await _relaxingSoundRepository.saveSoundPlay(
          event.index,
        );
        emit(FetchSoundRelaxing(runningIndexSound: event.index));
      } catch (e) {
        emit(SoundRelaxingError(message: 'Error ${e.toString()}'));
      }
    });

    on<StopSound>((event, emit) async {
      emit(SoundRelaxingLoading());
      try {
        await _relaxingSoundRepository.stopSound(event.index);
        emit(SoundRelaxingStop());
      } catch (e) {
        emit(SoundRelaxingError(message: 'Error ${e.toString()}'));
      }
    });

    on<LoadSound>((event, emit) async {
      emit(SoundRelaxingLoading());
      try {
        final result = await _relaxingSoundRepository.loadSound();
        if (result != null && result['isRunning'] == 1) {
          emit(FetchSoundRelaxing(runningIndexSound: result['index']));
        } else {
          emit(SoundRelaxingStop());
        }
      } catch (e) {
        emit(SoundRelaxingError(message: 'Error ${e.toString()}'));
      }
    });
  }
}
