import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF9F6EE), // Warm Cream
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF781C2E), // Burgundy
      secondary: const Color(0xFF8B2635),
      tertiary: const Color(0xFF9E2F3C),
      background: const Color(0xFFF9F6EE),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF9F6EE),
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF781C2E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF781C2E),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x0D781C2E)), // 0.05 opacity of 781C2E approx
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF781C2E),
        foregroundColor: Colors.white,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFF9F6EE),
      indicatorColor: const Color(0x1A781C2E), // 0.1 opacity
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(color: Color(0xFF781C2E), fontWeight: FontWeight.w500),
      ),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: Color(0xFF781C2E));
        }
        return const IconThemeData(color: Color(0x80781C2E)); // 0.5 opacity
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Indigo
      brightness: Brightness.dark,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
}
