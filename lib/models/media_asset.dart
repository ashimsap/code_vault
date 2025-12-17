class MediaAsset {
  // The path to the media file.
  final String path;

  // The type of media (e.g., image, gif, video).
  final String type;

  // The content hash of the media file.
  final String contentHash;

  MediaAsset({
    required this.path,
    required this.type,
    required this.contentHash,
  });
}
