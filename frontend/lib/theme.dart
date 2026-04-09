import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0A0A0A);
  static const card = Color(0xFF111111);
  static const inputBg = Color(0xFF1A1A1A);
  static const primary = Color(0xFF00D4FF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textBody = Color(0xFFA0A0A0);
  static const textMuted = Color(0xFF666666);
  static const border = Color(0xFF222222);
  static const borderHover = Color(0xFF333333);
  static const success = Color(0xFF00FF88);
  static const warning = Color(0xFFFFAA00);
  static const danger = Color(0xFFFF4444);

  static const successBg = Color(0x2200FF88);
  static const warningBg = Color(0x22FFAA00);
  static const dangerBg = Color(0x22FF4444);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.card,
          background: AppColors.bg,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        dividerColor: AppColors.border,
        useMaterial3: true,
      );
}
