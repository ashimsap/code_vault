import 'package:code_vault/models/snippet.dart';
import 'package:flutter/material.dart';

class SnippetCard extends StatelessWidget {
  final Snippet snippet;

  const SnippetCard({super.key, required this.snippet});

  @override
  Widget build(BuildContext context) {
    // TODO: Build the snippet card UI
    return Card(
      child: ListTile(
        title: Text(snippet.description),
        subtitle: Text(snippet.codeContent, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
