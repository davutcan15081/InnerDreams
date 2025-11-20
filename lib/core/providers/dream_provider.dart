import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dream_entry_model.dart';
import '../services/dream_service.dart';

/// Provider for DreamService
final dreamServiceProvider = Provider<DreamService>((ref) {
  return DreamService();
});

/// Stream provider for real-time dream entries
final dreamEntriesStreamProvider = StreamProvider<List<DreamEntryModel>>((ref) {
  final service = ref.watch(dreamServiceProvider);
  return service.streamDreamEntries();
});

/// Future provider for all dream entries
final allDreamEntriesProvider = FutureProvider<List<DreamEntryModel>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getAllDreamEntries();
});

/// Future provider for favorite dream entries
final favoriteDreamEntriesProvider = FutureProvider<List<DreamEntryModel>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getFavoriteDreamEntries();
});

/// Future provider for analyzed dream entries
final analyzedDreamEntriesProvider = FutureProvider<List<DreamEntryModel>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getAnalyzedDreamEntries();
});

/// Future provider for dream statistics
final dreamStatisticsProvider = FutureProvider<DreamStatistics>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getDreamStatistics();
});

/// Future provider for this week's dreams
final thisWeekDreamsProvider = FutureProvider<List<DreamEntryModel>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getThisWeekDreams();
});

/// Future provider for this month's dreams
final thisMonthDreamsProvider = FutureProvider<List<DreamEntryModel>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getThisMonthDreams();
});

/// Future provider for most common symbols
final commonSymbolsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getMostCommonSymbols(limit: 10);
});

/// Future provider for emotion distribution
final emotionDistributionProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getEmotionDistribution();
});

/// State notifier for managing dream filter and sort options
class DreamFilterState {
  final String filter; // 'all', 'favorites', 'analyzed'
  final String sortBy; // 'date', 'title', 'emotion'
  final String searchQuery;
  final String? dreamTypeFilter; // 'lucid', 'nightmare', 'normal', etc.
  final DateTime? startDate;
  final DateTime? endDate;

  DreamFilterState({
    this.filter = 'all',
    this.sortBy = 'date',
    this.searchQuery = '',
    this.dreamTypeFilter,
    this.startDate,
    this.endDate,
  });

  DreamFilterState copyWith({
    String? filter,
    String? sortBy,
    String? searchQuery,
    String? dreamTypeFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDreamType = false,
    bool clearDateRange = false,
  }) {
    return DreamFilterState(
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      dreamTypeFilter: clearDreamType ? null : (dreamTypeFilter ?? this.dreamTypeFilter),
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
    );
  }
}

class DreamFilterNotifier extends StateNotifier<DreamFilterState> {
  DreamFilterNotifier() : super(DreamFilterState());

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDreamTypeFilter(String? dreamType) {
    state = state.copyWith(dreamTypeFilter: dreamType, clearDreamType: dreamType == null);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearDateRange: start == null && end == null,
    );
  }

  void clearFilters() {
    state = DreamFilterState();
  }
}

/// Provider for dream filter state
final dreamFilterProvider = StateNotifierProvider<DreamFilterNotifier, DreamFilterState>((ref) {
  return DreamFilterNotifier();
});

/// Provider for filtered and sorted dreams
final filteredDreamsProvider = FutureProvider<List<DreamEntryModel>>((ref) async {
  final service = ref.watch(dreamServiceProvider);
  final filterState = ref.watch(dreamFilterProvider);

  List<DreamEntryModel> dreams;

  // Apply base filter
  if (filterState.filter == 'favorites') {
    dreams = await service.getFavoriteDreamEntries();
  } else if (filterState.filter == 'analyzed') {
    dreams = await service.getAnalyzedDreamEntries();
  } else if (filterState.startDate != null && filterState.endDate != null) {
    dreams = await service.getDreamsInDateRange(filterState.startDate!, filterState.endDate!);
  } else {
    dreams = await service.getAllDreamEntries();
  }

  // Apply search filter
  if (filterState.searchQuery.isNotEmpty) {
    final searchLower = filterState.searchQuery.toLowerCase();
    dreams = dreams.where((dream) {
      return dream.title.toLowerCase().contains(searchLower) ||
             dream.description.toLowerCase().contains(searchLower) ||
             dream.tags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();
  }

  // Apply dream type filter
  if (filterState.dreamTypeFilter != null) {
    dreams = dreams.where((dream) => dream.dreamType == filterState.dreamTypeFilter).toList();
  }

  // Apply sorting
  switch (filterState.sortBy) {
    case 'title':
      dreams.sort((a, b) => a.title.compareTo(b.title));
      break;
    case 'emotion':
      dreams.sort((a, b) {
        final aEmotion = a.emotion ?? '';
        final bEmotion = b.emotion ?? '';
        return aEmotion.compareTo(bEmotion);
      });
      break;
    case 'date':
    default:
      dreams.sort((a, b) => b.date.compareTo(a.date));
      break;
  }

  return dreams;
});

/// Provider for a specific dream entry
final dreamEntryProvider = FutureProvider.family<DreamEntryModel?, String>((ref, dreamId) async {
  final service = ref.watch(dreamServiceProvider);
  return service.getDreamEntry(dreamId);
});

/// Provider for creating/updating dreams
class DreamMutationNotifier extends StateNotifier<AsyncValue<void>> {
  final DreamService _dreamService;

  DreamMutationNotifier(this._dreamService) : super(const AsyncValue.data(null));

  Future<void> createDream(DreamEntryModel dream) async {
    state = const AsyncValue.loading();
    try {
      await _dreamService.createDreamEntry(dream);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateDream(DreamEntryModel dream) async {
    state = const AsyncValue.loading();
    try {
      await _dreamService.updateDreamEntry(dream);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteDream(String dreamId) async {
    state = const AsyncValue.loading();
    try {
      await _dreamService.deleteDreamEntry(dreamId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleFavorite(String dreamId, bool isFavorite) async {
    state = const AsyncValue.loading();
    try {
      await _dreamService.toggleFavorite(dreamId, isFavorite);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addInterpretation(String dreamId, String interpretation, Map<String, dynamic>? analysisData) async {
    state = const AsyncValue.loading();
    try {
      await _dreamService.addAIInterpretation(dreamId, interpretation, analysisData);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final dreamMutationProvider = StateNotifierProvider<DreamMutationNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(dreamServiceProvider);
  return DreamMutationNotifier(service);
});
