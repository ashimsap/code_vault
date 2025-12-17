import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/providers.dart';
import 'package:flutter/material.dart';
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

  // The function is now async to handle the database operation properly.
  Future<void> _createSnippet() async {
    if (_controller.text.isEmpty) return;

    final newSnippet = Snippet(
      description: _controller.text, // The initial title
      fullDescription: '', // Initialize with blank description
      codeContent: '', // Blank code content
      mediaPaths: [], // No media initially
      categories: [],
      creationDate: DateTime.now(),
      lastModificationDate: DateTime.now(),
      deviceSource: 'Phone',
    );

    try {
      // We now await the result of the add operation.
      await ref.read(snippetListProvider.notifier).addSnippet(newSnippet);

      // Only pop the dialog if the widget is still mounted and saving was successful.
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // If an error occurs, show it to the user.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create snippet: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardColor, // Use theme's card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Create New Snippet', style: TextStyle(color: theme.colorScheme.onSurface)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Title...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createSnippet,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
