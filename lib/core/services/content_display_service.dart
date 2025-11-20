import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Service for displaying content to users from doctors and writers
class ContentDisplayService {
  static final ContentDisplayService _instance = ContentDisplayService._internal();
  factory ContentDisplayService() => _instance;
  ContentDisplayService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Load all public content for users to view
  Future<List<Map<String, dynamic>>> loadPublicContent({
    String? contentType,
    bool? isPremium,
    List<String>? tags,
    String? authorType,
  }) async {
    try {
      final List<Map<String, dynamic>> allContent = [];

      // Load doctor content
      Query doctorQuery = _firestore.collection('doctor_content');
      
      // Apply filters
      if (isPremium != null) {
        doctorQuery = doctorQuery.where('isPremium', isEqualTo: isPremium);
      }
      if (tags != null && tags.isNotEmpty) {
        doctorQuery = doctorQuery.where('tags', arrayContainsAny: tags);
      }

      final doctorSnapshot = await doctorQuery.orderBy('createdAt', descending: true).get();
      
      for (final doc in doctorSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['collection'] = 'doctor_content';
        data['authorType'] = 'doctor';
        allContent.add(data);
      }

      // Load writer content
      Query writerQuery = _firestore.collection('writer_content');
      
      // Apply filters
      if (isPremium != null) {
        writerQuery = writerQuery.where('isPremium', isEqualTo: isPremium);
      }
      if (tags != null && tags.isNotEmpty) {
        writerQuery = writerQuery.where('tags', arrayContainsAny: tags);
      }

      final writerSnapshot = await writerQuery.orderBy('createdAt', descending: true).get();
      
      for (final doc in writerSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['collection'] = 'writer_content';
        data['authorType'] = 'writer';
        allContent.add(data);
      }

      // Load education content
      Query educationQuery = _firestore.collection('education_content');
      
      // Apply filters
      if (isPremium != null) {
        educationQuery = educationQuery.where('isPremium', isEqualTo: isPremium);
      }
      if (tags != null && tags.isNotEmpty) {
        educationQuery = educationQuery.where('tags', arrayContainsAny: tags);
      }

      final educationSnapshot = await educationQuery.orderBy('createdAt', descending: true).get();
      
      for (final doc in educationSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['collection'] = 'education_content';
        data['authorType'] = 'education';
        allContent.add(data);
      }

      // Filter by author type if specified
      if (authorType != null) {
        allContent.removeWhere((item) => item['authorType'] != authorType);
      }

      // Filter by content type if specified
      if (contentType != null) {
        allContent.removeWhere((item) => item['metadata']?['type'] != contentType);
      }

      // Sort by creation date
      allContent.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        
        // Handle both int (milliseconds) and Timestamp types
        DateTime? aDateTime;
        DateTime? bDateTime;
        
        if (aTime is int) {
          aDateTime = DateTime.fromMillisecondsSinceEpoch(aTime);
        } else if (aTime is Timestamp) {
          aDateTime = aTime.toDate();
        }
        
        if (bTime is int) {
          bDateTime = DateTime.fromMillisecondsSinceEpoch(bTime);
        } else if (bTime is Timestamp) {
          bDateTime = bTime.toDate();
        }
        
        if (aDateTime == null || bDateTime == null) return 0;
        return bDateTime.compareTo(aDateTime);
      });

