part of 'baby_bloc.dart';

@immutable
sealed class BabyEvent {}

class RegisterBaby extends BabyEvent {
  final String firstName;

  final String gender;
  final DateTime dateTime;

  RegisterBaby({
    required this.firstName,
    required this.gender,
    required this.dateTime,
  });
}

class LoadBabies extends BabyEvent {}

class GetBabyInfo extends BabyEvent {
  final String babyID;

  GetBabyInfo({required this.babyID});
}

//TODO: Change Class Name
class onGenderSelectedEvent extends BabyEvent {
  final Gender gender;

  onGenderSelectedEvent({required this.gender});
}

class UploadBabyImage extends BabyEvent {
  final String babyID;

  UploadBabyImage({required this.babyID});
}

class UpdatedBaby extends BabyEvent {
  final String babyID;
  final Map<String, dynamic> updatedFields;

  UpdatedBaby({required this.babyID, required this.updatedFields});
}

class DeletedBaby extends BabyEvent {
  final String babyID;

  DeletedBaby({required this.babyID});
}

//TODO: AddBaby and RegisterBaby has to different business
class AddBaby extends BabyEvent {
  final String firstName;

  final String gender;
  final DateTime dateTime;
  final Map<String, String> nighttimeHours;
  final File? file;

  AddBaby({
    required this.firstName,
    required this.gender,
    required this.dateTime,
    required this.nighttimeHours,
    this.file
  });
}

class SelectBaby extends BabyEvent{
  final BabyModel selectBabyModel;

  SelectBaby({required this.selectBabyModel});

}
class LoadBabyImagePath extends BabyEvent {
  final String babyID;
  LoadBabyImagePath({required this.babyID});
}

class SaveBabyImage extends BabyEvent {
  final String babyID;
  final File imageFile;

  SaveBabyImage({required this.babyID, required this.imageFile});

}
class UpdateBabyImageLocal extends BabyEvent {
  final String babyID;
  final String imagePath;

  UpdateBabyImageLocal({required this.babyID, required this.imagePath});
}

