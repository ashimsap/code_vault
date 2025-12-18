import 'dart:async';
import 'dart:convert';
import 'package:code_vault/helpers/storage_helper.dart';
import 'package:code_vault/http_server.dart';
import 'package:code_vault/models/connected_device.dart';
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/repositories/device_repository.dart';
import 'package:code_vault/repositories/snippet_repository.dart';
import 'package:code_vault/services/api_service.dart';
import 'package:code_vault/themes/app_themes.dart';
import 'package:code_vault/viewmodels/connected_devices_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mime/mime.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf/shelf.dart';

// --- THEME PROVIDERS ---

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) => ThemeNotifier());
class ThemeSettings {
  final ThemeMode themeMode;
  final AccentTheme accentTheme;
  ThemeSettings({required this.themeMode, required this.accentTheme});
}
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(ThemeSettings(themeMode: ThemeMode.light, accentTheme: accentThemes[0])) { _loadTheme(); }
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('themeMode') ?? 0;
    final accentIndex = prefs.getInt('accentTheme') ?? 0;
    state = ThemeSettings(themeMode: ThemeMode.values[modeIndex], accentTheme: accentThemes[accentIndex]);
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

final activeThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeProvider);
  final baseTheme = (settings.themeMode == ThemeMode.light) ? baseLightTheme : baseDarkTheme;
  final newColorScheme = baseTheme.colorScheme.copyWith(primary: settings.accentTheme.color, secondary: settings.accentTheme.color);
  return baseTheme.copyWith(colorScheme: newColorScheme);
});

// --- SNIPPET PROVIDERS ---

final snippetRepositoryProvider = Provider<SnippetRepository>((ref) => SnippetRepository(StorageHelper.instance));
final snippetListProvider = StateNotifierProvider<SnippetNotifier, List<Snippet>>((ref) => SnippetNotifier(ref.watch(snippetRepositoryProvider)));

class SnippetNotifier extends StateNotifier<List<Snippet>> {
  final SnippetRepository _repository;
  SnippetNotifier(this._repository) : super([]) { loadSnippets(); }

  Future<void> loadSnippets() async { state = await _repository.readAll(); }

  // **THE FIX: This now returns the created snippet with its new ID**
  Future<Snippet> addSnippet(Snippet snippet) async {
    final createdSnippet = await _repository.create(snippet);
    loadSnippets();
    return createdSnippet;
  }

  Future<void> updateSnippet(Snippet snippet) async { await _repository.update(snippet); loadSnippets(); }
  Future<void> deleteSnippet(int id) async { await _repository.delete(id); loadSnippets(); }
}

// --- SERVER, NETWORK, AND API PROVIDERS ---

final apiServiceProvider = Provider<ApiService>((ref) => ApiService(ref));
final httpServerProvider = Provider<SimpleHttpServer>((ref) { final server = SimpleHttpServer(); ref.onDispose(server.stop); return server; });
final ipAddressProvider = FutureProvider<String?>((ref) async => NetworkInfo().getWifiIP());

final serverHandlerProvider = Provider<Handler>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return (Request request) async {
    final path = request.url.path.trim().replaceAll(RegExp(r'^/|/$'), '');
    if (path.startsWith('api/') || path == 'status' || path.startsWith('media/')) {
      return await apiService.handleApiRequest(request);
    }
    String assetPath = path.isEmpty ? 'index.html' : path;
    try {
      final data = await rootBundle.load('web/$assetPath');
      return Response.ok(data.buffer.asUint8List(), headers: {'Content-Type': lookupMimeType(assetPath) ?? 'application/octet-stream'});
    } on FlutterError {
      return Response.notFound('Not Found');
    }
  };
});

final serverRunningProvider = StateNotifierProvider<ServerRunningNotifier, bool>((ref) => ServerRunningNotifier(ref));
class ServerRunningNotifier extends StateNotifier<bool> {
  ServerRunningNotifier(this.ref) : super(false);
  final Ref ref;
  Future<void> startServer() async {
    final handler = ref.read(serverHandlerProvider);
    final success = await ref.read(httpServerProvider).start(handler);
    state = success;
  }
  void stopServer() { ref.read(httpServerProvider).stop(); state = false; }
}
