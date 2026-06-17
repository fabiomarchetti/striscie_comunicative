import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens dell'app "Segnami" (vedi handoff §Design Tokens).
/// Tutti i colori, raggi e ombre sono ricavati fedelmente dal documento di
/// design e centralizzati qui per essere riusati nelle schermate.
abstract class AppColors {
  // Primario / accenti
  static const primary = Color(0xFF9C4A2B);
  static const primaryPressed = Color(0xFF85391F);
  static const primaryGradientStart = Color(0xFFC0432A);
  static const primaryGradientEnd = Color(0xFF9C4A2B);

  // Superfici
  static const surface = Color(0xFFFFF8F5); // app / contenuto
  static const railSurface = Color(0xFFF7EBE3); // NavigationRail
  static const card = Color(0xFFFFFFFF);
  static const softSurface = Color(0xFFFCF1EB); // drop box
  static const softSurfaceAlt = Color(0xFFF0E3DB); // area chip / anteprime

  // Bordi e divisori
  static const cardBorder = Color(0xFFEAD9D0);
  static const divider = Color(0xFFEFE0D8);
  static const dashedBorder = Color(0xFFD3A98E);

  // Container accento (badge / indicatore / chip)
  static const accentContainer = Color(0xFFFFDBCB);
  static const onAccentContainer = Color(0xFF3A0A00);

  // Testo
  static const textPrimary = Color(0xFF26211D);
  static const textPrimaryAlt = Color(0xFF221A15);
  static const textSecondary = Color(0xFF6E5F57);
  static const textSecondaryAlt = Color(0xFF53433C);
  static const textMuted = Color(0xFFA7958C);
  static const textMutedAlt = Color(0xFF85736B);

  // Sfondo esterno (gradiente "device")
  static const outerStart = Color(0xFFCDD2D8);
  static const outerEnd = Color(0xFFC2C7CE);

  // Snackbar
  static const snackbarBg = Color(0xFF382E29);
  static const snackbarText = Color(0xFFFFEDE5);
  static const snackbarIcon = Color(0xFFFFB59B);

  // Chip tipizzati (dominio componenti/frasi)
  static const soggettoAccent = Color(0xFF3F5BA9);
  static const soggettoContainer = Color(0xFFDEE3FF);
  static const onSoggetto = Color(0xFF00164F);

  static const verboAccent = Color(0xFFC0432A);
  static const verboContainer = Color(0xFFFFDAD0);
  static const onVerbo = Color(0xFF3A0500);

  static const complementoAccent = Color(0xFF2E7D52);
  static const complementoContainer = Color(0xFFC9EFD6);
  static const onComplemento = Color(0xFF00210F);
}

/// Raggi standard del design system.
abstract class AppRadii {
  static const pill = 22.0; // pillole / campi / card
  static const card = 22.0;
  static const innerBox = 18.0; // box interni
  static const dropBox = 16.0;
  static const chip = 11.0;
  static const logo = 13.0;
}

/// Ombre standard.
abstract class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x0F281E16), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const primaryButton = [
    BoxShadow(color: Color(0x479C4A2B), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const primaryButtonLarge = [
    BoxShadow(color: Color(0x479C4A2B), blurRadius: 16, offset: Offset(0, 6)),
  ];
  static const plusCircle = [
    BoxShadow(color: Color(0x479C4A2B), blurRadius: 11, offset: Offset(0, 4)),
  ];
  static const logo = [
    BoxShadow(color: Color(0x529C4A2B), blurRadius: 14, offset: Offset(0, 6)),
  ];
}

/// Costruisce il [ThemeData] Material 3 dell'app.
class AppTheme {
  static ThemeData build() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      primaryContainer: AppColors.accentContainer,
      onPrimaryContainer: AppColors.onAccentContainer,
    );

    final baseText = GoogleFonts.robotoFlexTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: baseText.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Font monospace per ID / schema / filename video.
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
