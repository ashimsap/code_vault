import 'dart:io';
import 'package:code_vault/models/snippet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class SnippetCard extends ConsumerStatefulWidget {
  final Snippet snippet;
  final bool isSelected;

  const SnippetCard({super.key, required this.snippet, this.isSelected = false});

  @override
  ConsumerState<SnippetCard> createState() => _SnippetCardState();
}

class _SnippetCardState extends ConsumerState<SnippetCard> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    final mediaPath = widget.snippet.mediaPaths.isNotEmpty ? widget.snippet.mediaPaths.first : null;
    if (mediaPath != null && (mediaPath.endsWith('.mp4') || mediaPath.endsWith('.mov'))) {
      _videoController = VideoPlayerController.file(File(mediaPath))
        ..initialize().then((_) {
          setState(() {}); // Ensure the first frame is shown
          _videoController?.play();
          _videoController?.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaPath = widget.snippet.mediaPaths.isNotEmpty ? widget.snippet.mediaPaths.first : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: widget.isSelected ? 3 : 1,
        ),
      ),
      child: Stack(
        children: [
          SizedBox.expand(
            child: mediaPath != null ? _buildMediaView(mediaPath, theme) : _buildTextView(theme),
          ),
          if (widget.isSelected)
            Container(
              decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.3)),
              child: const Center(child: Icon(Icons.check_circle_outline, color: Colors.white, size: 40)),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaView(String mediaPath, ThemeData theme) {
    final textColor = theme.colorScheme.onSurface.withOpacity(0.9);
    
    Widget mediaWidget;
    if (_videoController != null && _videoController!.value.isInitialized) {
      mediaWidget = Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else if (mediaPath.endsWith('.jpg') || mediaPath.endsWith('.png') || mediaPath.endsWith('.gif')) {
      mediaWidget = Image.file(File(mediaPath), fit: BoxFit.contain);
    } else {
      return _buildTextView(theme); // Fallback
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title above the media
          Container(
            padding: const EdgeInsets.all(12.0),
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              widget.snippet.description,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black, // Background for media to look better when fitting
              child: mediaWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextView(ThemeData theme) {
    final textColor = theme.colorScheme.onSurface.withOpacity(0.9);
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.1),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.snippet.description,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              widget.snippet.fullDescription,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: textColor.withOpacity(0.7)),
              // Removed default maxLines/ellipsis implicit behavior or explicit limitations
              // Using fade to allow it to fill as much as possible without awkward ellipsis if it's tight
              // But standard ellipsis at the end of the container is better.
              // The issue "only one line" usually implies maxLines: 1 was inferred or space was tiny.
              // Setting maxLines to a high number ensures wrapping.
              maxLines: 20, 
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
