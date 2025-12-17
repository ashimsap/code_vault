class Snippet {
  final int? id; // Nullable for new, unsaved snippets
  final String description;
  final String codeContent;
  final List<String> mediaPaths;
  final List<String> categories;
  final DateTime creationDate;
  final DateTime lastModificationDate;
  final String deviceSource;

  Snippet({
    this.id,
    required this.description,
    required this.codeContent,
    required this.mediaPaths,
    required this.categories,
    required this.creationDate,
    required this.lastModificationDate,
    required this.deviceSource,
  });

  // Add JSON conversion methods for database interaction
  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'codeContent': codeContent,
        'mediaPaths': mediaPaths.join(','), // Stored as a comma-separated string
        'categories': categories.join(','), // Stored as a comma-separated string
        'creationDate': creationDate.toIso8601String(),
        'lastModificationDate': lastModificationDate.toIso8601String(),
        'deviceSource': deviceSource,
      };

  static Snippet fromJson(Map<String, dynamic> json) => Snippet(
        id: json['id'] as int?,
        description: json['description'] as String,
        codeContent: json['codeContent'] as String,
        mediaPaths: (json['mediaPaths'] as String).split(','),
        categories: (json['categories'] as String).split(','),
        creationDate: DateTime.parse(json['creationDate'] as String),
        lastModificationDate: DateTime.parse(json['lastModificationDate'] as String),
        deviceSource: json['deviceSource'] as String,
      );
}
