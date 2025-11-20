import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Journey Step/Stage Model
class JourneyStep {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final int order;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final int requiredLevel;
  final int xpReward;
  final List<String> tasks;
  final Offset position; // Position on the map
  final DateTime? completedAt;

  const JourneyStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.order,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLocked = false,
    required this.requiredLevel,
    required this.xpReward,
    this.tasks = const [],
    required this.position,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'order': order,
      'isCompleted': isCompleted,
      'isCurrent': isCurrent,
      'isLocked': isLocked,
      'requiredLevel': requiredLevel,
      'xpReward': xpReward,
      'tasks': tasks,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory JourneyStep.fromJson(Map<String, dynamic> json) {
    return JourneyStep(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      icon: Icons.explore, // Will be set from predefined list
      color: Colors.purple, // Will be set from predefined list
      order: json['order'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
      isLocked: json['isLocked'] ?? false,
      requiredLevel: json['requiredLevel'] ?? 1,
      xpReward: json['xpReward'] ?? 0,
      tasks: List<String>.from(json['tasks'] ?? []),
      position: Offset(100, 100), // Will be calculated
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  JourneyStep copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    IconData? icon,
    Color? color,
    int? order,
    bool? isCompleted,
    bool? isCurrent,
    bool? isLocked,
    int? requiredLevel,
    int? xpReward,
    List<String>? tasks,
    Offset? position,
    DateTime? completedAt,
  }) {
    return JourneyStep(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
      isLocked: isLocked ?? this.isLocked,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      xpReward: xpReward ?? this.xpReward,
      tasks: tasks ?? this.tasks,
      position: position ?? this.position,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Journey Progress Model
class JourneyProgress {
  final String userId;
  final int currentLevel;
  final int currentXP;
  final int xpForNextLevel;
  final String currentStepId;
  final List<String> completedSteps;
  final List<String> unlockedSteps;
  final DateTime createdAt;
  final DateTime updatedAt;

  JourneyProgress({
    required this.userId,
    required this.currentLevel,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.currentStepId,
    this.completedSteps = const [],
    this.unlockedSteps = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage => currentXP / xpForNextLevel;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentLevel': currentLevel,
      'currentXP': currentXP,
      'xpForNextLevel': xpForNextLevel,
      'currentStepId': currentStepId,
      'completedSteps': completedSteps,
      'unlockedSteps': unlockedSteps,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory JourneyProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JourneyProgress(
      userId: data['userId'] ?? '',
      currentLevel: data['currentLevel'] ?? 1,
      currentXP: data['currentXP'] ?? 0,
      xpForNextLevel: data['xpForNextLevel'] ?? 100,
      currentStepId: data['currentStepId'] ?? 'awareness',
      completedSteps: List<String>.from(data['completedSteps'] ?? []),
      unlockedSteps: List<String>.from(data['unlockedSteps'] ?? ['awareness']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  JourneyProgress copyWith({
    String? userId,
    int? currentLevel,
    int? currentXP,
    int? xpForNextLevel,
    String? currentStepId,
    List<String>? completedSteps,
    List<String>? unlockedSteps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JourneyProgress(
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXP: currentXP ?? this.currentXP,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      currentStepId: currentStepId ?? this.currentStepId,
      completedSteps: completedSteps ?? this.completedSteps,
      unlockedSteps: unlockedSteps ?? this.unlockedSteps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Journey Task Model
class JourneyTask {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int completed;
  final int total;
  final bool isCompleted;
  final int xpReward;
  final DateTime? completedAt;
  final DateTime createdAt;

  JourneyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.completed,
    required this.total,
    this.isCompleted = false,
    required this.xpReward,
    this.completedAt,
    required this.createdAt,
  });

  double get progressPercentage => total > 0 ? completed / total : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'total': total,
      'isCompleted': isCompleted,
      'xpReward': xpReward,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory JourneyTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JourneyTask(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: Icons.task_alt,
      completed: data['completed'] ?? 0,
      total: data['total'] ?? 1,
      isCompleted: data['isCompleted'] ?? false,
      xpReward: data['xpReward'] ?? 10,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  JourneyTask copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? completed,
    int? total,
    bool? isCompleted,
    int? xpReward,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return JourneyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      isCompleted: isCompleted ?? this.isCompleted,
      xpReward: xpReward ?? this.xpReward,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.xpReward,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'xpReward': xpReward,
    };
  }

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Achievement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: Icons.emoji_events,
      color: Colors.orange,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
      xpReward: data['xpReward'] ?? 50,
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? xpReward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
    );
  }
}
