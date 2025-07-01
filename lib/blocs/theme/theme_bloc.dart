import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_baby_sara/app/theme/app_themes.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/repositories/baby_repository.dart';
import 'package:meta/meta.dart';

part 'theme_event.dart';

part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final BabyRepository _babyRepository = getIt<BabyRepository>();

  ThemeBloc()
    : super(ThemeInitial(themeData: AppThemes.girlTheme, gender: 'Girl')) {
    on<LoadThemeFromBabyGender>((event, emit) async {
      var baby = await _babyRepository.getSelectedBaby(event.babyID);
      if (baby!.gender == "Male") {
        emit(ThemeInitial.boy());
      }  else if (baby.gender == "Female") {
        emit(ThemeInitial.girl());
      }  else{
        emit(ThemeInitial.girl());
      }
    });
  }
}
