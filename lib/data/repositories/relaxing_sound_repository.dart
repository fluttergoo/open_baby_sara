import 'package:flutter_sara_baby_tracker_and_sound/data/models/relaxing_sound_model.dart';

abstract class RelaxingSoundRepository{
  Future<void> saveSoundPlay(int index);
  Future<Map<String,dynamic>?> loadSound();
  Future<void> stopSound(int index);

}