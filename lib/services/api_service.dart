import 'dart:convert';
import 'dart:io';
import 'package:code_vault/models/connected_device.dart';
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/providers.dart';
import 'package:code_vault/viewmodels/connected_devices_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';

class ApiService {
  final Ref _ref;

  ApiService(this._ref);

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).padLeft(6, '0')}';
  }

  Future<Response> handleApiRequest(Request request) async {
    final clientIp = (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)?.remoteAddress.address;
    if (clientIp != null) {
      _ref.read(connectedDevicesProvider.notifier).addOrUpdateDevice(clientIp);
      
      final device = _ref.read(connectedDevicesProvider).firstWhere((d) => d.ipAddress == clientIp, orElse: () => ConnectedDevice(ipAddress: clientIp, lastSeen: DateTime.now()));
      
      final isAllowed = device.status == AccessStatus.allowed || device.status == AccessStatus.tempAllowed;

      if (!isAllowed) {
        return Response.forbidden('Access Denied. Please ask for permission from the host app.');
      }
    }

    final path = request.url.path.trim().replaceAll(RegExp(r'^/|/$'), '');

    if (request.method == 'GET') {
      if (path == 'api/snippets') return _getSnippets();
      if (path == 'status') return _getStatus();
      if (path.startsWith('media/')) return _getMedia(path);
    }

    if (request.method == 'POST') {
      if (path == 'api/snippets/create') return await _createSnippet(request);
      if (path == 'api/snippets/update') return await _updateSnippet(request);
    }

    return Response.notFound('API endpoint not found');
  }

  Future<Response> _getSnippets() async {
    final snippets = _ref.read(snippetListProvider);
    return Response.ok(jsonEncode(snippets.map((s) => s.toApiJson()).toList()), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _getStatus() async {
    final ip = await _ref.read(ipAddressProvider.future);
    final isRunning = _ref.read(serverRunningProvider);
    final themeSettings = _ref.read(themeProvider);
    final statusData = {
      'ipAddress': ip,
      'isServerRunning': isRunning,
      'port': 8765,
      'themeMode': themeSettings.themeMode == ThemeMode.dark ? 'dark' : 'light',
      'accentColor': _colorToHex(themeSettings.accentTheme.color),
    };
    return Response.ok(jsonEncode(statusData), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _getMedia(String requestedPath) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(requestedPath);
    final file = File(p.join(documentsDir.path, fileName));

    if (await file.exists() && p.isWithin(documentsDir.path, file.path)) {
      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(file.path);
      return Response.ok(bytes, headers: {'Content-Type': mimeType ?? 'application/octet-stream'});
    } else {
      return Response.notFound('Media not found');
    }
  }

  Future<Response> _createSnippet(Request request) async {
    final requestBody = await request.readAsString();
    final json = jsonDecode(requestBody) as Map<String, dynamic>;
    final newSnippet = Snippet.fromJson(json);
    await _ref.read(snippetListProvider.notifier).addSnippet(newSnippet);
    return Response.ok(jsonEncode({'status': 'success'}));
  }

  Future<Response> _updateSnippet(Request request) async {
    final requestBody = await request.readAsString();
    final json = jsonDecode(requestBody) as Map<String, dynamic>;
    final snippet = Snippet.fromJson(json);
    await _ref.read(snippetListProvider.notifier).updateSnippet(snippet);
    return Response.ok(jsonEncode({'status': 'success'}));
  }
}
