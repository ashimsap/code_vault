import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:code_vault/models/connected_device.dart';
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/providers.dart';
import 'package:code_vault/viewmodels/connected_devices_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;

class ApiService {
  final Ref _ref;

  ApiService(this._ref);

  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
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

    // Check for multipart manually since we aren't using the middleware
    if (request.method == 'POST' && request.mimeType == 'multipart/form-data') {
      if (path == 'api/media/upload') return await _uploadMedia(request);
    }

    if (request.method == 'GET') {
      if (path == 'api/snippets') return _getSnippets();
      if (path == 'status') return _getStatus();
      if (path.startsWith('media/')) return _getMedia(path);
    }

    if (request.method == 'POST') {
      if (path == 'api/snippets/create') return await _createSnippet(request);
      if (path == 'api/snippets/update') return await _updateSnippet(request);
      if (path == 'api/snippets/delete') return await _deleteSnippet(request); // Add delete handler
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
      return Response.ok(bytes, headers: {'Content-Type': lookupMimeType(file.path) ?? 'application/octet-stream'});
    } else {
      return Response.notFound('Media not found');
    }
  }

  Future<Response> _createSnippet(Request request) async {
    final requestBody = await request.readAsString();
    final json = jsonDecode(requestBody);
    final newSnippet = Snippet.fromJson(json);
    final createdSnippet = await _ref.read(snippetListProvider.notifier).addSnippet(newSnippet);
    return Response.ok(jsonEncode(createdSnippet.toApiJson()));
  }

  Future<Response> _updateSnippet(Request request) async {
    final requestBody = await request.readAsString();
    final json = jsonDecode(requestBody);
    final snippet = Snippet.fromJson(json);
    await _ref.read(snippetListProvider.notifier).updateSnippet(snippet);
    return Response.ok(jsonEncode({'status': 'success'}));
  }

  Future<Response> _deleteSnippet(Request request) async {
    final idStr = request.url.queryParameters['id'];
    if (idStr == null) return Response.badRequest(body: 'Missing id');
    final id = int.tryParse(idStr);
    if (id == null) return Response.badRequest(body: 'Invalid id');

    await _ref.read(snippetListProvider.notifier).deleteSnippet(id);
    return Response.ok(jsonEncode({'status': 'success'}));
  }

  Future<Response> _uploadMedia(Request request) async {
    final snippetId = int.tryParse(request.url.queryParameters['snippetId'] ?? '');
    if (snippetId == null) return Response.badRequest(body: 'Missing snippetId');

    final originalSnippet = _ref.read(snippetListProvider).firstWhere((s) => s.id == snippetId, orElse: () => throw Exception('Snippet not found'));

    final imageBytes = <int>[];
    
    // Use the `multipart` function from the library to get the parts
    // It returns a MultipartRequest? which we need to unwrap.
    final multipartRequest = request.multipart();
    if (multipartRequest == null) {
         return Response.badRequest(body: 'Not a multipart request');
    }

    // Iterate over the parts from the MultipartRequest
    await for (final part in multipartRequest.parts) {
      await for (final chunk in part) {
        imageBytes.addAll(chunk);
      }
    }

    final image = img.decodeImage(Uint8List.fromList(imageBytes));
    if (image == null) return Response.badRequest(body: 'Invalid image data');

    // Resize to 480p width as requested to fix freezing issues
    final resizedImage = img.copyResize(image, width: 480);
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImagePath = p.join(appDir.path, fileName);
    await File(savedImagePath).writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

    final updatedSnippet = originalSnippet.copyWith(mediaPaths: [savedImagePath]);
    await _ref.read(snippetListProvider.notifier).updateSnippet(updatedSnippet);

    return Response.ok(jsonEncode(updatedSnippet.toApiJson()));
  }
}
