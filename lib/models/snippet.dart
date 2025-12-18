import 'package:path/path.dart' as p;

class Snippet {
  final int? id;
  final String description;
  final String fullDescription;
  final String codeContent;
  final List<String> mediaPaths;
  final List<String> categories;
  final DateTime creationDate;
  final DateTime lastModificationDate;
  final String deviceSource;

  String? get firstMediaUrl => mediaPaths.isNotEmpty ? '/media/${p.basename(mediaPaths.first)}' : null;

  Snippet({
    this.id,
    required this.description,
    this.fullDescription = '',
    required this.codeContent,
    required this.mediaPaths,
    required this.categories,
    required this.creationDate,
    required this.lastModificationDate,
    required this.deviceSource,
  });

  Snippet copyWith({
    int? id, String? description, String? fullDescription, String? codeContent,
    List<String>? mediaPaths, List<String>? categories, DateTime? creationDate,
    DateTime? lastModificationDate, String? deviceSource,
  }) {
    return Snippet(
      id: id ?? this.id,
      description: description ?? this.description,
      fullDescription: fullDescription ?? this.fullDescription,
      codeContent: codeContent ?? this.codeContent,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      categories: categories ?? this.categories,
      creationDate: creationDate ?? this.creationDate,
      lastModificationDate: lastModificationDate ?? this.lastModificationDate,
      deviceSource: deviceSource ?? this.deviceSource,
    );
  }

  Map<String, dynamic> toApiJson() => {
        'id': id,
        'description': description,
        'fullDescription': fullDescription,
        'codeContent': codeContent,
        'mediaPaths': mediaPaths,
        'firstMediaUrl': firstMediaUrl,
        'categories': categories,
        'creationDate': creationDate.toIso8601String(),
        'lastModificationDate': lastModificationDate.toIso8601String(),
        'deviceSource': deviceSource,
      };

  Map<String, dynamic> toDbJson() => {
        'id': id,
        'description': description,
        'fullDescription': fullDescription,
        'codeContent': codeContent,
        'mediaPaths': mediaPaths.join(','),
        'categories': categories.join(','),
        'creationDate': creationDate.toIso8601String(),
        'lastModificationDate': lastModificationDate.toIso8601String(),
        'deviceSource': deviceSource,
      };

  static Snippet fromJson(Map<String, dynamic> json) {
    var mediaPathsFromJson = json['mediaPaths'];
    List<String> mediaPaths = [];
    if (mediaPathsFromJson is String) {
      mediaPaths = mediaPathsFromJson.split(',').where((s) => s.isNotEmpty).toList();
    } else if (mediaPathsFromJson is List) {
      mediaPaths = List<String>.from(mediaPathsFromJson);
    }

    return Snippet(
        id: json['id'] as int?,
        description: json['description'] as String,
        fullDescription: json['fullDescription'] as String? ?? '',
        codeContent: json['codeContent'] as String,
        mediaPaths: mediaPaths,
        categories: (json['categories'] as String? ?? '').split(',').where((s) => s.isNotEmpty).toList(),
        creationDate: DateTime.parse(json['creationDate'] as String),
        lastModificationDate: DateTime.parse(json['lastModificationDate'] as String),
        deviceSource: json['deviceSource'] as String,
      );
  }
}
