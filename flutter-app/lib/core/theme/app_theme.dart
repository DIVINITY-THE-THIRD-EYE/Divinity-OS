import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand tokens ────────────────────────────────────────────────────────────
// Shared design system (decision #3): identical void/bone/ember hex values
// and Cormorant/Hanken Grotesk/JetBrains Mono typography across the
// website and every Flutter shell (website: app/globals.css,
// tailwind.config.ts). Ember is the one constant accent in both modes;
// void/bone (and the surface/text roles built from them) swap per theme —
// see AppColors.dark/light below for how the raw palette maps to each mode.

abstract final class DivinityPalette {
  static const Color voidColor = Color(0xFF15161E);
  static const Color deep = Color(0xFF1E2029);
  static const Color smoke = Color(0xFF2A2D38);
  static const Color bone = Color(0xFFECE7DB);
  static const Color bone2 = Color(0xFFE2DCCB);
  static const Color ember = Color(0xFFD08A3E);
  static const Color emberDeep = Color(0xFFA85E2A);
  static const Color emberPale = Color(0xFFE8C490);
  static const Color mist = Color(0xFF8E93A6);
  static const Color ink = Color(0xFF20242F);
}

abstract final class AppColors {
  // Night (default) — matches the website's dark mode (:root in globals.css).
  static const Color bgDark = DivinityPalette.voidColor;
  static const Color surfaceDark = DivinityPalette.deep;
  static const Color surfaceAltDark = DivinityPalette.smoke;
  static const Color accentViolet = DivinityPalette.ember;
  static const Color accentVioletHover = DivinityPalette.emberDeep;
  static const Color accentVioletLight = Color(0x29D08A3E); // ember @ 16%
  static const Color textDark = DivinityPalette.bone;
  static const Color textSecondaryDark = DivinityPalette.mist;
  static const Color textMutedDark = Color(0xFF62667A);
  static const Color borderDark = Color(0x29D08A3E); // ember @ 16% (line-dark)
  static const Color borderLightDark = Color(0x1AD08A3E); // ember @ 10%

  // Day — matches the website's light mode ([data-theme="light"]).
  static const Color bgLight = Color(0xFFFDFBF6);
  static const Color surfaceLight = Color(0xFFF5EFE0);
  static const Color surfaceAltLight = Color(0xFFEAE2CC);
  static const Color accentGold = DivinityPalette.ember; // same accent, both modes
  static const Color accentGoldHover = DivinityPalette.emberDeep;
  static const Color accentGoldLight = Color(0x29D08A3E); // ember @ 16%
  static const Color textLight = Color(0xFF1B1D24);
  static const Color textSecondaryLight = Color(0xFF3C3F49);
  static const Color textMutedLight = Color(0xFF6B6F7E);
  static const Color borderLight = Color(0x29A85E2A); // ember-deep @ 16%
  static const Color borderLightAlt = Color(0x1A20242F); // ink @ 10%

  // Semantic (not part of the brand palette — unchanged across modes).
  static const Color error = Color(0xFFD14646);
  static const Color errorBg = Color(0x14D14646);
  static const Color success = Color(0xFF4A9D6B);
  static const Color successBg = Color(0x144A9D6B);
  static const Color warning = Color(0xFFD4A04A);
}

// ── Text styles ──────────────────────────────────────────────────────────────
// Display: Cormorant. Body/UI: Hanken Grotesk. Mono/labels: JetBrains Mono.

abstract final class AppTextStyles {
  static TextTheme light() => TextTheme(
    displayLarge: GoogleFonts.cormorant(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: AppColors.textLight,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.cormorant(
      fontSize: 45,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
    ),
    displaySmall: GoogleFonts.cormorant(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
    ),
    headlineLarge: GoogleFonts.cormorant(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
    ),
    headlineMedium: GoogleFonts.cormorant(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
    ),
    headlineSmall: GoogleFonts.cormorant(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
    ),
    titleLarge: GoogleFonts.hankenGrotesk(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
    ),
    titleMedium: GoogleFonts.hankenGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textLight,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.hankenGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textLight,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.hankenGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textLight,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.hankenGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textLight,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.hankenGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondaryLight,
      letterSpacing: 0.4,
    ),
    labelLarge: GoogleFonts.hankenGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryLight,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.textMutedLight,
      letterSpacing: 0.5,
    ),
  );

  static TextTheme dark() => TextTheme(
    displayLarge: GoogleFonts.cormorant(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.cormorant(
      fontSize: 45,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    displaySmall: GoogleFonts.cormorant(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    headlineLarge: GoogleFonts.cormorant(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    headlineMedium: GoogleFonts.cormorant(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    headlineSmall: GoogleFonts.cormorant(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    titleLarge: GoogleFonts.hankenGrotesk(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    titleMedium: GoogleFonts.hankenGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textDark,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.hankenGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textDark,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.hankenGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textDark,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.hankenGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textDark,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.hankenGrotesk(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondaryDark,
      letterSpacing: 0.4,
    ),
    labelLarge: GoogleFonts.hankenGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDark,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.textMutedDark,
      letterSpacing: 0.5,
    ),
  );
}

// ── ThemeData builders ───────────────────────────────────────────────────────

abstract final class AppTheme {
  static ThemeData dark() {
    const accent = AppColors.accentViolet;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.bgDark,
        primary: accent,
        secondary: accent,
        onPrimary: Colors.white,
        onSurface: AppColors.textDark,
        error: AppColors.error,
        surfaceContainerHighest: AppColors.surfaceDark,
        outline: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: AppTextStyles.dark(),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.textMutedDark,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.accentVioletLight,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.hankenGrotesk(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.cormorant(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
    );
  }

  static ThemeData light() {
    const accent = AppColors.accentGold;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: AppColors.bgLight,
        primary: accent,
        secondary: accent,
        onSurface: AppColors.textLight,
        error: AppColors.error,
        surfaceContainerHighest: AppColors.surfaceLight,
        outline: AppColors.borderLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: AppTextStyles.light(),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.textSecondaryLight,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.textMutedLight,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.accentGoldLight,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.hankenGrotesk(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.cormorant(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
    );
  }
}
