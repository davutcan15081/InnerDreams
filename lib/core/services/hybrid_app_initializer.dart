import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'hybrid_system_service.dart';
import 'hybrid_user_service.dart';
import 'hybrid_content_service.dart';

/// Hibrit sistem başlatma servisi
class HybridAppInitializer {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Uygulamayı başlat
  static Future<bool> initializeApp() async {
    if (_isInitialized) return true;

    try {
      print('🚀 Hibrit sistem başlatılıyor...');

      // Firebase'i başlat
      await Firebase.initializeApp();
      print('✅ Firebase başlatıldı');

      // Hibrit sistem servislerini başlat
      final systemReady = await HybridSystemService().initializeAll();
      if (!systemReady) {
        print('❌ Hibrit sistem başlatılamadı');
        return false;
      }

      // Sistem durumunu kontrol et
      HybridSystemService().printSystemStatus();

      _isInitialized = true;
      print('🎉 Hibrit sistem başarıyla başlatıldı!');
      return true;
    } catch (e) {
      print('❌ Uygulama başlatma hatası: $e');
      return false;
    }
  }

  /// Sistem durumunu kontrol et
  static Future<Map<String, dynamic>> getSystemStatus() async {
    final systemService = HybridSystemService();
    
    return {
      'isInitialized': _isInitialized,
      'firebaseAuth': systemService.isFirebaseAuthReady,
      'firestore': systemService.isFirestoreReady,
      'cloudinary': systemService.isCloudinaryReady,
      'systemReady': systemService.isSystemReady,
      'userLoggedIn': HybridUserService.isLoggedIn,
      'currentUser': HybridUserService.currentUser?.email ?? 'Giriş yapılmamış',
    };
  }

  /// Sistem durumu widget'ı
  static Widget buildSystemStatusWidget() {
    return FutureBuilder<Map<String, dynamic>>(
      future: getSystemStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Sistem durumu kontrol ediliyor...'),
            ),
          );
        }

        final status = snapshot.data!;
        return Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text('Hibrit Sistem Durumu'),
                subtitle: Text('Firebase + Cloudinary'),
              ),
              ListTile(
                leading: Icon(
                  status['firebaseAuth'] ? Icons.check_circle : Icons.error,
                  color: status['firebaseAuth'] ? Colors.green : Colors.red,
                ),
                title: const Text('Firebase Auth'),
                subtitle: Text(status['firebaseAuth'] ? 'Hazır' : 'Hazır Değil'),
              ),
              ListTile(
                leading: Icon(
                  status['firestore'] ? Icons.check_circle : Icons.error,
                  color: status['firestore'] ? Colors.green : Colors.red,
                ),
                title: const Text('Firestore'),
                subtitle: Text(status['firestore'] ? 'Hazır' : 'Hazır Değil'),
              ),
              ListTile(
                leading: Icon(
                  status['cloudinary'] ? Icons.check_circle : Icons.error,
                  color: status['cloudinary'] ? Colors.green : Colors.red,
                ),
                title: const Text('Cloudinary'),
                subtitle: Text(status['cloudinary'] ? 'Hazır' : 'Hazır Değil'),
              ),
              ListTile(
                leading: Icon(
                  status['userLoggedIn'] ? Icons.person : Icons.person_off,
                  color: status['userLoggedIn'] ? Colors.green : Colors.orange,
                ),
                title: const Text('Kullanıcı'),
                subtitle: Text(status['currentUser']),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sistem bilgileri dialog'u
  static void showSystemInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hibrit Sistem Bilgileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏗️ Sistem Mimarisi:'),
            const SizedBox(height: 8),
            const Text('• Firebase Auth - Kullanıcı yönetimi'),
            const Text('• Firebase Firestore - Veri depolama'),
            const Text('• Cloudinary - Dosya depolama (25GB ücretsiz)'),
            const SizedBox(height: 16),
            const Text('📊 Özellikler:'),
            const SizedBox(height: 8),
            const Text('• Kullanıcı rolleri (Admin, Yazar, Uzman, Premium, Kullanıcı)'),
            const Text('• İçerik yönetimi (PDF, resim, video, ses)'),
            const Text('• Dosya yükleme ve indirme'),
            const Text('• Premium içerik sistemi'),
            const Text('• İstatistikler ve raporlama'),
            const SizedBox(height: 16),
            const Text('💾 Depolama:'),
            const SizedBox(height: 8),
            const Text('• Cloudinary: 25GB ücretsiz'),
            const Text('• Firebase: Sınırsız (Firestore)'),
            const Text('• Otomatik dosya optimizasyonu'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
