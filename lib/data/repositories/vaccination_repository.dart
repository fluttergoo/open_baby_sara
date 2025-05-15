abstract class VaccinationRepository{
  Future<void> insertVaccination(String vaccinationNames);
  Future<List<String>?> fetchVaccinationList();
  Future<void> deleteVaccination(String vaccinationName);

}