import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/providers.dart'; // Corrected import path
import 'package:code_vault/views/snippets/add_snippet_dialog.dart';
import 'package:code_vault/views/snippets/snippet_card.dart';
import 'package:code_vault/views/snippets/snippet_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<int> _selectedSnippetIds = [];

  bool get _isInSelectionMode => _selectedSnippetIds.isNotEmpty;

  void _onToggleSelection(int snippetId) {
    setState(() {
      if (_selectedSnippetIds.contains(snippetId)) {
        _selectedSnippetIds.remove(snippetId);
      } else {
        _selectedSnippetIds.add(snippetId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedSnippetIds = [];
    });
  }

  void _deleteSelectedSnippets() {
    final snippetNotifier = ref.read(snippetListProvider.notifier);
    for (final id in _selectedSnippetIds) {
      snippetNotifier.deleteSnippet(id);
    }
    _exitSelectionMode();
  }

  void _showAddSnippetDialog(BuildContext context) {
    _exitSelectionMode();
    showDialog(
      context: context,
      builder: (context) => const AddSnippetDialog(),
    );
  }

  AppBar _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Snippets'),
      centerTitle: true,
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
      ),
      title: Text('${_selectedSnippetIds.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _deleteSelectedSnippets,
          tooltip: 'Delete Selected',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final snippets = ref.watch(snippetListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isInSelectionMode ? _buildSelectionAppBar() : _buildDefaultAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: snippets.isEmpty
            ? const Center(child: Text('No snippets yet. Tap the button to create one!'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: snippets.length,
                itemBuilder: (context, index) {
                  final snippet = snippets[index];
                  final isSelected = _selectedSnippetIds.contains(snippet.id);
                  return GestureDetector(
                    onLongPress: () => _onToggleSelection(snippet.id!),
                    onTap: () {
                      if (_isInSelectionMode) {
                        _onToggleSelection(snippet.id!);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SnippetDetailView(snippet: snippet),
                          ),
                        );
                      }
                    },
                    child: SnippetCard(
                      snippet: snippet,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSnippetDialog(context),
        icon: Icon(Icons.edit, color: theme.colorScheme.onPrimary),
        label: Text('Create', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}
