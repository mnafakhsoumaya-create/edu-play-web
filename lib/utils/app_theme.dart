import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTheme {
  static const Color primary    = Color(0xFFFF6B35);
  static const Color secondary  = Color(0xFF4ECDC4);
  static const Color accent     = Color(0xFFFFE66D);
  static const Color darkText   = Color(0xFF2D3436);
  static const Color lightText  = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFF9F0);

  static const Color beachColor  = Color(0xFFFFB347);
  static const Color safariColor = Color(0xFF78C843);
  static const Color oceanColor  = Color(0xFF00B4D8);
  static const Color mathColor   = Color(0xFFA855F7);
  static const Color colorColor  = Color(0xFFFF6B9D);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      textTheme: GoogleFonts.fredokaTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: lightText,
        centerTitle: true,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
      ),
    );
  }
}