import 'package:open_baby_sara/data/models/relaxing_sound_model.dart';

abstract class RelaxingSoundRepository{
  Future<void> saveSoundPlay(int index);
  Future<Map<String,dynamic>?> loadSound();
  Future<void> stopSound(int index);

}