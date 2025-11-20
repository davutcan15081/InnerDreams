import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Kullanıcı rolleri
enum UserRole {
  admin('Admin', 'Sistem yöneticisi'),
  writer('Yazar', 'İçerik yazarı'),
  expert('Uzman', 'Rüya tabiri uzmanı'),
  premium('Premium', 'Premium üye'),
  user('Kullanıcı', 'Standart üye');

  const UserRole(this.displayName, this.description);
  final String displayName;
  final String description;

  /// String'den role dönüştür
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.user,
    );
  }
}

/// Kullanıcı izinleri
class UserPermissions {
  final bool canCreateContent;
  final bool canEditContent;
  final bool canDeleteContent;
  final bool canManageUsers;
  final bool canAccessAdminPanel;
  final bool canUploadFiles;
  final bool canViewPremiumContent;

  const UserPermissions({
    required this.canCreateContent,
    required this.canEditContent,
    required this.canDeleteContent,
    required this.canManageUsers,
    required this.canAccessAdminPanel,
    required this.canUploadFiles,
    required this.canViewPremiumContent,
  });

  /// Role göre izinleri belirle
  static UserPermissions fromRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const UserPermissions(
          canCreateContent: true,
          canEditContent: true,
          canDeleteContent: true,
          canManageUsers: true,
          canAccessAdminPanel: true,
          canUploadFiles: true,
          canViewPremiumContent: true,
        );
      case UserRole.writer:
        return const UserPermissions(
          canCreateContent: true,
          canEditContent: true,
          canDeleteContent: false,
          canManageUsers: false,
          canAccessAdminPanel: false,
          canUploadFiles: true,
          canViewPremiumContent: true,
        );
      case UserRole.expert:
        return const UserPermissions(
          canCreateContent: true,
          canEditContent: true,
          canDeleteContent: false,
          canManageUsers: false,
          canAccessAdminPanel: false,
          canUploadFiles: true,
          canViewPremiumContent: true,
        );
      case UserRole.premium:
        return const UserPermissions(
          canCreateContent: false,
          canEditContent: false,
          canDeleteContent: false,
          canManageUsers: false,
          canAccessAdminPanel: false,
          canUploadFiles: false,
          canViewPremiumContent: true,
        );
      case UserRole.user:
        return const UserPermissions(
          canCreateContent: false,
          canEditContent: false,
          canDeleteContent: false,
          canManageUsers: false,
          canAccessAdminPanel: false,
          canUploadFiles: false,
          canViewPremiumContent: false,
        );
    }
  }
}

/// Hibrit kullanıcı yönetimi servisi
class HybridUserService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mevcut kullanıcıyı al
  static User? get currentUser => _auth.currentUser;

  /// Kullanıcı giriş yapmış mı?
  static bool get isLoggedIn => currentUser != null;

  /// Kullanıcı bilgilerini al
  static Future<Map<String, dynamic>?> getUserData() async {
    if (!isLoggedIn) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      return doc.data();
    } catch (e) {
      print('Kullanıcı bilgileri alınamadı: $e');
      return null;
    }
  }

  /// Kullanıcı rolünü al
  static Future<UserRole> getUserRole() async {
    final userData = await getUserData();
    if (userData == null) return UserRole.user;

    final roleString = userData['role'] as String? ?? 'user';
    return UserRole.fromString(roleString);
  }

  /// Kullanıcı izinlerini al
  static Future<UserPermissions> getUserPermissions() async {
    final role = await getUserRole();
    return UserPermissions.fromRole(role);
  }

  /// Kullanıcı rolünü güncelle (sadece admin)
  static Future<bool> updateUserRole(String userId, UserRole newRole) async {
    try {
      final currentRole = await getUserRole();
      if (currentRole != UserRole.admin) {
        print('Sadece admin kullanıcı rolü güncelleyebilir');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': newRole.name});

      print('Kullanıcı rolü güncellendi: $newRole');
      return true;
    } catch (e) {
      print('Kullanıcı rolü güncellenemedi: $e');
      return false;
    }
  }

  /// Kullanıcı profilini güncelle
  static Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    if (!isLoggedIn) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(data);

      print('Kullanıcı profili güncellendi');
      return true;
    } catch (e) {
      print('Kullanıcı profili güncellenemedi: $e');
      return false;
    }
  }

  /// Kullanıcı oluştur (kayıt sırasında)
  static Future<bool> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    UserRole role = UserRole.user,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileImageUrl': null,
        'bio': null,
        'preferences': {
          'notifications': true,
          'theme': 'system',
          'language': 'tr',
        },
      });

      print('Kullanıcı profili oluşturuldu: $displayName');
      return true;
    } catch (e) {
      print('Kullanıcı profili oluşturulamadı: $e');
      return false;
    }
  }

  /// Kullanıcıları listele (admin için)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final currentRole = await getUserRole();
      if (currentRole != UserRole.admin) {
        print('Sadece admin kullanıcıları listeleyebilir');
        return [];
      }

      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Kullanıcılar listelenemedi: $e');
      return [];
    }
  }

  /// Kullanıcı istatistikleri
  static Future<Map<String, int>> getUserStats() async {
    try {
      final currentRole = await getUserRole();
      if (currentRole != UserRole.admin) {
        return {};
      }

      final snapshot = await _firestore.collection('users').get();
      final stats = <String, int>{};

      for (final doc in snapshot.docs) {
        final role = doc.data()['role'] as String? ?? 'user';
        stats[role] = (stats[role] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Kullanıcı istatistikleri alınamadı: $e');
      return {};
    }
  }
}
