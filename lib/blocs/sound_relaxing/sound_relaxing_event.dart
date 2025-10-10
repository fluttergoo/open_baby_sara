part of 'sound_relaxing_bloc.dart';

@immutable
sealed class SoundRelaxingEvent {}

class SaveSound extends SoundRelaxingEvent {
  final int index;

  SaveSound({required this.index});
}

class LoadSound extends SoundRelaxingEvent {}

class StopSound extends SoundRelaxingEvent {
  final int index;

  StopSound({required this.index});
}
