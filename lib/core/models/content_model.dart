class ContentModel {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final String url;
  final String? thumbnailUrl;
  final String? authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPremium;
  final List<String> tags;
  final int? duration; // Video için saniye cinsinden
  final String? fileSize; // Dosya boyutu
  final String? mimeType; // MIME type

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.authorId,
    this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.isPremium = false,
    this.tags = const [],
    this.duration,
    this.fileSize,
    this.mimeType,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ContentType.fromString(map['type'] ?? 'document'),
      url: map['url'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      authorId: map['authorId'],
      authorName: map['authorName'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      isPremium: map['isPremium'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      duration: map['duration'],
      fileSize: map['fileSize'],
      mimeType: map['mimeType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isPremium': isPremium,
      'tags': tags,
      'duration': duration,
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    ContentType? type,
    String? url,
    String? thumbnailUrl,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremium,
    List<String>? tags,
    int? duration,
    String? fileSize,
    String? mimeType,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
    );
  }
}

enum ContentType {
  document,
  video,
  audio,
  image,
  pdf,
  text;

  static ContentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'document':
        return ContentType.document;
      case 'video':
        return ContentType.video;
      case 'audio':
        return ContentType.audio;
      case 'image':
        return ContentType.image;
      case 'pdf':
        return ContentType.pdf;
      case 'text':
        return ContentType.text;
      default:
        return ContentType.document;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ContentType.document:
        return 'document';
      case ContentType.video:
        return 'video';
      case ContentType.audio:
        return 'audio';
      case ContentType.image:
        return 'image';
      case ContentType.pdf:
        return 'pdf';
      case ContentType.text:
        return 'text';
    }
  }

  String get displayName {
    switch (this) {
      case ContentType.document:
        return 'Döküman';
      case ContentType.video:
        return 'Video';
      case ContentType.audio:
        return 'Ses';
      case ContentType.image:
        return 'Resim';
      case ContentType.pdf:
        return 'PDF';
      case ContentType.text:
        return 'Metin';
    }
  }

  String get icon {
    switch (this) {
      case ContentType.document:
        return '📄';
      case ContentType.video:
        return '🎥';
      case ContentType.audio:
        return '🎵';
      case ContentType.image:
        return '🖼️';
      case ContentType.pdf:
        return '📕';
      case ContentType.text:
        return '📝';
    }
  }
}
