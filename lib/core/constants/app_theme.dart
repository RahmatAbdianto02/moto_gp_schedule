import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ===================== WARNA =====================
  static const Color primary = Color(0xFFE8003D);    // merah MotoGP
  static const Color black = Color(0xFF0D0D0D);       // hitam border
  static const Color white = Color(0xFFFAFAFA);       // putih background
  static const Color cream = Color(0xFFF5F0E8);       // krem card
  static const Color yellow = Color(0xFFFFD60A);      // aksen kuning
  static const Color grey = Color(0xFF9E9E9E);        // teks abu

  // ===================== BORDER =====================
  static const BorderSide borderSide = BorderSide(
    color: black,
    width: 2.5,
  );

  static const Border border = Border(
    top: borderSide,
    left: borderSide,
    right: borderSide,
    bottom: borderSide,
  );

  // ===================== SHADOW =====================
  // Neobrutalist shadow = offset solid, bukan blur
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: black,
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: black,
      offset: Offset(2, 2),
      blurRadius: 0,
    ),
  ];

  // ===================== DECORATION =====================
  // Box decoration siap pakai untuk card neobrutalist
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? cream,
        border: border,
        boxShadow: shadow,
      );

  static BoxDecoration cardDecorationSmall({Color? color}) => BoxDecoration(
        color: color ?? cream,
        border: border,
        boxShadow: shadowSmall,
      );

  // ===================== THEME DATA =====================
  static ThemeData get themeData => ThemeData(
        scaffoldBackgroundColor: white,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.light(
          primary: primary,
          onPrimary: white,
          surface: white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: white,
            elevation: 0,
            side: const BorderSide(color: black, width: 2.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // neobrutalist = sudut kotak
            ),
          ),
        ),
        chipTheme: const ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: black, width: 1.5),
          ),
        ),
        useMaterial3: true,
      );
}