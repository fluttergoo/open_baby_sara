import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:google_fonts/google_fonts.dart";

class AppThemes {
  static final ThemeData girlTheme = ThemeData(
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFDCA6F5),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.fredoka(
        fontSize: 32.sp,
        fontWeight: FontWeight.w300,
        color: const Color(0xFF333333),
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 20.sp,
        fontWeight: FontWeight.w300,
        color: const Color(0xFF333333),
      ),
      headlineSmall: GoogleFonts.fredoka(
        fontSize: 12.sp,
        fontWeight: FontWeight.w300,
        color: const Color(0xFF333333),
      ),
      bodyLarge: TextStyle(fontSize: 20.sp, color: Color(0xFF333333)),
      bodyMedium: TextStyle(fontSize: 14.sp, color: Color(0xFF333333)),
      bodySmall: TextStyle(fontSize: 10.sp, color: Color(0xFF333333)),
      titleMedium: TextStyle(fontSize: 10.sp, color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4081),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(fontSize: 10.sp, color: Colors.black),
      floatingLabelStyle: TextStyle(fontSize: 10.sp, color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.girlBorder, width: 1.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.girlPrimary, width: 2.r),
      ),
    ),
  );
}
