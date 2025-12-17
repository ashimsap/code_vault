import 'package:code_vault/helpers/storage_helper.dart';
import 'package:code_vault/http_server.dart';
import 'package:code_vault/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';

// --- THEME PROVIDERS ---

// Manages the app's primary theme mode (light or dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Manages the selected accent theme
final accentThemeProvider = StateProvider<AccentTheme>((ref) => accentThemes[0]);

// Combines the base theme and accent theme into the final, active theme
final activeThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  final accent = ref.watch(accentThemeProvider);
  final baseTheme = (mode == ThemeMode.light) ? baseLightTheme : baseDarkTheme;

  // Create a new ColorScheme using the base theme but with the chosen accent color
  final newColorScheme = baseTheme.colorScheme.copyWith(
    primary: accent.color,
    secondary: accent.color,
  );

  // Apply the new color scheme to the base theme
  return baseTheme.copyWith(
    colorScheme: newColorScheme,
    // You can customize other theme properties here too
    // e.g., appBarTheme, buttonTheme, etc.
  );
});

// --- SERVER AND NETWORK PROVIDERS ---

final storageHelperProvider = Provider<StorageHelper>((ref) {
  return StorageHelper.instance;
});

final databaseProvider = FutureProvider<void>((ref) async {
  final storageHelper = ref.watch(storageHelperProvider);
  await storageHelper.database;
});

final httpServerProvider = Provider<SimpleHttpServer>((ref) {
  final server = SimpleHttpServer();
  ref.onDispose(() => server.stop());
  return server;
});

final ipAddressProvider = FutureProvider<String?>((ref) async {
  return NetworkInfo().getWifiIP();
});

final clientUpdatesProvider = StreamProvider<List<String>>((ref) {
  final server = ref.watch(httpServerProvider);
  return server.clientUpdates;
});

final serverRunningProvider = StateNotifierProvider<ServerRunningNotifier, bool>((ref) {
  return ServerRunningNotifier(ref);
});

class ServerRunningNotifier extends StateNotifier<bool> {
  ServerRunningNotifier(this.ref) : super(false);

  final Ref ref;

  Future<void> startServer() async {
    final server = ref.read(httpServerProvider);
    final ip = await ref.read(ipAddressProvider.future);
    server.setIpAddress(ip);
    final success = await server.start();
    state = success;
  }

  void stopServer() {
    final server = ref.read(httpServerProvider);
    server.stop();
    state = false;
  }
}
