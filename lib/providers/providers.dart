import 'package:code_vault/helpers/storage_helper.dart';
import 'package:code_vault/http_server.dart';
import 'package:code_vault/themes/app_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';

// A provider for the StorageHelper instance
final storageHelperProvider = Provider<StorageHelper>((ref) {
  return StorageHelper.instance;
});

// A future provider that initializes the database
final databaseProvider = FutureProvider<void>((ref) async {
  final storageHelper = ref.watch(storageHelperProvider);
  await storageHelper.database;
});

// Provider for the SimpleHttpServer
final httpServerProvider = Provider<SimpleHttpServer>((ref) {
  final server = SimpleHttpServer();
  ref.onDispose(() => server.stop());
  return server;
});

// Provider to get the IP address
final ipAddressProvider = FutureProvider<String?>((ref) async {
  return NetworkInfo().getWifiIP();
});

// Provider that exposes the stream of connected clients from the server
final clientUpdatesProvider = StreamProvider<List<String>>((ref) {
  final server = ref.watch(httpServerProvider);
  return server.clientUpdates;
});

// Provider to manage the server's running state
final serverRunningProvider = StateNotifierProvider<ServerRunningNotifier, bool>((ref) {
  return ServerRunningNotifier(ref);
});

// Provider to manage the currently selected theme
final activeThemeProvider = StateProvider<AppTheme>((ref) {
  // Default to the first theme in the list
  return appThemes[0];
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
