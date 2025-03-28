import 'package:flutter/material.dart';
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
      headlineLarge: GoogleFonts.dancingScript(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF333333),
      ),
      headlineMedium: GoogleFonts.dancingScript(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF333333),
      ),
      headlineSmall: GoogleFonts.dancingScript(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: const Color(0xFF333333),
      ),
      bodyLarge: const TextStyle(fontSize: 24, color: Color(0xFF333333)),
      bodyMedium: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
      bodySmall: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4081),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
