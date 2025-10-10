part of 'sound_relaxing_bloc.dart';

@immutable
sealed class SoundRelaxingState {}

final class SoundRelaxingInitial extends SoundRelaxingState {}

class SoundRelaxingLoading extends SoundRelaxingState {}

class SoundRelaxingStop extends SoundRelaxingState {}

class FetchSoundRelaxing extends SoundRelaxingState {
  final int runningIndexSound;

  FetchSoundRelaxing({required this.runningIndexSound});
}

class SoundRelaxingError extends SoundRelaxingState {
  final String message;

  SoundRelaxingError({required this.message});
}
