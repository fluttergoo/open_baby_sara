import 'package:open_baby_sara/data/models/invite_model.dart';

abstract class CaregiverRepository {
  Future<void> createCaregiver(InviteModel caregiver);
  Future<void> signUpCaregiverAndCheck(
    String firstName,
    String email,
    String password,
  );
  Future<void> signUpCaregiverWithGoogle(
    String firstName,
    String email,
  );
  Future<List<InviteModel>?> getCaregiverList();
  Future<void> deleteCaregiver(String caregiverID);
}
