import 'package:open_baby_sara/data/models/medication_model.dart';

abstract class MedicationRepository{
  Future<void> insertMedication(MedicationModel medicationModel);
  Future<List<MedicationModel>?> fetchMedicationList();
  Future<void> deleteMedication(int id);

}