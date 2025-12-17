import 'dart:async';
import 'dart:io';
import 'dart:convert'; // Required for jsonEncode
import 'package:flutter/cupertino.dart'; // Keeping this import as requested
import 'package:flutter/services.dart' show rootBundle;
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

class SimpleHttpServer {
  HttpServer? _server;
  final int _port = 8765;
  String? _ipAddress;
  Timer? _reaperTimer;

  static const _clientTimeout = Duration(seconds: 15);

  // Store client IPs and their last seen time
  final _clients = <String, DateTime>{};
  final _clientStreamController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get clientUpdates => _clientStreamController.stream;

  bool get isRunning => _server != null;

  void setIpAddress(String? ip) {
    _ipAddress = ip;
  }

  Future<bool> start() async {
    if (_server != null) return true;
    try {
      final handler = const Pipeline().addMiddleware(logRequests()).addHandler(_masterHandler);
      _server = await io.serve(handler, InternetAddress.anyIPv4, _port);
      _startReaper(); // Start the timer to remove inactive clients
      print('Server running on port ${_server!.port}');
      return true;
    } catch (e) {
      print("Server failed to start: $e");
      return false;
    }
  }

  void stop() {
    _reaperTimer?.cancel();
    _server?.close(force: true);
    _server = null;
    _clients.clear();
    _clientStreamController.add([]);
  }

  void _startReaper() {
    _reaperTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      var changed = false;
      _clients.removeWhere((ip, lastSeen) {
        if (now.difference(lastSeen) > _clientTimeout) {
          changed = true;
          return true; // Remove this client
        }
        return false;
      });

      if (changed) {
        _clientStreamController.add(_clients.keys.toList());
      }
    });
  }

  Future<Response> _masterHandler(Request request) async {
    final connectionInfo = request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
    if (connectionInfo != null) {
      final clientIp = connectionInfo.remoteAddress.address;
      final isNewClient = !_clients.containsKey(clientIp);
      _clients[clientIp] = DateTime.now(); // Update client's last seen time

      if (isNewClient) {
        _clientStreamController.add(_clients.keys.toList()); // Notify UI of the new client
      }
    }

    final path = request.url.path;
    if (path == '/status' || path == 'status' || path == '/status/') {
      final statusData = {
        'ipAddress': _ipAddress,
        'isServerRunning': isRunning,
        'port': _port,
      };
      return Response.ok(jsonEncode(statusData), headers: {'Content-Type': 'application/json'});
    }

    String assetPath = request.url.path.startsWith('/') ? request.url.path.substring(1) : request.url.path;
    if (assetPath.isEmpty) assetPath = 'index.html';

    final fullAssetPath = 'web/$assetPath';
    try {
      final data = await rootBundle.load(fullAssetPath);
      final bytes = data.buffer.asUint8List();
      final mimeType = lookupMimeType(fullAssetPath);
      return Response.ok(bytes, headers: {'Content-Type': mimeType ?? 'application/octet-stream'});
    } on FlutterError {
      return Response.notFound('Asset not found: $fullAssetPath');
    } catch (e) {
      return Response.internalServerError(body: 'Error loading asset: $e');
    }
  }
}
