import 'dart:async';
import 'dart:io' as dart_io; // Alias dart:io to prevent name collisions
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class SimpleHttpServer {
  dart_io.HttpServer? _server;
  final int _port = 8765;
  Timer? _reaperTimer;

  static const _clientTimeout = Duration(seconds: 15);

  final _clients = <String, DateTime>{};
  final _clientStreamController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get clientUpdates => _clientStreamController.stream;

  bool get isRunning => _server != null;

  void handleRequest(Request request) {
    // HttpConnectionInfo now correctly refers to the type from shelf_io
    final connectionInfo = request.context['shelf.io.connection_info'] as dart_io.HttpConnectionInfo?;
    if (connectionInfo != null) {
      final clientIp = connectionInfo.remoteAddress.address;
      final isNewClient = !_clients.containsKey(clientIp);
      _clients[clientIp] = DateTime.now();

      if (isNewClient) {
        _clientStreamController.add(_clients.keys.toList());
      }
    }
  }

  Future<bool> start(Handler handler) async {
    if (_server != null) return true;
    try {
      final cascadedHandler = Cascade().add(handler).add((Request request) {
        handleRequest(request);
        return Response.notFound(''); // Fallback
      }).handler;

      _server = await serve(cascadedHandler, dart_io.InternetAddress.anyIPv4, _port);
      _startReaper();
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
          return true;
        }
        return false;
      });

      if (changed) {
        _clientStreamController.add(_clients.keys.toList());
      }
    });
  }
}
