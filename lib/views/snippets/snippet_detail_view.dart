import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:code_vault/models/snippet.dart';
// Import for syntax highlighting
import 'package:flutter_highlight/themes/monokai-sublime.dart'; 

class SnippetDetailView extends StatefulWidget {
  final Snippet snippet;

  const SnippetDetailView({super.key, required this.snippet});

  @override
  State<SnippetDetailView> createState() => _SnippetDetailViewState();
}

class _SnippetDetailViewState extends State<SnippetDetailView> {
  late CodeController _codeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.snippet.description);
    _codeController = CodeController(
      text: widget.snippet.codeContent,
      // TODO: Add language support
      // language: dart,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Snippet'),
        // TODO: Add save button
      ),
      body: Column(
        children: [
          // TODO: Add media view (image/gif/video)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(styles: monokaiSublimeTheme),
              child: CodeField(
                controller: _codeController,
                textStyle: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
