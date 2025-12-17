class Snippet {
  // Code content: The text of the Flutter snippet.
  final String codeContent;

  // Media content: Images, GIFs, or short videos demonstrating what the snippet does.
  final List<String> mediaPaths;

  // Tags/Categories: For organizing snippets into groups or tabs.
  final List<String> categories;

  // Metadata: Creation date, last modification, device source, and associated media paths.
  final DateTime creationDate;
  final DateTime lastModificationDate;
  final String deviceSource;

  Snippet({
    required this.codeContent,
    required this.mediaPaths,
    required this.categories,
    required this.creationDate,
    required this.lastModificationDate,
    required this.deviceSource,
  });
}
