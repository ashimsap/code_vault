import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/providers.dart';
import 'package:code_vault/views/snippets/add_snippet_dialog.dart';
import 'package:code_vault/views/snippets/snippet_card.dart';
import 'package:code_vault/views/snippets/snippet_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAddSnippetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddSnippetDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snippets = ref.watch(snippetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Vault'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: snippets.isEmpty
            ? const Center(child: Text('No snippets yet. Tap \'+\' to add one!'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: snippets.length,
                itemBuilder: (context, index) {
                  final snippet = snippets[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SnippetDetailView(snippet: snippet),
                        ),
                      );
                    },
                    child: SnippetCard(snippet: snippet),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSnippetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
