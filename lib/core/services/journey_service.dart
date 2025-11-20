import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/journey_model.dart';
import 'dart:math';

/// Service for managing user's inner journey progress
class JourneyService {
  static final JourneyService _instance = JourneyService._internal();
  factory JourneyService() => _instance;
  JourneyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Get reference to user's journey progress document
  DocumentReference? get _journeyProgressRef {
    if (_currentUserId == null) return null;
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('journey')
        .doc('progress');
  }

  /// Get all predefined journey steps
  List<JourneyStep> getAllJourneySteps() {
    return [
      JourneyStep(
        id: 'awareness',
        title: 'Farkındalık',
        subtitle: 'İç dünyanı keşfetmeye başla',
        description: 'Rüyalarınızı kaydetmeye başlayın ve iç dünyanızı keşfedin. Bu aşamada farkındalığınızı geliştirin.',
        icon: Icons.visibility,
        color: Colors.green,
        order: 0,
        requiredLevel: 1,
        xpReward: 100,
        tasks: ['record_first_dream', 'analyze_emotion', 'identify_symbol'],
        position: const Offset(200, 50),
      ),
      JourneyStep(
        id: 'discovery',
        title: 'Keşif',
        subtitle: 'Sembollerinizi öğrenin',
        description: 'Rüyalarınızdaki sembolleri tanımaya ve anlamlarını öğrenmeye başlayın.',
        icon: Icons.explore,
        color: Colors.blue,
        order: 1,
        requiredLevel: 2,
        xpReward: 150,
        tasks: ['learn_5_symbols', 'record_10_dreams', 'create_dream_journal'],
        position: const Offset(300, 120),
      ),
      JourneyStep(
        id: 'transformation',
        title: 'Dönüşüm',
        subtitle: 'İç gücünüzü keşfedin',
        description: 'Rüyalarınızdaki mesajları anlayın ve içsel dönüşümünüzü başlatın.',
        icon: Icons.transform,
        color: const Color(0xFF7C4DFF),
        order: 2,
        requiredLevel: 3,
        xpReward: 200,
        tasks: ['interpret_dreams', 'identify_patterns', 'practice_lucid_dreaming'],
        position: const Offset(250, 200),
      ),
      JourneyStep(
        id: 'integration',
        title: 'Entegrasyon',
        subtitle: 'Bilgeliği hayata geçirin',
        description: 'Rüya yorumlarınızı günlük yaşamınıza entegre edin.',
        icon: Icons.integration_instructions,
        color: Colors.orange,
        order: 3,
        requiredLevel: 5,
        xpReward: 250,
        tasks: ['apply_insights', 'set_intentions', 'track_progress'],
        position: const Offset(150, 280),
      ),
      JourneyStep(
        id: 'wisdom',
        title: 'Bilgelik',
        subtitle: 'İç bilgeliğe ulaşın',
        description: 'Rüya dünyası ve gerçek dünya arasında köprü kurun, bilgeliğe ulaşın.',
        icon: Icons.psychology,
        color: Colors.purple,
        order: 4,
        requiredLevel: 10,
        xpReward: 500,
        tasks: ['master_lucid_dreaming', 'guide_others', 'achieve_enlightenment'],
        position: const Offset(80, 200),
      ),
    ];
  }

  /// Initialize user's journey progress
  Future<JourneyProgress> initializeJourneyProgress() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final existingProgress = await getJourneyProgress();
      if (existingProgress != null) {
        return existingProgress;
      }

      final newProgress = JourneyProgress(
        userId: _currentUserId!,
        currentLevel: 1,
        currentXP: 0,
        xpForNextLevel: 100,
        currentStepId: 'awareness',
        completedSteps: [],
        unlockedSteps: ['awareness'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _journeyProgressRef?.set(newProgress.toJson());
      _logger.i('✅ Journey progress initialized');

      return newProgress;
    } catch (e) {
      _logger.e('❌ Error initializing journey progress: $e');
      rethrow;
    }
  }

  /// Get user's current journey progress
  Future<JourneyProgress?> getJourneyProgress() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _journeyProgressRef?.get();

      if (doc == null || !doc.exists) {
        return null;
      }

