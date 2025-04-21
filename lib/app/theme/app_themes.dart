import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final ThemeData girlTheme = ThemeData(
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFF6F91),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF4081),
      secondary: Color(0xFFDCA6F5),
    ),
    textTheme: _commonTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4081),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    ),
    inputDecorationTheme: _inputDecorationTheme(AppColors.girlBorder, AppColors.girlPrimary),
  );

  static final ThemeData boyTheme = ThemeData(
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF4FC3F7), // canlı mavi
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0288D1),
      secondary: Color(0xFFB3E5FC),
    ),
    textTheme: _commonTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0288D1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    ),
    inputDecorationTheme: _inputDecorationTheme(AppColors.boyBorder, AppColors.boyPrimary),
  );

  static TextTheme _commonTextTheme() {
    return TextTheme(
      headlineLarge: GoogleFonts.dancingScript(fontSize: 32.sp, fontWeight: FontWeight.w300, color: const Color(0xFF333333)),
      headlineMedium: GoogleFonts.dancingScript(fontSize: 20.sp, fontWeight: FontWeight.w300, color: const Color(0xFF333333)),
      headlineSmall: GoogleFonts.dancingScript(fontSize: 12.sp, fontWeight: FontWeight.w300, color: const Color(0xFF333333)),
      bodyLarge: TextStyle(fontSize: 20.sp, color: const Color(0xFF333333)),
      bodyMedium: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
      bodySmall: TextStyle(fontSize: 10.sp, color: const Color(0xFF333333)),
      titleLarge: GoogleFonts.fredoka(fontSize: 32.sp, fontWeight: FontWeight.w300, color: const Color(0xFF333333)),
      titleMedium: GoogleFonts.fredoka(fontSize: 20.sp, fontWeight: FontWeight.w300, color: const Color(0xFF333333)),
      titleSmall: GoogleFonts.fredoka(fontSize: 12.sp, fontWeight: FontWeight.w300, color: const Color(0xFF333333)),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color borderColor, Color focusColor) {
    return InputDecorationTheme(
      labelStyle: TextStyle(fontSize: 10.sp, color: Colors.black),
      floatingLabelStyle: TextStyle(fontSize: 10.sp, color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: borderColor, width: 1.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: focusColor, width: 2.r),
      ),
    );
  }
}
