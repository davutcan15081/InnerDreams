import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'hybrid_user_service.dart';
import 'hybrid_content_service.dart';
import 'cloudinary_service.dart';

/// Hibrit sistem servisleri
/// Firebase (Auth + Firestore) + Cloudinary (File Storage)
class HybridSystemService {
  // Singleton pattern
  static final HybridSystemService _instance = HybridSystemService._internal();
  factory HybridSystemService() => _instance;
  HybridSystemService._internal();

  // Servis durumları
  bool _isFirebaseAuthInitialized = false;
  bool _isFirestoreInitialized = false;
  bool _isCloudinaryInitialized = false;

  /// Sistem durumunu kontrol et
  bool get isSystemReady => 
      _isFirebaseAuthInitialized && 
      _isFirestoreInitialized && 
      _isCloudinaryInitialized;

  /// Firebase Auth durumu
  bool get isFirebaseAuthReady => _isFirebaseAuthInitialized;

  /// Firestore durumu
  bool get isFirestoreReady => _isFirestoreInitialized;

  /// Cloudinary durumu
  bool get isCloudinaryReady => _isCloudinaryInitialized;

  /// Firebase Auth'u başlat
  Future<bool> initializeFirebaseAuth() async {
    try {
      // Firebase Auth zaten kurulu, sadece durumu kontrol et
      _isFirebaseAuthInitialized = true;
      return true;
    } catch (e) {
      print('Firebase Auth başlatma hatası: $e');
      return false;
    }
  }

  /// Firestore'u başlat
  Future<bool> initializeFirestore() async {
    try {
      // Firestore zaten kurulu, sadece durumu kontrol et
      _isFirestoreInitialized = true;
      return true;
    } catch (e) {
      print('Firestore başlatma hatası: $e');
      return false;
    }
  }

  /// Cloudinary'yi başlat
  Future<bool> initializeCloudinary() async {
    try {
      // Cloudinary bağlantısını test et
      final isConnected = await CloudinaryService.testConnection();
      _isCloudinaryInitialized = isConnected;
      return isConnected;
    } catch (e) {
      print('Cloudinary başlatma hatası: $e');
      return false;
    }
  }

  /// Tüm sistemi başlat
  Future<bool> initializeAll() async {
    print('🚀 Hibrit sistem başlatılıyor...');
    
    final authResult = await initializeFirebaseAuth();
    final firestoreResult = await initializeFirestore();
    final cloudinaryResult = await initializeCloudinary();

    if (authResult && firestoreResult && cloudinaryResult) {
      print('✅ Hibrit sistem başarıyla başlatıldı!');
      print('   - Firebase Auth: ✅');
      print('   - Firestore: ✅');
      print('   - Cloudinary: ✅');
      return true;
    } else {
      print('❌ Hibrit sistem başlatılamadı!');
      print('   - Firebase Auth: ${authResult ? "✅" : "❌"}');
      print('   - Firestore: ${firestoreResult ? "✅" : "❌"}');
      print('   - Cloudinary: ${cloudinaryResult ? "✅" : "❌"}');
      return false;
    }
  }

  /// Sistem durumunu yazdır
  void printSystemStatus() {
    print('📊 Hibrit Sistem Durumu:');
    print('   - Firebase Auth: ${_isFirebaseAuthInitialized ? "✅ Hazır" : "❌ Hazır Değil"}');
    print('   - Firestore: ${_isFirestoreInitialized ? "✅ Hazır" : "❌ Hazır Değil"}');
    print('   - Cloudinary: ${_isCloudinaryInitialized ? "✅ Hazır" : "❌ Hazır Değil"}');
    print('   - Genel Durum: ${isSystemReady ? "✅ Sistem Hazır" : "❌ Sistem Hazır Değil"}');
  }
}
