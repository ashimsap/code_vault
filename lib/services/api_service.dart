import 'dart:convert';
import 'dart:io';
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/api_providers.dart';
import 'package:code_vault/providers/data_providers.dart';
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
    final path = request.url.path.trim().replaceAll(RegExp(r'^/|/$'), '');

    if (request.method == 'GET') {
      if (path == 'api/snippets') return _getSnippets();
      if (path == 'status') return _getStatus();
      if (path.startsWith('media/')) return _getMedia(path); // New media route
    }

    if (request.method == 'POST') {
      if (path == 'api/snippets/create') return await _createSnippet(request);
      if (path == 'api/snippets/update') return await _updateSnippet(request);
    }

    return Response.notFound('API endpoint not found');
  }

  Future<Response> _getSnippets() async {
    final snippets = _ref.read(snippetListProvider);
    return Response.ok(jsonEncode(snippets.map((s) => s.toJson()).toList()), headers: {'Content-Type': 'application/json'});
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
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(requestedPath);
      final file = File(p.join(documentsDir.path, fileName));

      if (await file.exists()) {
        // Security check: Ensure the file is within the app's documents directory
        if (!p.isWithin(documentsDir.path, file.path)) {
          return Response.forbidden('Access Denied');
        }
        final bytes = await file.readAsBytes();
        final mimeType = lookupMimeType(file.path);
        return Response.ok(bytes, headers: {'Content-Type': mimeType ?? 'application/octet-stream'});
      } else {
        return Response.notFound('Media not found');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Error serving media: $e');
    }
  }

  Future<Response> _createSnippet(Request request) async {
    // ... create logic
    return Response.ok('Not Implemented');
  }

  Future<Response> _updateSnippet(Request request) async {
    // ... update logic
    return Response.ok('Not Implemented');
  }
}
