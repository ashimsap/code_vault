import 'dart:convert';
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/api_providers.dart';
import 'package:code_vault/providers/data_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';

class ApiService {
  final Ref _ref;

  ApiService(this._ref);

  // Helper to convert a Flutter Color to a CSS hex string
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).padLeft(6, '0')}';
  }

  Future<Response> handleApiRequest(Request request) async {
    final path = request.url.path.trim().replaceAll(RegExp(r'^/|/$'), '');

    if (request.method == 'GET') {
      if (path == 'api/snippets') return _getSnippets();
      if (path == 'status') return _getStatus();
    }

    if (request.method == 'POST') {
      if (path == 'api/snippets/create') return _createSnippet(request);
    }

    return Response.notFound('API endpoint not found');
  }

  Future<Response> _getSnippets() async {
    final snippets = _ref.read(snippetListProvider);
    final json = jsonEncode(snippets.map((s) => s.toJson()).toList());
    return Response.ok(json, headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _getStatus() async {
    final ip = await _ref.read(ipAddressProvider.future);
    final isRunning = _ref.read(serverRunningProvider);
    final themeMode = _ref.read(themeModeProvider);
    final accentTheme = _ref.read(accentThemeProvider);

    final statusData = {
      'ipAddress': ip,
      'isServerRunning': isRunning,
      'port': 8765,
      'themeMode': themeMode == ThemeMode.dark ? 'dark' : 'light',
      'accentColor': _colorToHex(accentTheme.color),
    };
    return Response.ok(jsonEncode(statusData), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _createSnippet(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final json = jsonDecode(requestBody) as Map<String, dynamic>;

      final newSnippet = Snippet(
        description: json['description'] as String,
        codeContent: json['codeContent'] as String,
        mediaPaths: [],
        categories: [],
        creationDate: DateTime.now(),
        lastModificationDate: DateTime.now(),
        deviceSource: 'Web Client',
      );

      await _ref.read(snippetListProvider.notifier).addSnippet(newSnippet);

      return Response.ok('Snippet created successfully');
    } catch (e) {
      return Response.internalServerError(body: 'Error creating snippet: $e');
    }
  }
}
