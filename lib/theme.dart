import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0B1326);
  static const Color surface1 = Color(0xFF131B2E); 
  static const Color surface2 = Color(0xFF222A3D); 
  static const Color surface3 = Color(0xFF2D3449); 
  
  static const Color primary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFB9C8DE);
  static const Color onSurfaceVariant = Color(0xFF8E9193);
  static const Color outline = Color(0xFF444749);
  
  static const Color hairlineColor = Color(0x33444749); 

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: background,
        surfaceContainerLow: surface1,
        surfaceContainerHigh: surface2,
        surfaceContainerHighest: surface3,
        onPrimary: background,
        onSurface: primary,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: hairlineColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xE60B1326),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primary),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -2.24, color: primary),
        headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.64, color: primary),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.24, color: primary),
        titleLarge: GoogleFonts.geist(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: primary),
        titleMedium: GoogleFonts.geist(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0, color: primary),
        bodyLarge: GoogleFonts.geist(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0, color: primary),
        bodyMedium: GoogleFonts.geist(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.14, color: primary),
        bodySmall: GoogleFonts.geist(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.24, color: secondary),
        labelLarge: GoogleFonts.geist(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.28, color: primary),
        labelSmall: GoogleFonts.geist(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: secondary),
      ),
      cardTheme: CardThemeData(
        color: surface1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: hairlineColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface1,
        hintStyle: GoogleFonts.geist(color: onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: hairlineColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: hairlineColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.geist(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: outline, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.geist(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.geist(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Color(0xE60B1326),
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.geist(fontSize: 10, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5);
          }
          return GoogleFonts.geist(fontSize: 10, fontWeight: FontWeight.w500, color: onSurfaceVariant, letterSpacing: 0.5);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: onSurfaceVariant);
        }),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return surface2;
        }),
        checkColor: WidgetStateProperty.all(background),
        side: const BorderSide(color: hairlineColor, width: 1),
      ),
      dividerTheme: const DividerThemeData(
        color: hairlineColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