      return JourneyProgress.fromFirestore(doc);
    } catch (e) {
      _logger.e('❌ Error getting journey progress: $e');
      rethrow;
    }
  }

  /// Add XP to user's journey progress
  Future<void> addXP(int xp, {String? reason}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final progress = await getJourneyProgress();
      if (progress == null) {
        await initializeJourneyProgress();
        return addXP(xp, reason: reason);
      }

      int newXP = progress.currentXP + xp;
      int newLevel = progress.currentLevel;
      int xpForNextLevel = progress.xpForNextLevel;

      // Check for level up
      while (newXP >= xpForNextLevel) {
        newXP -= xpForNextLevel;
        newLevel++;
        xpForNextLevel = _calculateXPForLevel(newLevel + 1);

        _logger.i('🎉 Level up! New level: $newLevel');
      }

      final updatedProgress = progress.copyWith(
        currentLevel: newLevel,
        currentXP: newXP,
        xpForNextLevel: xpForNextLevel,
        updatedAt: DateTime.now(),
      );

      await _journeyProgressRef?.update(updatedProgress.toJson());

      _logger.i('✅ Added $xp XP${reason != null ? ' for $reason' : ''}');
    } catch (e) {
      _logger.e('❌ Error adding XP: $e');
      rethrow;
    }
  }

  /// Calculate XP required for a specific level
  int _calculateXPForLevel(int level) {
    return (100 * pow(1.5, level - 1)).round();
  }

  /// Complete a journey step
  Future<void> completeStep(String stepId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final progress = await getJourneyProgress();
      if (progress == null) {
        throw Exception('Journey progress not found');
      }

      // Find the step
      final step = getAllJourneySteps().firstWhere((s) => s.id == stepId);

      // Check if already completed
      if (progress.completedSteps.contains(stepId)) {
        _logger.w('⚠️ Step already completed: $stepId');
        return;
      }

      // Add to completed steps
      final completedSteps = [...progress.completedSteps, stepId];

      // Unlock next step
      final allSteps = getAllJourneySteps();
      final currentStepIndex = allSteps.indexWhere((s) => s.id == stepId);
      final unlockedSteps = List<String>.from(progress.unlockedSteps);

      if (currentStepIndex < allSteps.length - 1) {
        final nextStep = allSteps[currentStepIndex + 1];
        if (!unlockedSteps.contains(nextStep.id)) {
          unlockedSteps.add(nextStep.id);
        }
      }

      // Determine current step (next uncompleted step)
      String currentStepId = progress.currentStepId;
      for (final s in allSteps) {
        if (!completedSteps.contains(s.id)) {
          currentStepId = s.id;
          break;
        }
      }

      final updatedProgress = progress.copyWith(
        completedSteps: completedSteps,
        unlockedSteps: unlockedSteps,
        currentStepId: currentStepId,
        updatedAt: DateTime.now(),
      );

      await _journeyProgressRef?.update(updatedProgress.toJson());

      // Award XP
      await addXP(step.xpReward, reason: 'Completed step: ${step.title}');

      _logger.i('✅ Completed step: $stepId');
    } catch (e) {
      _logger.e('❌ Error completing step: $e');
      rethrow;
    }
  }

  /// Get journey steps with current progress
  Future<List<JourneyStep>> getJourneyStepsWithProgress() async {
    try {
      final progress = await getJourneyProgress();
      if (progress == null) {
        await initializeJourneyProgress();
        return getJourneyStepsWithProgress();
      }

      final allSteps = getAllJourneySteps();

      return allSteps.map((step) {
        final isCompleted = progress.completedSteps.contains(step.id);
        final isCurrent = progress.currentStepId == step.id;
        final isLocked = !progress.unlockedSteps.contains(step.id);

        return step.copyWith(
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLocked: isLocked,
          completedAt: isCompleted ? DateTime.now() : null, // Would be stored in DB
        );
      }).toList();
    } catch (e) {
      _logger.e('❌ Error getting journey steps with progress: $e');
      rethrow;
    }
  }

  /// Get active tasks for current journey step
  Future<List<JourneyTask>> getActiveTasks() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('journey')
          .doc('progress')
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .orderBy('createdAt', descending: false)
          .get();

      final tasks = snapshot.docs
          .map((doc) => JourneyTask.fromFirestore(doc))
          .toList();

      _logger.i('✅ Loaded ${tasks.length} active tasks');
      return tasks;
    } catch (e) {
      _logger.e('❌ Error getting active tasks: $e');
      rethrow;
    }
  }

  /// Create a new journey task
  Future<JourneyTask> createTask(JourneyTask task) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('journey')
          .doc('progress')
          .collection('tasks')
          .add(task.toJson());

      _logger.i('✅ Created task: ${task.title}');

      return task.copyWith(id: docRef.id);
    } catch (e) {
      _logger.e('❌ Error creating task: $e');
      rethrow;
    }
  }

  /// Update task progress
  Future<void> updateTaskProgress(String taskId, int completed) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final taskRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('journey')
          .doc('progress')
          .collection('tasks')
          .doc(taskId);

      final taskDoc = await taskRef.get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final task = JourneyTask.fromFirestore(taskDoc);
      final isNowCompleted = completed >= task.total;

      await taskRef.update({
        'completed': completed,
        'isCompleted': isNowCompleted,
        'completedAt': isNowCompleted ? Timestamp.now() : null,
      });

      // Award XP if task is completed
      if (isNowCompleted && !task.isCompleted) {
        await addXP(task.xpReward, reason: 'Completed task: ${task.title}');
      }

      _logger.i('✅ Updated task progress: $taskId');
    } catch (e) {
      _logger.e('❌ Error updating task progress: $e');
      rethrow;
    }
  }

  /// Get achievements
  Future<List<Achievement>> getAchievements() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('achievements')
          .get();

      final achievements = snapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();

      // Add predefined achievements if not present
      final predefinedAchievements = _getPredefinedAchievements();

      for (final predefined in predefinedAchievements) {
        if (!achievements.any((a) => a.id == predefined.id)) {
          achievements.add(predefined);
        }
      }

      _logger.i('✅ Loaded ${achievements.length} achievements');
      return achievements;
    } catch (e) {
      _logger.e('❌ Error getting achievements: $e');
      rethrow;
    }
  }

  List<Achievement> _getPredefinedAchievements() {
    return [
      Achievement(
        id: 'first_dream',
        title: 'İlk Rüya',
        description: 'İlk rüyanı kaydettiniz',
        icon: Icons.nights_stay,
        color: Colors.blue,
        xpReward: 50,
      ),
      Achievement(
        id: 'symbol_master',
        title: 'Sembol Ustası',
        description: '10 farklı sembolü öğrendiniz',
        icon: Icons.star,
        color: Colors.orange,
        xpReward: 100,
      ),
      Achievement(
        id: 'meditator',
        title: 'Meditasyon Ustası',
        description: '7 gün üst üste meditasyon yaptınız',
        icon: Icons.self_improvement,
        color: Colors.purple,
        xpReward: 150,
      ),
      Achievement(
        id: 'dream_keeper',
        title: 'Rüya Koruyucusu',
        description: '30 gün üst üste rüya kaydettiniz',
        icon: Icons.shield,
        color: Colors.green,
        xpReward: 200,
      ),
      Achievement(
        id: 'lucid_dreamer',
        title: 'Lucid Rüya Görücü',
        description: 'İlk lucid rüyanızı gördünüz',
        icon: Icons.lightbulb,
        color: Colors.yellow,
        xpReward: 250,
      ),
    ];
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String achievementId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final achievementRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('achievements')
          .doc(achievementId);

      final achievementDoc = await achievementRef.get();

      if (achievementDoc.exists) {
        final achievement = Achievement.fromFirestore(achievementDoc);
        if (achievement.isUnlocked) {
          _logger.w('⚠️ Achievement already unlocked: $achievementId');
          return;
        }
      }

      // Find predefined achievement
      final predefined = _getPredefinedAchievements()
          .firstWhere((a) => a.id == achievementId);

      await achievementRef.set({
        'id': achievementId,
        'title': predefined.title,
        'description': predefined.description,
        'isUnlocked': true,
        'unlockedAt': Timestamp.now(),
        'xpReward': predefined.xpReward,
      });

      // Award XP
      await addXP(predefined.xpReward, reason: 'Unlocked achievement: ${predefined.title}');

      _logger.i('🏆 Unlocked achievement: $achievementId');
    } catch (e) {
      _logger.e('❌ Error unlocking achievement: $e');
      rethrow;
    }
  }

  /// Check and auto-unlock achievements based on user's activity
  Future<void> checkAndUnlockAchievements() async {
    try {
      // This would check various conditions and unlock achievements
      // For example:
      // - Check if user has recorded first dream
      // - Check if user has learned 10 symbols
      // - Check if user has 7-day meditation streak
      // etc.

      _logger.i('✅ Checked achievements');
    } catch (e) {
      _logger.e('❌ Error checking achievements: $e');
      rethrow;
    }
  }

  /// Get weekly progress statistics
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    try {
      // Calculate weekly stats
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      // This would aggregate data from dreams, tasks, etc.
      return {
        'dreamsRecorded': 5, // Would be calculated
        'tasksCompleted': 3,
        'xpEarned': 150,
        'progressPercentage': 0.75,
      };
    } catch (e) {
      _logger.e('❌ Error getting weekly progress: $e');
      rethrow;
    }
  }
}
