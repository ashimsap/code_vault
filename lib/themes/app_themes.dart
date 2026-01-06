import 'package:flutter/material.dart';

// A simple class to hold the accent color and its name
class AccentTheme {
  final String name;
  final Color color;

  const AccentTheme(this.name, this.color);
}

// --- BASE THEMES ---
final baseLightTheme = ThemeData.light(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Off-white
  cardColor: Colors.white, // Brighter white cards
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF5F5F5), // Match scaffold
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF5F5F5), // Match scaffold
    elevation: 0,
  ),
);

// A modern, more visually appealing dark theme
final baseDarkTheme = ThemeData.dark(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: const Color(0xFF36393e), // Your chosen dark grey
  cardColor: const Color(0xFF40444b),           // A slightly lighter grey for cards
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF36393e), // Match scaffold
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF36393e), // Match scaffold
    elevation: 0,
  ),
);


// --- ACCENT THEMES ---
// List of available accent colors.
final List<AccentTheme> accentThemes = [
  const AccentTheme('Default', Color(0xFF5892E5)),
  const AccentTheme('Mint', Color(0xFF66CDAA)),
  const AccentTheme('Lavender', Color(0xFFBDB2FF)),
  const AccentTheme('Sunset', Color(0xFFFFB3A7)),
  const AccentTheme('Ocean', Color(0xFF81D4FA)),
  const AccentTheme('Rose', Color(0xFFF48FB1)),
  const AccentTheme('Forest', Color(0xFF81C784)),
  const AccentTheme('Sand', Color(0xFFD2B48C)),
];
