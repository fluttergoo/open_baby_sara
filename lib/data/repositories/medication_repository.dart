import 'package:flutter_sara_baby_tracker_and_sound/data/models/medication_model.dart';

abstract class MedicationRepository{
  Future<void> insertMedication(MedicationModel medicationModel);
  Future<List<MedicationModel>?> fetchMedicationList();
  Future<void> deleteMedication(int id);

}