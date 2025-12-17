import 'package:flutter/material.dart';

// A simple class to hold the accent color and its name
class AccentTheme {
  final String name;
  final Color color;

  const AccentTheme(this.name, this.color);
}

// --- BASE THEMES ---
// Defines the overall look of the app in light and dark mode.
final baseLightTheme = ThemeData.light(useMaterial3: true);
final baseDarkTheme = ThemeData.dark(useMaterial3: true);

// --- ACCENT THEMES ---
// List of available accent colors.
final List<AccentTheme> accentThemes = [
  const AccentTheme('Default', Colors.deepPurple),
  const AccentTheme('Mint', Color(0xFF66CDAA)),
  const AccentTheme('Lavender', Color(0xFFBDB2FF)),
  const AccentTheme('Sunset', Color(0xFFFFB3A7)),
  const AccentTheme('Ocean', Color(0xFF81D4FA)),
  const AccentTheme('Rose', Color(0xFFF48FB1)),
  const AccentTheme('Forest', Color(0xFF81C784)),
  const AccentTheme('Sand', Color(0xFFD2B48C)),
];
