import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'cloudinary_service.dart';
import 'hybrid_user_service.dart';
import '../models/content_model.dart';

/// Hibrit içerik yönetimi servisi
/// Firebase Firestore (metadata) + Cloudinary (dosyalar)
class HybridContentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// İçerik oluştur
  static Future<String?> createContent({
    required String title,
    required String description,
    required ContentType type,
    required String content,
    List<String> tags = const [],
    bool isPremium = false,
    File? file,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Kullanıcı giriş yapmamış');
        return null;
      }

      // Kullanıcı izinlerini kontrol et
      final permissions = await HybridUserService.getUserPermissions();
      if (!permissions.canCreateContent) {
        print('İçerik oluşturma izni yok');
        return null;
      }

      String? fileUrl;
      String? fileName;
      String? fileSize;

      // Dosya varsa Cloudinary'ye yükle (Signed - Private)
      if (file != null) {
        fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        
        Map<String, dynamic>? uploadResult;
        
        // Dosya türüne göre yükleme
        if (type == ContentType.pdf) {
          uploadResult = await CloudinaryService.uploadFileSigned(
            file,
            folder: 'innerdreams/pdfs',
            type: 'private', // Private dosya olarak yükle
          );
        } else if (type == ContentType.image) {
          uploadResult = await CloudinaryService.uploadImageUnsigned(file);
        } else {
          // Diğer dosya türleri için private olarak yükle
          uploadResult = await CloudinaryService.uploadFileSigned(
            file,
            folder: 'innerdreams/pdfs',
            type: 'private',
          );
        }
        
        if (uploadResult == null) {
          print('Dosya yüklenemedi');
          return null;
        }

        // URL'yi belirle
        if (type == ContentType.pdf) {
          // PDF için signed URL oluştur
          print('🔗 PDF için signed URL oluşturuluyor...');
          print('📄 Upload Result: $uploadResult');
          print('📄 Public ID: ${uploadResult['public_id']}');
          
          final publicId = uploadResult['public_id'];
          if (publicId == null || publicId.isEmpty) {
            print('❌ Public ID boş veya null!');
            fileUrl = null;
          } else {
            fileUrl = CloudinaryService.getSignedUrlFromPublicId(
              publicId,
              isPdf: true,
            );
            print('✅ PDF Signed URL: $fileUrl');
          }
        } else {
          // Resim için normal URL
          fileUrl = uploadResult['secure_url'];
          print('✅ Resim URL: $fileUrl');
        }
        
        fileSize = _formatFileSize(await file.length());
      }

      // Firestore'a metadata kaydet
      final docRef = await _firestore.collection('content').add({
        'title': title,
        'description': description,
        'type': type.name,
        'content': content,
        'tags': tags,
        'isPremium': isPremium,
        'url': fileUrl ?? '',
        'fileName': fileName,
        'fileSize': fileSize,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Bilinmeyen',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': true,
        'views': 0,
        'likes': 0,
        'downloads': 0,
        'storageProvider': fileUrl != null ? 'cloudinary' : 'none',
      });

      print('İçerik oluşturuldu: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('İçerik oluşturulamadı: $e');
      return null;
    }
  }

  /// İçerik güncelle
  static Future<bool> updateContent({
    required String contentId,
    String? title,
    String? description,
    String? content,
    List<String>? tags,
    bool? isPremium,
    File? newFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // İçerik sahibini kontrol et
      final doc = await _firestore.collection('content').doc(contentId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final authorId = data['authorId'] as String;
      final permissions = await HybridUserService.getUserPermissions();

      if (authorId != user.uid && !permissions.canEditContent) {
        print('İçerik düzenleme izni yok');
        return false;
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (content != null) updateData['content'] = content;
      if (tags != null) updateData['tags'] = tags;
      if (isPremium != null) updateData['isPremium'] = isPremium;

      // Yeni dosya varsa eski dosyayı sil ve yenisini yükle
      if (newFile != null) {
        final oldUrl = data['url'] as String?;
        if (oldUrl != null && oldUrl.isNotEmpty) {
          // Eski dosya Cloudinary'de, silme işlemi yapılabilir
          print('Eski dosya: $oldUrl');
        }

        // Yeni dosyayı yükle
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${newFile.path.split('/').last}';
        
        Map<String, dynamic>? uploadResult;
        
        // Dosya türüne göre yükleme
        if (data['type'] == 'pdf') {
          uploadResult = await CloudinaryService.uploadFileSigned(
            newFile,
            folder: 'innerdreams/pdfs',
            type: 'private',
          );
        } else if (data['type'] == 'image') {
          uploadResult = await CloudinaryService.uploadImageUnsigned(newFile);
        } else {
          uploadResult = await CloudinaryService.uploadFileSigned(
            newFile,
            folder: 'innerdreams/pdfs',
            type: 'private',
          );
        }
        
        if (uploadResult != null) {
          String downloadUrl;
          
          if (data['type'] == 'pdf') {
            // PDF için signed URL oluştur
            downloadUrl = CloudinaryService.getSignedUrlFromPublicId(
              uploadResult['public_id'],
              isPdf: true,
            );
          } else {
            // Resim için normal URL
            downloadUrl = uploadResult['secure_url'];
          }
          
          updateData['url'] = downloadUrl;
          updateData['fileName'] = fileName;
          updateData['fileSize'] = _formatFileSize(await newFile.length());
          updateData['storageProvider'] = 'cloudinary';
        }
      }

      await _firestore.collection('content').doc(contentId).update(updateData);
      print('İçerik güncellendi: $contentId');
      return true;
    } catch (e) {
      print('İçerik güncellenemedi: $e');
      return false;
    }
  }

  /// İçerik sil
  static Future<bool> deleteContent(String contentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // İçerik sahibini kontrol et
      final doc = await _firestore.collection('content').doc(contentId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final authorId = data['authorId'] as String;
      final permissions = await HybridUserService.getUserPermissions();

      if (authorId != user.uid && !permissions.canDeleteContent) {
        print('İçerik silme izni yok');
        return false;
      }

      // Cloudinary'deki dosyayı sil
      final fileUrl = data['url'] as String?;
      if (fileUrl != null && fileUrl.isNotEmpty) {
        // Dosya Cloudinary'de, silme işlemi yapılabilir
        print('Silinecek dosya: $fileUrl');
      }

      // Firestore'dan sil
      await _firestore.collection('content').doc(contentId).delete();
      print('İçerik silindi: $contentId');
      return true;
    } catch (e) {
      print('İçerik silinemedi: $e');
      return false;
    }
  }

  /// İçerikleri listele
  static Future<List<Map<String, dynamic>>> getContents({
    ContentType? type,
    bool? isPremium,
    String? authorId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('content');

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }

      if (authorId != null) {
        query = query.where('authorId', isEqualTo: authorId);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('İçerikler listelenemedi: $e');
      return [];
    }
  }

  /// İçerik detayını al
  static Future<Map<String, dynamic>?> getContent(String contentId) async {
    try {
      final doc = await _firestore.collection('content').doc(contentId).get();
      if (!doc.exists) return null;

      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      print('İçerik detayı alınamadı: $e');
      return null;
    }
  }

  /// İçerik görüntülenme sayısını artır
  static Future<void> incrementViewCount(String contentId) async {
    try {
      await _firestore.collection('content').doc(contentId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Görüntülenme sayısı artırılamadı: $e');
    }
  }

  /// İçerik beğeni sayısını artır/azalt
  static Future<void> toggleLike(String contentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('content').doc(contentId).get();
      if (!doc.exists) return;

      final likes = doc.data()!['likes'] as int? ?? 0;
      await _firestore.collection('content').doc(contentId).update({
        'likes': likes + 1,
      });
    } catch (e) {
      print('Beğeni işlemi başarısız: $e');
    }
  }

  /// İçerik indirme sayısını artır
  static Future<void> incrementDownloadCount(String contentId) async {
    try {
      await _firestore.collection('content').doc(contentId).update({
        'downloads': FieldValue.increment(1),
      });
    } catch (e) {
      print('İndirme sayısı artırılamadı: $e');
    }
  }

  /// İçerik istatistikleri
  static Future<Map<String, int>> getContentStats() async {
    try {
      final permissions = await HybridUserService.getUserPermissions();
      if (!permissions.canAccessAdminPanel) {
        return {};
      }

      final snapshot = await _firestore.collection('content').get();
      final stats = <String, int>{
        'total': snapshot.docs.length,
        'published': 0,
        'premium': 0,
        'totalViews': 0,
        'totalLikes': 0,
        'totalDownloads': 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['isPublished'] == true) stats['published'] = stats['published']! + 1;
        if (data['isPremium'] == true) stats['premium'] = stats['premium']! + 1;
        stats['totalViews'] = stats['totalViews']! + (data['views'] as int? ?? 0);
        stats['totalLikes'] = stats['totalLikes']! + (data['likes'] as int? ?? 0);
        stats['totalDownloads'] = stats['totalDownloads']! + (data['downloads'] as int? ?? 0);
      }

      return stats;
    } catch (e) {
      print('İçerik istatistikleri alınamadı: $e');
      return {};
    }
  }

  /// Dosya boyutunu formatla
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