      _logger.i('✅ Public content loaded successfully: ${allContent.length} items');
      return allContent;
    } catch (e) {
      _logger.e('❌ Error loading public content: $e');
      rethrow;
    }
  }

  /// Load content by category
  Future<List<Map<String, dynamic>>> loadContentByCategory(String category) async {
    try {
      final content = await loadPublicContent(authorType: category);
      _logger.i('✅ Content loaded for category $category: ${content.length} items');
      return content;
    } catch (e) {
      _logger.e('❌ Error loading content by category: $e');
      rethrow;
    }
  }

  /// Load premium content (requires user to be premium)
  Future<List<Map<String, dynamic>>> loadPremiumContent() async {
    try {
      final content = await loadPublicContent(isPremium: true);
      _logger.i('✅ Premium content loaded: ${content.length} items');
      return content;
    } catch (e) {
      _logger.e('❌ Error loading premium content: $e');
      rethrow;
    }
  }

  /// Load free content
  Future<List<Map<String, dynamic>>> loadFreeContent() async {
    try {
      final content = await loadPublicContent(isPremium: false);
      _logger.i('✅ Free content loaded: ${content.length} items');
      return content;
    } catch (e) {
      _logger.e('❌ Error loading free content: $e');
      rethrow;
    }
  }

  /// Search content by title or description
  Future<List<Map<String, dynamic>>> searchContent(String query) async {
    try {
      final allContent = await loadPublicContent();
      
      final filteredContent = allContent.where((item) {
        final title = (item['title'] ?? '').toString().toLowerCase();
        final description = (item['description'] ?? '').toString().toLowerCase();
        final content = (item['content'] ?? '').toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return title.contains(searchQuery) || 
               description.contains(searchQuery) || 
               content.contains(searchQuery);
      }).toList();

      _logger.i('✅ Content search completed: ${filteredContent.length} results for "$query"');
      return filteredContent;
    } catch (e) {
      _logger.e('❌ Error searching content: $e');
      rethrow;
    }
  }

  /// Get content by ID
  Future<Map<String, dynamic>?> getContentById(String collection, String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        data['collection'] = collection;
        
        _logger.i('✅ Content loaded by ID: $id');
        return data;
      } else {
        _logger.w('⚠️ Content not found: $id');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error loading content by ID: $e');
      rethrow;
    }
  }

  /// Get content statistics
  Future<Map<String, int>> getContentStatistics() async {
    try {
      final allContent = await loadPublicContent();
      
      final stats = {
        'total': allContent.length,
        'doctor': allContent.where((item) => item['authorType'] == 'doctor').length,
        'writer': allContent.where((item) => item['authorType'] == 'writer').length,
        'education': allContent.where((item) => item['authorType'] == 'education').length,
        'premium': allContent.where((item) => item['isPremium'] == true).length,
        'free': allContent.where((item) => item['isPremium'] == false).length,
      };

      _logger.i('✅ Content statistics loaded: $stats');
      return stats;
    } catch (e) {
      _logger.e('❌ Error loading content statistics: $e');
      rethrow;
    }
  }

  /// Get popular tags
  Future<List<String>> getPopularTags({int limit = 10}) async {
    try {
      final allContent = await loadPublicContent();
      final Map<String, int> tagCounts = {};
      
      for (final item in allContent) {
        final tags = List<String>.from(item['tags'] ?? []);
        for (final tag in tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
      
      final sortedTags = tagCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      final popularTags = sortedTags
          .take(limit)
          .map((entry) => entry.key)
          .toList();

      _logger.i('✅ Popular tags loaded: $popularTags');
      return popularTags;
    } catch (e) {
      _logger.e('❌ Error loading popular tags: $e');
      rethrow;
    }
  }

  /// Check if user has access to premium content
  Future<bool> hasPremiumAccess() async {
    try {
      if (_currentUserId == null) return false;
      
      // Check if user is premium (this would be implemented based on your subscription system)
      // For now, return false as a placeholder
      return false;
    } catch (e) {
      _logger.e('❌ Error checking premium access: $e');
      return false;
    }
  }

  /// Get content recommendations for user
  Future<List<Map<String, dynamic>>> getContentRecommendations() async {
    try {
      final allContent = await loadPublicContent();
      
      // Simple recommendation algorithm - get most recent content
      final recommendations = allContent.take(10).toList();
      
      _logger.i('✅ Content recommendations loaded: ${recommendations.length} items');
      return recommendations;
    } catch (e) {
      _logger.e('❌ Error loading content recommendations: $e');
      rethrow;
    }
  }
}
