import 'package:flutter/material.dart';

// Paleta J FIGHT — vermelho combate, preto e dourado
const Color verdeEscuro = Color(0xFFB91C1C);
const Color verdeMedio = Color(0xFFDC2626);
const Color verdeClaro = Color(0xFFEF4444);
const Color corFundoEscuro = Color(0xFF1A1A2E);
const Color corDestaque = Color(0xFFF59E0B);

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: verdeEscuro,
      primary: verdeEscuro,
      secondary: corDestaque,
      surface: corFundoEscuro,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: verdeEscuro,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: verdeEscuro,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: verdeEscuro, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: verdeEscuro,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
