import 'package:flutter/material.dart';

// Paleta J FIGHT — vermelho combate, superfícies claras para contraste com o logo
const Color verdeEscuro = Color(0xFFB91C1C);
const Color verdeMedio = Color(0xFFDC2626);
const Color verdeClaro = Color(0xFFEF4444);
const Color corFundoEscuro = Color(0xFFF3F4F6);
const Color corSuperficie = Color(0xFFFFFFFF);
const Color corDestaque = Color(0xFFF59E0B);

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: corFundoEscuro,
    colorScheme: ColorScheme.fromSeed(
      seedColor: verdeEscuro,
      brightness: Brightness.light,
      primary: verdeEscuro,
      secondary: corDestaque,
      surface: corSuperficie,
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
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: verdeEscuro, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: corSuperficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: corSuperficie,
      selectedItemColor: verdeEscuro,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
