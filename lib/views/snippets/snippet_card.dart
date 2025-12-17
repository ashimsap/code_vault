import 'package:code_vault/models/snippet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnippetCard extends ConsumerWidget {
  final Snippet snippet;
  final bool isSelected; // Replaces isDeletable
  final VoidCallback? onDelete; 

  const SnippetCard({
    super.key,
    required this.snippet,
    this.isSelected = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primary.withOpacity(0.1);
    final textColor = theme.colorScheme.onSurface.withOpacity(0.9);

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: isSelected ? 3 : 1, // Thicker border when selected
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snippet.description,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Removed Expanded to enforce fixed size
                Text(
                  snippet.codeContent,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: textColor.withOpacity(0.7)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4, // Fixed max lines
                ),
              ],
            ),
          ),
          // Selection Overlay
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              child: const Center(
                child: Icon(Icons.check_circle_outline, color: Colors.white, size: 40),
              ),
            ),
          // Delete button positioned at the top-right corner
          if (isSelected)
            Positioned(
              top: -12,
              right: -12,
              child: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  radius: 14,
                  child: Icon(Icons.delete, color: Colors.white, size: 16),
                ),
                onPressed: onDelete,
                tooltip: 'Delete Snippet',
              ),
            ),
        ],
      ),
    );
  }
}
