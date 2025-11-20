import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // User data collection
  static const String _userDataCollection = 'user_data';
  static const String _profileImagesFolder = 'profile_images';
  static const String _dreamImagesFolder = 'dream_images';
  static const String _contentFolder = 'content';
  
  // Content management for doctors and writers
  static const String _doctorContentFolder = 'doctor_content';
  static const String _writerContentFolder = 'writer_content';
  static const String _educationContentFolder = 'education_content';

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Save user profile data to Firestore
  Future<void> saveUserProfile({
    required String name,
    required String email,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      if (_currentUserId == null) {
        print('⚠️ User not authenticated, skipping Firebase Storage');
        return;
      }

      // Basit Firestore koleksiyonu ile profil bilgilerini sakla
      final userData = {
        'name': name,
        'email': email,
        'bio': bio ?? '',
        'profileImageUrl': profileImageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('user_profiles')
          .doc(_currentUserId)
          .set(userData, SetOptions(merge: true));

      _logger.i('✅ User profile saved successfully');
    } catch (e) {
      _logger.e('❌ Error saving user profile: $e');
      // Hata olsa bile devam et - kritik değil
      print('⚠️ Firebase Storage hatası göz ardı ediliyor: $e');
    }
  }

  /// Load user profile data from Firestore
  Future<Map<String, dynamic>?> loadUserProfile() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(_userDataCollection)
          .doc(_currentUserId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _logger.i('✅ User profile loaded successfully');
        return data;
      } else {
        _logger.w('⚠️ User profile not found');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error loading user profile: $e');
      rethrow;
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(_profileImagesFolder).child(fileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('✅ Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('❌ Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Upload dream image to Firebase Storage
  Future<String> uploadDreamImage(File imageFile, String dreamId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '${dreamId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(_dreamImagesFolder).child(_currentUserId!).child(fileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('✅ Dream image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('❌ Error uploading dream image: $e');
      rethrow;
    }
  }

  /// Upload content file to Firebase Storage
  Future<String> uploadContentFile(File file, String contentType) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(_contentFolder).child(_currentUserId!).child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('✅ Content file uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('❌ Error uploading content file: $e');
      rethrow;
    }
  }

  /// Upload doctor content file to Firebase Storage
  Future<String> uploadDoctorContent(File file, String contentType) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(_doctorContentFolder).child(_currentUserId!).child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('✅ Doctor content uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('❌ Error uploading doctor content: $e');
      rethrow;
    }
  }

  /// Upload writer content file to Firebase Storage
  Future<String> uploadWriterContent(File file, String contentType) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(_writerContentFolder).child(_currentUserId!).child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('✅ Writer content uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('❌ Error uploading writer content: $e');
      rethrow;
    }
  }

  /// Upload education content file to Firebase Storage
  Future<String> uploadEducationContent(File file, String contentType) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(_educationContentFolder).child(_currentUserId!).child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('✅ Education content uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('❌ Error uploading education content: $e');
      rethrow;
    }
  }

  /// Download file from Firebase Storage
  Future<Uint8List> downloadFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final data = await ref.getData();
      
      if (data != null) {
        _logger.i('✅ File downloaded successfully');
        return data;
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      _logger.e('❌ Error downloading file: $e');
      rethrow;
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      _logger.i('✅ File deleted successfully');
    } catch (e) {
      _logger.e('❌ Error deleting file: $e');
      rethrow;
    }
  }

  /// Save dream data to Firestore
  Future<void> saveDream({
    required String title,
    required String content,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final dreamData = {
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'metadata': metadata ?? {},
        'userId': _currentUserId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('dreams')
          .add(dreamData);

      _logger.i('✅ Dream saved successfully');
    } catch (e) {
      _logger.e('❌ Error saving dream: $e');
      rethrow;
    }
  }

  /// Load user dreams from Firestore
  Future<List<Map<String, dynamic>>> loadUserDreams() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final query = await _firestore
          .collection('dreams')
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      final dreams = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _logger.i('✅ User dreams loaded successfully: ${dreams.length} dreams');
      return dreams;
    } catch (e) {
      _logger.e('❌ Error loading user dreams: $e');
      rethrow;
    }
  }

  /// Save dream interpretation to Firestore
  Future<void> saveDreamInterpretation({
    required String dreamId,
    required String interpretation,
    required String interpreter,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final interpretationData = {
        'dreamId': dreamId,
        'interpretation': interpretation,
        'interpreter': interpreter,
        'metadata': metadata ?? {},
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('dream_interpretations')
          .add(interpretationData);

      _logger.i('✅ Dream interpretation saved successfully');
    } catch (e) {
      _logger.e('❌ Error saving dream interpretation: $e');
      rethrow;
    }
  }

  /// Save doctor content to Firestore
  Future<void> saveDoctorContent({
    required String title,
    required String description,
    required String content,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    List<String>? tags,
    bool isPremium = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final contentData = {
        'title': title,
        'description': description,
        'content': content,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'tags': tags ?? [],
        'isPremium': isPremium,
        'metadata': metadata ?? {},
        'authorId': _currentUserId,
        'authorType': 'doctor',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('doctor_content')
          .add(contentData);

      _logger.i('✅ Doctor content saved successfully');
    } catch (e) {
      _logger.e('❌ Error saving doctor content: $e');
      rethrow;
    }
  }

  /// Save writer content to Firestore
  Future<void> saveWriterContent({
    required String title,
    required String description,
    required String content,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    String? fileType,
    String? contentType,
    List<String>? tags,
    bool isPremium = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final contentData = {
        'title': title,
        'description': description,
        'content': content,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'fileType': fileType,
        'contentType': contentType,
        'tags': tags ?? [],
        'isPremium': isPremium,
        'metadata': metadata ?? {},
        'authorId': _currentUserId,
        'authorType': 'writer',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('writer_content')
          .add(contentData);

      _logger.i('✅ Writer content saved successfully');
    } catch (e) {
      _logger.e('❌ Error saving writer content: $e');
      rethrow;
    }
  }

  /// Save education content to Firestore
  Future<void> saveEducationContent({
    required String title,
    required String description,
    required String content,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    List<String>? tags,
    bool isPremium = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final contentData = {
        'title': title,
        'description': description,
        'content': content,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'tags': tags ?? [],
        'isPremium': isPremium,
        'metadata': metadata ?? {},
        'authorId': _currentUserId,
        'authorType': 'education',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('education_content')
          .add(contentData);

      _logger.i('✅ Education content saved successfully');
    } catch (e) {
      _logger.e('❌ Error saving education content: $e');
      rethrow;
    }
  }

  /// Load dream interpretations from Firestore
  Future<List<Map<String, dynamic>>> loadDreamInterpretations(String dreamId) async {
    try {
      final query = await _firestore
          .collection('dream_interpretations')
          .where('dreamId', isEqualTo: dreamId)
          .orderBy('createdAt', descending: true)
          .get();

      final interpretations = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _logger.i('✅ Dream interpretations loaded successfully: ${interpretations.length} interpretations');
      return interpretations;
    } catch (e) {
      _logger.e('❌ Error loading dream interpretations: $e');
      rethrow;
    }
  }

  /// Load doctor content from Firestore
  Future<List<Map<String, dynamic>>> loadDoctorContent() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final query = await _firestore
          .collection('doctor_content')
          .where('authorId', isEqualTo: _currentUserId)
          .get();

      // Sort by createdAt in memory
      final content = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt descending
      content.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));

      _logger.i('✅ Doctor content loaded successfully: ${content.length} items');
      return content;
    } catch (e) {
      _logger.e('❌ Error loading doctor content: $e');
      rethrow;
    }
  }

  /// Load writer content from Firestore
  Future<List<Map<String, dynamic>>> loadWriterContent() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final query = await _firestore
          .collection('writer_content')
          .where('authorId', isEqualTo: _currentUserId)
          .get();

      // Sort by createdAt in memory
      final content = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt descending
      content.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));

      _logger.i('✅ Writer content loaded successfully: ${content.length} items');
      return content;
    } catch (e) {
      _logger.e('❌ Error loading writer content: $e');
      rethrow;
    }
  }

  /// Load education content from Firestore
  Future<List<Map<String, dynamic>>> loadEducationContent() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final query = await _firestore
          .collection('education_content')
          .where('authorId', isEqualTo: _currentUserId)
          .get();

      // Sort by createdAt in memory
      final content = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt descending
      content.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));

      _logger.i('✅ Education content loaded successfully: ${content.length} items');
      return content;
    } catch (e) {
      _logger.e('❌ Error loading education content: $e');
      rethrow;
    }
  }

  /// Load all public content (for users to view)
  Future<List<Map<String, dynamic>>> loadPublicContent({
    String? contentType,
    bool? isPremium,
    List<String>? tags,
  }) async {
    try {
      Query query = _firestore.collection('content');

      // Apply filters
      if (contentType != null) {
        query = query.where('type', isEqualTo: contentType);
      }
      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      final content = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter by tags if provided
      if (tags != null && tags.isNotEmpty) {
        content.removeWhere((item) {
          final itemTags = List<String>.from(item['tags'] ?? []);
          return !tags.any((tag) => itemTags.contains(tag));
        });
      }

      _logger.i('✅ Public content loaded successfully: ${content.length} items');
      return content;
    } catch (e) {
      _logger.e('❌ Error loading public content: $e');
      rethrow;
    }
  }

  /// Load all content from all collections (for admin view)
  Future<List<Map<String, dynamic>>> loadAllContent() async {
    try {
      final List<Map<String, dynamic>> allContent = [];

      // Load doctor content
      final doctorQuery = await _firestore
          .collection('doctor_content')
          .orderBy('createdAt', descending: true)
          .get();
      
      for (final doc in doctorQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['collection'] = 'doctor_content';
        allContent.add(data);
      }

      // Load writer content
      final writerQuery = await _firestore
          .collection('writer_content')
          .orderBy('createdAt', descending: true)
          .get();
      
      for (final doc in writerQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['collection'] = 'writer_content';
        allContent.add(data);
      }

      // Load education content
      final educationQuery = await _firestore
          .collection('education_content')
          .orderBy('createdAt', descending: true)
          .get();
      
      for (final doc in educationQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        data['collection'] = 'education_content';
        allContent.add(data);
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

      _logger.i('✅ All content loaded successfully: ${allContent.length} items');
      return allContent;
    } catch (e) {
      _logger.e('❌ Error loading all content: $e');
      rethrow;
    }
  }

  /// Update content
  Future<void> updateContent(String collection, String contentId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      
      await _firestore
          .collection(collection)
          .doc(contentId)
          .update(updates);

      _logger.i('✅ Content updated successfully');
    } catch (e) {
      _logger.e('❌ Error updating content: $e');
      rethrow;
    }
  }

  /// Delete content
  Future<void> deleteContent(String collection, String contentId) async {
    try {
      // Get content data to delete associated files
      final doc = await _firestore.collection(collection).doc(contentId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final fileUrl = data['fileUrl'] as String?;
        
        // Delete file from storage if exists
        if (fileUrl != null && fileUrl.isNotEmpty) {
          try {
            await deleteFile(fileUrl);
          } catch (e) {
            _logger.w('⚠️ Could not delete file: $e');
          }
        }
      }

      // Delete document from Firestore
      await _firestore.collection(collection).doc(contentId).delete();

      _logger.i('✅ Content deleted successfully');
    } catch (e) {
      _logger.e('❌ Error deleting content: $e');
      rethrow;
    }
  }

  /// Save user settings to Firestore
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final settingsData = {
        ...settings,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection(_userDataCollection)
          .doc(_currentUserId)
          .collection('settings')
          .doc('user_settings')
          .set(settingsData, SetOptions(merge: true));

      _logger.i('✅ User settings saved successfully');
    } catch (e) {
      _logger.e('❌ Error saving user settings: $e');
      rethrow;
    }
  }

  /// Load user settings from Firestore
  Future<Map<String, dynamic>?> loadUserSettings() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(_userDataCollection)
          .doc(_currentUserId)
          .collection('settings')
          .doc('user_settings')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _logger.i('✅ User settings loaded successfully');
        return data;
      } else {
        _logger.w('⚠️ User settings not found');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error loading user settings: $e');
      rethrow;
    }
  }

  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get profile images size
      final profileImagesRef = _storage.ref().child(_profileImagesFolder);
      final profileImagesList = await profileImagesRef.listAll();
      
      // Get dream images size
      final dreamImagesRef = _storage.ref().child(_dreamImagesFolder).child(_currentUserId!);
      final dreamImagesList = await dreamImagesRef.listAll();
      
      // Get content files size
      final contentRef = _storage.ref().child(_contentFolder).child(_currentUserId!);
      final contentList = await contentRef.listAll();

      int totalFiles = profileImagesList.items.length + 
                      dreamImagesList.items.length + 
                      contentList.items.length;

      // Calculate total size (simplified - in real implementation you'd get metadata for each file)
      final usage = {
        'totalFiles': totalFiles,
        'profileImages': profileImagesList.items.length,
        'dreamImages': dreamImagesList.items.length,
        'contentFiles': contentList.items.length,
        'estimatedSize': '${totalFiles * 0.5} MB', // Rough estimate
      };

      _logger.i('✅ Storage usage calculated: $usage');
      return usage;
    } catch (e) {
      _logger.e('❌ Error calculating storage usage: $e');
      rethrow;
    }
  }

  /// Clear all user data (for account deletion)
  Future<void> clearAllUserData() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Delete all files from storage
      final profileImagesRef = _storage.ref().child(_profileImagesFolder);
      final profileImagesList = await profileImagesRef.listAll();
      for (final item in profileImagesList.items) {
        await item.delete();
      }

      final dreamImagesRef = _storage.ref().child(_dreamImagesFolder).child(_currentUserId!);
      final dreamImagesList = await dreamImagesRef.listAll();
      for (final item in dreamImagesList.items) {
        await item.delete();
      }

      final contentRef = _storage.ref().child(_contentFolder).child(_currentUserId!);
      final contentList = await contentRef.listAll();
      for (final item in contentList.items) {
        await item.delete();
      }

      // Delete doctor content files
      final doctorContentRef = _storage.ref().child(_doctorContentFolder).child(_currentUserId!);
      final doctorContentList = await doctorContentRef.listAll();
      for (final item in doctorContentList.items) {
        await item.delete();
      }

      // Delete writer content files
      final writerContentRef = _storage.ref().child(_writerContentFolder).child(_currentUserId!);
      final writerContentList = await writerContentRef.listAll();
      for (final item in writerContentList.items) {
        await item.delete();
      }

      // Delete education content files
      final educationContentRef = _storage.ref().child(_educationContentFolder).child(_currentUserId!);
      final educationContentList = await educationContentRef.listAll();
      for (final item in educationContentList.items) {
        await item.delete();
      }

      // Delete Firestore documents
      await _firestore.collection(_userDataCollection).doc(_currentUserId).delete();
      
      // Delete dreams
      final dreamsQuery = await _firestore
          .collection('dreams')
          .where('userId', isEqualTo: _currentUserId)
          .get();
      
      for (final doc in dreamsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete doctor content
      final doctorContentQuery = await _firestore
          .collection('doctor_content')
          .where('authorId', isEqualTo: _currentUserId)
          .get();
      
      for (final doc in doctorContentQuery.docs) {
        await doc.reference.delete();
      }

      // Delete writer content
      final writerContentQuery = await _firestore
          .collection('writer_content')
          .where('authorId', isEqualTo: _currentUserId)
          .get();
      
      for (final doc in writerContentQuery.docs) {
        await doc.reference.delete();
      }

      // Delete education content
      final educationContentQuery = await _firestore
          .collection('education_content')
          .where('authorId', isEqualTo: _currentUserId)
          .get();
      
      for (final doc in educationContentQuery.docs) {
        await doc.reference.delete();
      }

      _logger.i('✅ All user data cleared successfully');
    } catch (e) {
      _logger.e('❌ Error clearing user data: $e');
      rethrow;
    }
  }
}
