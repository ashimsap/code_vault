import 'package:code_vault/helpers/storage_helper.dart';
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/repositories/snippet_repository.dart';
import 'package:code_vault/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- THEME PROVIDERS ---

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final accentThemeProvider = StateProvider<AccentTheme>((ref) => accentThemes[0]);

final activeThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  final accent = ref.watch(accentThemeProvider);
  final baseTheme = (mode == ThemeMode.light) ? baseLightTheme : baseDarkTheme;
  final newColorScheme = baseTheme.colorScheme.copyWith(primary: accent.color, secondary: accent.color);
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
