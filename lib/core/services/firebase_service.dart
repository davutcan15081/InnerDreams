import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  
  // Collections
  static CollectionReference get usersCollection => firestore.collection('users');
  static CollectionReference get adminsCollection => firestore.collection('admins');
  static CollectionReference get writersCollection => firestore.collection('writers');
  static CollectionReference get doctorsCollection => firestore.collection('doctors');
  static CollectionReference get educationsCollection => firestore.collection('educations');
  static CollectionReference get sessionsCollection => firestore.collection('sessions');
  static CollectionReference get booksCollection => firestore.collection('books');
  static CollectionReference get contentCollection => firestore.collection('content');
  
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // User roles enum
  static const String ROLE_ADMIN = 'admin';
  static const String ROLE_WRITER = 'writer';
  static const String ROLE_DOCTOR = 'doctor';
  static const String ROLE_USER = 'user';
  static const String ROLE_HYBRID = 'hybrid';
  
  // Check if user is hybrid (both doctor and writer)
  static Future<bool> isHybrid(String uid) async {
    try {
      final doctorDoc = await doctorsCollection.doc(uid).get();
      final writerDoc = await writersCollection.doc(uid).get();
      return doctorDoc.exists && writerDoc.exists;
    } catch (e) {
      print('Hybrid check error: $e');
      return false;
    }
  }
  
  // Get user role with hybrid support
  static Future<String> getUserRole(String uid) async {
    try {
      // Check if user is hybrid (both doctor and writer)
      final isHybridUser = await isHybrid(uid);
      if (isHybridUser) {
        print('User $uid is hybrid (doctor + writer)');
        return ROLE_HYBRID;
      }
      
      // Check admin
      final adminDoc = await adminsCollection.doc(uid).get();
      if (adminDoc.exists) {
        print('User $uid is admin');
        return ROLE_ADMIN;
      }
      
      // Check writer
      final writerDoc = await writersCollection.doc(uid).get();
      if (writerDoc.exists) {
        print('User $uid is writer');
        return ROLE_WRITER;
      }
      
      // Check doctor
      final doctorDoc = await doctorsCollection.doc(uid).get();
      if (doctorDoc.exists) {
        print('User $uid is doctor');
        return ROLE_DOCTOR;
      }
      
      print('User $uid is regular user');
      return ROLE_USER;
    } catch (e) {
      print('Role check error: $e');
      return ROLE_USER;
    }
  }
  
  // Check if user is admin (backward compatibility)
  static Future<bool> isAdmin(String uid) async {
    final role = await getUserRole(uid);
    return role == ROLE_ADMIN;
  }
  
  // Check if user is writer
  static Future<bool> isWriter(String uid) async {
    final role = await getUserRole(uid);
    return role == ROLE_WRITER;
  }
  
  // Check if user is doctor
  static Future<bool> isDoctor(String uid) async {
    final role = await getUserRole(uid);
    return role == ROLE_DOCTOR;
  }
  
  // Check if user is hybrid
  static Future<bool> isHybridRole(String uid) async {
    final role = await getUserRole(uid);
    return role == ROLE_HYBRID;
  }
  
  // Get current user
  static User? get currentUser => auth.currentUser;
  
  // Sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }

  // İçerik URL'sini güncelle
  static Future<bool> updateContentUrl(String contentId, String newUrl) async {
    try {
      await contentCollection.doc(contentId).update({
        'url': newUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('İçerik URL güncellendi: $contentId -> $newUrl');
      return true;
    } catch (e) {
      print('İçerik URL güncelleme hatası: $e');
      return false;
    }
  }

  // Boş URL'li içerikleri bul ve güncelle
  static Future<void> fixEmptyUrls() async {
    try {
      final snapshot = await contentCollection
          .where('url', isEqualTo: '')
          .where('type', isEqualTo: 'pdf')
          .get();

      print('Boş URL\'li ${snapshot.docs.length} PDF içeriği bulundu');

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final fileName = data['fileName'] as String?;
        
        if (fileName != null && fileName.isNotEmpty) {
          print('❌ ${doc.id} için URL bulunamadı: $fileName');
        }
      }
    } catch (e) {
      print('Boş URL\'leri düzeltme hatası: $e');
    }
  }

  // Test için: Belirli bir içeriği güncelle
  static Future<void> fixTestContent() async {
    try {
      // testpdf3 içeriğini bul ve güncelle
      final snapshot = await contentCollection
          .where('title', isEqualTo: 'testpdf3')
          .where('type', isEqualTo: 'pdf')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final fileName = data['fileName'] as String? ?? '10rules.pdf';
        
        print('testpdf3 içeriği bulundu: ${doc.id}');
        print('fileName: $fileName');
        
        print('❌ Cloudinary sistemi kaldırıldı, URL güncellenemedi');
      } else {
        print('testpdf3 içeriği bulunamadı');
      }
    } catch (e) {
      print('Test içeriği düzeltme hatası: $e');
    }
  }
}