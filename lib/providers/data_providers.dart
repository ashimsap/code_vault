import 'package:code_vault/helpers/storage_helper.dart';
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/repositories/snippet_repository.dart';
import 'package:code_vault/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- THEME PROVIDERS ---

// This notifier now manages both theme mode and accent color
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});

class ThemeSettings {
  final ThemeMode themeMode;
  final AccentTheme accentTheme;

  ThemeSettings({required this.themeMode, required this.accentTheme});
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(ThemeSettings(themeMode: ThemeMode.light, accentTheme: accentThemes[0])) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('themeMode') ?? 0;
    final accentIndex = prefs.getInt('accentTheme') ?? 0;

    state = ThemeSettings(
      themeMode: ThemeMode.values[modeIndex],
      accentTheme: accentThemes[accentIndex],
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    state = ThemeSettings(themeMode: mode, accentTheme: state.accentTheme);
  }

  Future<void> setAccentTheme(AccentTheme accent) async {
    final prefs = await SharedPreferences.getInstance();
    final accentIndex = accentThemes.indexOf(accent);
    await prefs.setInt('accentTheme', accentIndex);
    state = ThemeSettings(themeMode: state.themeMode, accentTheme: accent);
  }
}

// This provider now intelligently builds the theme based on the ThemeNotifier
final activeThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeProvider);
  final baseTheme = (settings.themeMode == ThemeMode.light) ? baseLightTheme : baseDarkTheme;
  final newColorScheme = baseTheme.colorScheme.copyWith(primary: settings.accentTheme.color, secondary: settings.accentTheme.color);
  return baseTheme.copyWith(colorScheme: newColorScheme);
});


// --- SNIPPET PROVIDERS ---

final storageHelperProvider = Provider<StorageHelper>((ref) {
  return StorageHelper.instance;
});

final snippetRepositoryProvider = Provider<SnippetRepository>((ref) {
  final dbHelper = ref.watch(storageHelperProvider);
  return SnippetRepository(dbHelper);
});

final snippetListProvider = StateNotifierProvider<SnippetNotifier, List<Snippet>>((ref) {
  final repository = ref.watch(snippetRepositoryProvider);
  return SnippetNotifier(repository);
});

class SnippetNotifier extends StateNotifier<List<Snippet>> {
  final SnippetRepository _repository;

  SnippetNotifier(this._repository) : super([]) {
    loadSnippets();
  }

  Future<void> loadSnippets() async {
    state = await _repository.readAll();
  }

  Future<void> addSnippet(Snippet snippet) async {
    await _repository.create(snippet);
    loadSnippets();
  }

  Future<void> updateSnippet(Snippet snippet) async {
    await _repository.update(snippet);
    loadSnippets();
  }

  Future<void> deleteSnippet(int id) async {
    await _repository.delete(id);
    loadSnippets();
  }
}
