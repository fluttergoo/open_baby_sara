part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent {}

class LoadThemeFromBabyGender extends ThemeEvent {
  final String? babyID;

  LoadThemeFromBabyGender(this.babyID);
}
