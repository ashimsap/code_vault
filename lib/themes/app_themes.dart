import 'package:flutter/material.dart';

// A class to hold theme information
class AppTheme {
  final String name;
  final ThemeData data;

  const AppTheme(this.name, this.data);
}

// List of available themes
final List<AppTheme> appThemes = [
  AppTheme('Default', defaultTheme),
  AppTheme('Minty', mintyTheme),
  AppTheme('Lavender', lavenderTheme),
  AppTheme('Sunset', sunsetTheme),
];

// Theme Definitions
final defaultTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
);

final mintyTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  useMaterial3: true,
);

final lavenderTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 159, 134, 209)),
  useMaterial3: true,
);

final sunsetTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 159, 128)),
  useMaterial3: true,
);
