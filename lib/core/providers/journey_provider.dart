import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journey_model.dart';
import '../services/journey_service.dart';

/// Provider for JourneyService
final journeyServiceProvider = Provider<JourneyService>((ref) {
  return JourneyService();
});

/// Provider for current journey progress
final journeyProgressProvider = FutureProvider<JourneyProgress>((ref) async {
  final service = ref.watch(journeyServiceProvider);
  var progress = await service.getJourneyProgress();

  // Initialize if not exists
  if (progress == null) {
    progress = await service.initializeJourneyProgress();
  }

  return progress;
});

/// Provider for journey steps with progress
final journeyStepsProvider = FutureProvider<List<JourneyStep>>((ref) async {
  final service = ref.watch(journeyServiceProvider);
  return service.getJourneyStepsWithProgress();
});

/// Provider for active tasks
final activeTasksProvider = FutureProvider<List<JourneyTask>>((ref) async {
  final service = ref.watch(journeyServiceProvider);
  return service.getActiveTasks();
});

/// Provider for achievements
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final service = ref.watch(journeyServiceProvider);
  return service.getAchievements();
});

/// Provider for weekly progress
final weeklyProgressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(journeyServiceProvider);
  return service.getWeeklyProgress();
});

/// State notifier for journey mutations
class JourneyMutationNotifier extends StateNotifier<AsyncValue<void>> {
  final JourneyService _journeyService;

  JourneyMutationNotifier(this._journeyService) : super(const AsyncValue.data(null));

  Future<void> addXP(int xp, {String? reason}) async {
    state = const AsyncValue.loading();
    try {
      await _journeyService.addXP(xp, reason: reason);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeStep(String stepId) async {
    state = const AsyncValue.loading();
    try {
      await _journeyService.completeStep(stepId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createTask(JourneyTask task) async {
    state = const AsyncValue.loading();
    try {
      await _journeyService.createTask(task);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTaskProgress(String taskId, int completed) async {
    state = const AsyncValue.loading();
    try {
      await _journeyService.updateTaskProgress(taskId, completed);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    state = const AsyncValue.loading();
    try {
      await _journeyService.unlockAchievement(achievementId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final journeyMutationProvider = StateNotifierProvider<JourneyMutationNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(journeyServiceProvider);
  return JourneyMutationNotifier(service);
});
