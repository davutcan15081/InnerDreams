import 'package:flutter/material.dart';
import 'content_model.dart';

class ContentCategory {
  final String id;
  final String name;
  final String description;
  final ContentType defaultType;
  final List<ContentType> allowedTypes;
  final String icon;
  final Color color;

  ContentCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultType,
    required this.allowedTypes,
    required this.icon,
    required this.color,
  });

  factory ContentCategory.fromMap(Map<String, dynamic> map) {
    return ContentCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      defaultType: ContentType.fromString(map['defaultType'] ?? 'document'),
      allowedTypes: (map['allowedTypes'] as List<dynamic>?)
          ?.map((e) => ContentType.fromString(e.toString()))
          .toList() ?? [ContentType.document],
      icon: map['icon'] ?? '📄',
      color: Color(map['color'] ?? 0xFF7C4DFF),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'defaultType': defaultType.toString(),
      'allowedTypes': allowedTypes.map((e) => e.toString()).toList(),
      'icon': icon,
      'color': color.value,
    };
  }
}

class ContentCategoryManager {
  static final List<ContentCategory> _categories = [
    ContentCategory(
      id: 'temel_egitimler',
      name: 'Temel Eğitimler',
      description: 'Rüya tabiri temel bilgileri',
      defaultType: ContentType.document,
      allowedTypes: [ContentType.document, ContentType.pdf, ContentType.text],
      icon: '📚',
      color: Color(0xFF4CAF50),
    ),
    ContentCategory(
      id: 'sembol_egitimleri',
      name: 'Sembol Eğitimleri',
      description: 'Rüya sembolleri ve anlamları',
      defaultType: ContentType.video,
      allowedTypes: [ContentType.video, ContentType.document, ContentType.image],
      icon: '🔮',
      color: Color(0xFF9C27B0),
    ),
    ContentCategory(
      id: 'ruya_psikolojisi',
      name: 'Rüya Psikolojisi',
      description: 'Psikolojik analiz ve yorumlama',
      defaultType: ContentType.video,
      allowedTypes: [ContentType.video, ContentType.audio, ContentType.document],
      icon: '🧠',
      color: Color(0xFF2196F3),
    ),
    ContentCategory(
      id: 'pratik_uygulamalar',
      name: 'Pratik Uygulamalar',
      description: 'Uygulamalı rüya analizi',
      defaultType: ContentType.video,
      allowedTypes: [ContentType.video, ContentType.document],
      icon: '🎯',
      color: Color(0xFFFF9800),
    ),
    ContentCategory(
      id: 'meditasyon',
      name: 'Meditasyon ve Rahatlama',
      description: 'Rüya öncesi hazırlık teknikleri',
      defaultType: ContentType.audio,
      allowedTypes: [ContentType.audio, ContentType.video],
      icon: '🧘',
      color: Color(0xFF00BCD4),
    ),
    ContentCategory(
      id: 'kisisel_gelisim',
      name: 'Kişisel Gelişim',
      description: 'Rüyalar ile kişisel gelişim',
      defaultType: ContentType.document,
      allowedTypes: [ContentType.document, ContentType.video, ContentType.pdf],
      icon: '🌟',
      color: Color(0xFFFFC107),
    ),
  ];

  static List<ContentCategory> getAllCategories() {
    return List.from(_categories);
  }

  static ContentCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ContentType> getAllowedTypesForCategory(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.allowedTypes ?? [ContentType.document];
  }

  static ContentType getDefaultTypeForCategory(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.defaultType ?? ContentType.document;
  }
}
