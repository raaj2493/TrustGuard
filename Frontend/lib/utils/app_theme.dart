import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00F0FF); // Cyber Blue
  static const Color secondaryColor = Color(0xFF7B61FF); // Neon Purple
  static const Color accentColor = Color(0xFF00FF94); // Neon Green
  static const Color dangerColor = Color(0xFFFF2E2E); // Alert Red
  static const Color warningColor = Color(0xFFFFC107); // Warning Yellow
  
  static const Color darkBackground = Color(0xFF0A0E17);
  static const Color darkSurface = Color(0xFF161B28);
  
  static const Color lightBackground = Color(0xFFF0F2F5);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      error: dangerColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      headlineSmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
    ),
    useMaterial3: true,
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurface,
      error: dangerColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    useMaterial3: true,
  );
  
  // Glassmorphism decoration
  static BoxDecoration glassDecoration({Color? color}) {
    return BoxDecoration(
      color: (color ?? darkSurface).withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          spreadRadius: 2,
        )
      ],
    );
  }
}
