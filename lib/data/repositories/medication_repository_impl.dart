import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/models/medication_model.dart';
import 'package:open_baby_sara/data/repositories/medication_repository.dart';
import 'package:sqflite/sqflite.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final Database database;

  MedicationRepositoryImpl({required this.database});



  @override
  Future<void> deleteMedication(int id) async {
    final result = await database.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<MedicationModel>?> fetchMedicationList() async {
    final result = await database.rawQuery('SELECT * FROM medications');

    if (result.isNotEmpty) {
      return result.map((e) => MedicationModel.fromMap(e)).toList();
    } else {
      return null;
    }
  }

  @override
  Future<void> insertMedication(MedicationModel medicationModel) async {
    await database.insert(
      'medications',
      medicationModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
