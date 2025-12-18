import 'dart:async';
import 'dart:io' as dart_io;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class SimpleHttpServer {
  dart_io.HttpServer? _server;
  final int _port = 8765;

  bool get isRunning => _server != null;

  Future<bool> start(Handler handler) async {
    if (_server != null) return true;
    try {
      _server = await serve(handler, dart_io.InternetAddress.anyIPv4, _port);
      print('Server running on port ${_server!.port}');
      return true;
    } catch (e) {
      print("Server failed to start: $e");
      return false;
    }
  }

  void stop() {
    _server?.close(force: true);
    _server = null;
  }
}
