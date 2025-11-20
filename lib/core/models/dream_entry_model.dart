import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for dream entries
class DreamEntryModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Dream details
  final String? dreamType; // lucid, nightmare, normal, recurring
  final String? emotion; // peace, fear, curiosity, happiness, sadness, etc.
  final List<String> tags;
  final List<String> symbols;

  // Analysis
  final bool isAnalyzed;
  final String? aiInterpretation;
  final Map<String, dynamic>? analysisData;

  // User preferences
  final bool isFavorite;
  final int? sleepQuality; // 1-10
  final String? notes;

  // Media
  final List<String>? imageUrls;
  final String? audioUrl;

  DreamEntryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.createdAt,
    this.updatedAt,
    this.dreamType,
    this.emotion,
    this.tags = const [],
    this.symbols = const [],
    this.isAnalyzed = false,
    this.aiInterpretation,
    this.analysisData,
    this.isFavorite = false,
    this.sleepQuality,
    this.notes,
    this.imageUrls,
    this.audioUrl,
  });

  /// Convert DreamEntryModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'dreamType': dreamType,
      'emotion': emotion,
      'tags': tags,
      'symbols': symbols,
      'isAnalyzed': isAnalyzed,
      'aiInterpretation': aiInterpretation,
      'analysisData': analysisData,
      'isFavorite': isFavorite,
      'sleepQuality': sleepQuality,
      'notes': notes,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
    };
  }

  /// Create DreamEntryModel from Firestore document
  factory DreamEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DreamEntryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      dreamType: data['dreamType'],
      emotion: data['emotion'],
      tags: List<String>.from(data['tags'] ?? []),
      symbols: List<String>.from(data['symbols'] ?? []),
      isAnalyzed: data['isAnalyzed'] ?? false,
      aiInterpretation: data['aiInterpretation'],
      analysisData: data['analysisData'],
      isFavorite: data['isFavorite'] ?? false,
      sleepQuality: data['sleepQuality'],
      notes: data['notes'],
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      audioUrl: data['audioUrl'],
    );
  }

  /// Create DreamEntryModel from JSON
  factory DreamEntryModel.fromJson(Map<String, dynamic> json, String id) {
    return DreamEntryModel(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
          : null,
      dreamType: json['dreamType'],
      emotion: json['emotion'],
      tags: List<String>.from(json['tags'] ?? []),
      symbols: List<String>.from(json['symbols'] ?? []),
      isAnalyzed: json['isAnalyzed'] ?? false,
      aiInterpretation: json['aiInterpretation'],
      analysisData: json['analysisData'],
      isFavorite: json['isFavorite'] ?? false,
      sleepQuality: json['sleepQuality'],
      notes: json['notes'],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      audioUrl: json['audioUrl'],
    );
  }

  /// Copy with method for updating fields
  DreamEntryModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dreamType,
    String? emotion,
    List<String>? tags,
    List<String>? symbols,
    bool? isAnalyzed,
    String? aiInterpretation,
    Map<String, dynamic>? analysisData,
    bool? isFavorite,
    int? sleepQuality,
    String? notes,
    List<String>? imageUrls,
    String? audioUrl,
  }) {
    return DreamEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dreamType: dreamType ?? this.dreamType,
      emotion: emotion ?? this.emotion,
      tags: tags ?? this.tags,
      symbols: symbols ?? this.symbols,
      isAnalyzed: isAnalyzed ?? this.isAnalyzed,
      aiInterpretation: aiInterpretation ?? this.aiInterpretation,
      analysisData: analysisData ?? this.analysisData,
      isFavorite: isFavorite ?? this.isFavorite,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}

/// Statistics model for dream analytics
class DreamStatistics {
  final int totalDreams;
  final int analyzedDreams;
  final int favoriteDreams;
  final int lucidDreams;
  final int nightmares;
  final Map<String, int> emotionCounts;
  final Map<String, int> symbolCounts;
  final double averageSleepQuality;
  final int dreamRecallRate; // Percentage

  DreamStatistics({
    required this.totalDreams,
    required this.analyzedDreams,
    required this.favoriteDreams,
    required this.lucidDreams,
    required this.nightmares,
    required this.emotionCounts,
    required this.symbolCounts,
    required this.averageSleepQuality,
    required this.dreamRecallRate,
  });

  factory DreamStatistics.empty() {
    return DreamStatistics(
      totalDreams: 0,
      analyzedDreams: 0,
      favoriteDreams: 0,
      lucidDreams: 0,
      nightmares: 0,
      emotionCounts: {},
      symbolCounts: {},
      averageSleepQuality: 0.0,
      dreamRecallRate: 0,
    );
  }

  factory DreamStatistics.fromDreams(List<DreamEntryModel> dreams) {
    final emotionCounts = <String, int>{};
    final symbolCounts = <String, int>{};
    double totalSleepQuality = 0;
    int sleepQualityCount = 0;

    for (final dream in dreams) {
      // Count emotions
      if (dream.emotion != null) {
        emotionCounts[dream.emotion!] = (emotionCounts[dream.emotion!] ?? 0) + 1;
      }

      // Count symbols
      for (final symbol in dream.symbols) {
        symbolCounts[symbol] = (symbolCounts[symbol] ?? 0) + 1;
      }

      // Calculate average sleep quality
      if (dream.sleepQuality != null) {
        totalSleepQuality += dream.sleepQuality!;
        sleepQualityCount++;
      }
    }

    final lucidCount = dreams.where((d) => d.dreamType?.toLowerCase() == 'lucid').length;
    final nightmareCount = dreams.where((d) => d.dreamType?.toLowerCase() == 'nightmare' || d.dreamType?.toLowerCase() == 'kabus').length;

    return DreamStatistics(
      totalDreams: dreams.length,
      analyzedDreams: dreams.where((d) => d.isAnalyzed).length,
      favoriteDreams: dreams.where((d) => d.isFavorite).length,
      lucidDreams: lucidCount,
      nightmares: nightmareCount,
      emotionCounts: emotionCounts,
      symbolCounts: symbolCounts,
      averageSleepQuality: sleepQualityCount > 0 ? totalSleepQuality / sleepQualityCount : 0.0,
      dreamRecallRate: dreams.isEmpty ? 0 : ((dreams.length / 30) * 100).toInt().clamp(0, 100), // Simple calculation
    );
  }
}
