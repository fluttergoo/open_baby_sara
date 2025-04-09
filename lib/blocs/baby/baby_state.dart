part of 'baby_bloc.dart';

@immutable
sealed class BabyState {}

final class BabyInitial extends BabyState {}

final class BabyLoading extends BabyState {}

final class BabySuccess extends BabyState {}

final class BabyFailure extends BabyState {
  final String message;
  BabyFailure(this.message);
}
