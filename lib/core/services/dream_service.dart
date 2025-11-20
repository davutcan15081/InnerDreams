import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/dream_entry_model.dart';

/// Service for managing dream entries in Firestore
class DreamService {
  static final DreamService _instance = DreamService._internal();
  factory DreamService() => _instance;
  DreamService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  /// Collection name for dream entries
  static const String _collectionName = 'dream_entries';

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Get reference to user's dream entries collection
  CollectionReference get _dreamEntriesCollection {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection(_collectionName);
  }

  /// Create a new dream entry
  Future<DreamEntryModel> createDreamEntry(DreamEntryModel dream) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await _dreamEntriesCollection.add(dream.toJson());
      final createdDream = dream.copyWith(id: docRef.id);

      _logger.i('✅ Dream entry created: ${docRef.id}');
      return createdDream;
    } catch (e) {
      _logger.e('❌ Error creating dream entry: $e');
      rethrow;
    }
  }

  /// Update an existing dream entry
  Future<void> updateDreamEntry(DreamEntryModel dream) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final updatedDream = dream.copyWith(updatedAt: DateTime.now());
      await _dreamEntriesCollection.doc(dream.id).update(updatedDream.toJson());

      _logger.i('✅ Dream entry updated: ${dream.id}');
    } catch (e) {
      _logger.e('❌ Error updating dream entry: $e');
      rethrow;
    }
  }

  /// Delete a dream entry
  Future<void> deleteDreamEntry(String dreamId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _dreamEntriesCollection.doc(dreamId).delete();
      _logger.i('✅ Dream entry deleted: $dreamId');
    } catch (e) {
      _logger.e('❌ Error deleting dream entry: $e');
      rethrow;
    }
  }

  /// Get a single dream entry by ID
  Future<DreamEntryModel?> getDreamEntry(String dreamId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _dreamEntriesCollection.doc(dreamId).get();

      if (!doc.exists) {
        _logger.w('⚠️ Dream entry not found: $dreamId');
        return null;
      }

      return DreamEntryModel.fromFirestore(doc);
    } catch (e) {
      _logger.e('❌ Error getting dream entry: $e');
      rethrow;
    }
  }

  /// Get all dream entries for the current user
  Future<List<DreamEntryModel>> getAllDreamEntries({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _dreamEntriesCollection.orderBy('date', descending: true);

      // Apply date filters if provided
      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final dreams = snapshot.docs
          .map((doc) => DreamEntryModel.fromFirestore(doc))
          .toList();

      _logger.i('✅ Loaded ${dreams.length} dream entries');
      return dreams;
    } catch (e) {
      _logger.e('❌ Error getting dream entries: $e');
      rethrow;
    }
  }

  /// Get dream entries filtered by dream type
  Future<List<DreamEntryModel>> getDreamEntriesByType(String dreamType) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _dreamEntriesCollection
          .where('dreamType', isEqualTo: dreamType)
          .orderBy('date', descending: true)
          .get();

      final dreams = snapshot.docs
          .map((doc) => DreamEntryModel.fromFirestore(doc))
          .toList();

      _logger.i('✅ Loaded ${dreams.length} dream entries of type: $dreamType');
      return dreams;
    } catch (e) {
      _logger.e('❌ Error getting dream entries by type: $e');
      rethrow;
    }
  }

  /// Get favorite dream entries
  Future<List<DreamEntryModel>> getFavoriteDreamEntries() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _dreamEntriesCollection
          .where('isFavorite', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      final dreams = snapshot.docs
          .map((doc) => DreamEntryModel.fromFirestore(doc))
          .toList();

      _logger.i('✅ Loaded ${dreams.length} favorite dream entries');
      return dreams;
    } catch (e) {
      _logger.e('❌ Error getting favorite dream entries: $e');
      rethrow;
    }
  }

  /// Get analyzed dream entries
  Future<List<DreamEntryModel>> getAnalyzedDreamEntries() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _dreamEntriesCollection
          .where('isAnalyzed', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      final dreams = snapshot.docs
          .map((doc) => DreamEntryModel.fromFirestore(doc))
          .toList();

      _logger.i('✅ Loaded ${dreams.length} analyzed dream entries');
      return dreams;
    } catch (e) {
      _logger.e('❌ Error getting analyzed dream entries: $e');
      rethrow;
    }
  }

  /// Search dream entries by text
  Future<List<DreamEntryModel>> searchDreamEntries(String searchQuery) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get all dreams (Firestore doesn't support full-text search natively)
      final allDreams = await getAllDreamEntries();

      // Filter locally
      final searchLower = searchQuery.toLowerCase();
      final filteredDreams = allDreams.where((dream) {
        return dream.title.toLowerCase().contains(searchLower) ||
               dream.description.toLowerCase().contains(searchLower) ||
               dream.tags.any((tag) => tag.toLowerCase().contains(searchLower)) ||
               (dream.notes?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      _logger.i('✅ Found ${filteredDreams.length} dreams matching: "$searchQuery"');
      return filteredDreams;
    } catch (e) {
      _logger.e('❌ Error searching dream entries: $e');
      rethrow;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String dreamId, bool isFavorite) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _dreamEntriesCollection.doc(dreamId).update({
        'isFavorite': isFavorite,
        'updatedAt': Timestamp.now(),
      });

      _logger.i('✅ Toggled favorite for dream: $dreamId');
    } catch (e) {
      _logger.e('❌ Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Add AI interpretation to dream
  Future<void> addAIInterpretation(String dreamId, String interpretation, Map<String, dynamic>? analysisData) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _dreamEntriesCollection.doc(dreamId).update({
        'aiInterpretation': interpretation,
        'analysisData': analysisData,
        'isAnalyzed': true,
        'updatedAt': Timestamp.now(),
      });

      _logger.i('✅ Added AI interpretation for dream: $dreamId');
    } catch (e) {
      _logger.e('❌ Error adding AI interpretation: $e');
      rethrow;
    }
  }

  /// Get dream statistics
  Future<DreamStatistics> getDreamStatistics() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final dreams = await getAllDreamEntries();
      final statistics = DreamStatistics.fromDreams(dreams);

      _logger.i('✅ Generated dream statistics');
      return statistics;
    } catch (e) {
      _logger.e('❌ Error getting dream statistics: $e');
      rethrow;
    }
  }

  /// Get dreams for a specific date range (for filtering)
  Future<List<DreamEntryModel>> getDreamsInDateRange(DateTime start, DateTime end) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _dreamEntriesCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      final dreams = snapshot.docs
          .map((doc) => DreamEntryModel.fromFirestore(doc))
          .toList();

      _logger.i('✅ Loaded ${dreams.length} dreams from ${start.toString()} to ${end.toString()}');
      return dreams;
    } catch (e) {
      _logger.e('❌ Error getting dreams in date range: $e');
      rethrow;
    }
  }

  /// Get dreams from this week
  Future<List<DreamEntryModel>> getThisWeekDreams() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getDreamsInDateRange(startDate, endDate);
  }

  /// Get dreams from this month
  Future<List<DreamEntryModel>> getThisMonthDreams() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getDreamsInDateRange(startDate, endDate);
  }

  /// Stream of dream entries (real-time updates)
  Stream<List<DreamEntryModel>> streamDreamEntries() {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _dreamEntriesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DreamEntryModel.fromFirestore(doc))
            .toList());
  }

  /// Get most common symbols across all dreams
  Future<Map<String, int>> getMostCommonSymbols({int limit = 10}) async {
    try {
      final dreams = await getAllDreamEntries();
      final symbolCounts = <String, int>{};

      for (final dream in dreams) {
        for (final symbol in dream.symbols) {
          symbolCounts[symbol] = (symbolCounts[symbol] ?? 0) + 1;
        }
      }

      // Sort by frequency and take top N
      final sortedSymbols = symbolCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topSymbols = Map.fromEntries(
        sortedSymbols.take(limit),
      );

      return topSymbols;
    } catch (e) {
      _logger.e('❌ Error getting common symbols: $e');
      rethrow;
    }
  }

  /// Get emotion distribution
  Future<Map<String, int>> getEmotionDistribution() async {
    try {
      final dreams = await getAllDreamEntries();
      final emotionCounts = <String, int>{};

      for (final dream in dreams) {
        if (dream.emotion != null) {
          emotionCounts[dream.emotion!] = (emotionCounts[dream.emotion!] ?? 0) + 1;
        }
      }

      return emotionCounts;
    } catch (e) {
      _logger.e('❌ Error getting emotion distribution: $e');
      rethrow;
    }
  }
}
