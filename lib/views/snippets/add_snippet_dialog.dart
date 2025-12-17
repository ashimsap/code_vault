import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/data_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddSnippetDialog extends ConsumerStatefulWidget {
  const AddSnippetDialog({super.key});

  @override
  ConsumerState<AddSnippetDialog> createState() => _AddSnippetDialogState();
}

class _AddSnippetDialogState extends ConsumerState<AddSnippetDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSnippet() {
    if (_controller.text.isEmpty) return;

    final newSnippet = Snippet(
      description: _controller.text,
      codeContent: '// Add your code here',
      mediaPaths: [],
      categories: [],
      creationDate: DateTime.now(),
      lastModificationDate: DateTime.now(),
      deviceSource: 'Phone',
    );

    ref.read(snippetListProvider.notifier).addSnippet(newSnippet);
    Navigator.of(context).pop(); // Close dialog
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text;
    if (text != null) {
      _controller.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Snippet'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Description or code...',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.paste),
            onPressed: _pasteFromClipboard,
            tooltip: 'Paste from Clipboard',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addSnippet, // Add
          child: const Text('Add'),
        ),
      ],
    );
  }
}
