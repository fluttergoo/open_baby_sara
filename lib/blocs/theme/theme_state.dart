part of 'theme_bloc.dart';

@immutable
sealed class ThemeState {}

final class ThemeInitial extends ThemeState {
  final ThemeData themeData;
  final String gender;

  ThemeInitial({required this.themeData, required this.gender});

  factory ThemeInitial.girl() =>
      ThemeInitial(themeData: AppThemes.girlTheme, gender: 'Girl');

  factory ThemeInitial.boy() =>
      ThemeInitial(themeData: AppThemes.boyTheme, gender: 'Boy');
}
