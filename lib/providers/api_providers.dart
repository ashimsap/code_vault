import 'dart:async';
import 'package:code_vault/http_server.dart';
import 'package:code_vault/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mime/mime.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart';

// --- SERVER, NETWORK, AND API PROVIDERS ---

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});

final httpServerProvider = Provider<SimpleHttpServer>((ref) {
  final server = SimpleHttpServer();
  ref.onDispose(server.stop);
  return server;
});

final ipAddressProvider = FutureProvider<String?>((ref) async {
  return NetworkInfo().getWifiIP();
});

final serverHandlerProvider = Provider<Handler>((ref) {
  final apiService = ref.read(apiServiceProvider);

  return (Request request) async {
    // The handleRequest call is removed as this logic is now in ApiService

    final path = request.url.path.trim().replaceAll(RegExp(r'^/|/$'), '');

    // Check for API routes first (this now includes client registration)
    if (path.startsWith('api/') || path == 'status' || path.startsWith('media/')) {
      return await apiService.handleApiRequest(request);
    }

    // Otherwise, serve static files
    String assetPath = path.isEmpty ? 'index.html' : path;
    try {
      final data = await rootBundle.load('web/$assetPath');
      return Response.ok(data.buffer.asUint8List(), headers: {'Content-Type': lookupMimeType(assetPath) ?? 'application/octet-stream'});
    } on FlutterError {
      return Response.notFound('Not Found');
    }
  };
});

// The clientUpdatesProvider is removed as it is obsolete.

final serverRunningProvider = StateNotifierProvider<ServerRunningNotifier, bool>((ref) {
  return ServerRunningNotifier(ref);
});

class ServerRunningNotifier extends StateNotifier<bool> {
  ServerRunningNotifier(this.ref) : super(false);

  final Ref ref;

  Future<void> startServer() async {
    final handler = ref.read(serverHandlerProvider);
    final success = await ref.read(httpServerProvider).start(handler);
    state = success;
  }

  void stopServer() {
    ref.read(httpServerProvider).stop();
    state = false;
  }
}
