part of 'baby_bloc.dart';
enum BabyStatus{
 loading, loaded,failure
}

//TODO: sealed abstract interface class?
@immutable
sealed class BabyState {}


final class BabyInitial extends BabyState {}

final class BabyLoading extends BabyState {}

final class BabySuccess extends BabyState {}

final class BabyFailure extends BabyState {
  final String message;
  BabyFailure(this.message);
}
class BabyLoaded extends BabyState {
  final List<BabyModel> babies;
  BabyModel? selectedBaby;
  BabyLoaded({required this.babies,this.selectedBaby});
}
class GotBabyInfo extends BabyState{
  final BabyModel babyModel;
  GotBabyInfo({required this.babyModel});
}

class onGenderSelectedState extends BabyState{
  Gender newGender;
  onGenderSelectedState({required this.newGender});
}

class UploadBabyImageUrl extends BabyState{
  final String imageUrl;
  UploadBabyImageUrl({required this.imageUrl});
}
class BabyUpdated extends BabyState {
  final String message;

  BabyUpdated({this.message = "Baby info successfully updated"});
}
class BabyDeleted extends BabyState {
  final String message;

  BabyDeleted({this.message = "Baby profile deleted successfully."});
}
class AddedBaby extends BabyState {
  final String message;

  AddedBaby({this.message = "Baby profile created successfully."});
}