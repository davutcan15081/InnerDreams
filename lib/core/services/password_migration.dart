import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordMigration {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Şifre hash'leme fonksiyonu
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sadece users koleksiyonundaki şifreleri hash'le
  static Future<void> migrateAllPasswords() async {
    print('Şifre migration başlıyor...');
    
    try {
      // Sadece users koleksiyonu
      await _migrateCollection('users');
      
      print('Users koleksiyonu şifreleri başarıyla hash\'lendi!');
    } catch (e) {
      print('Migration hatası: $e');
    }
  }

  // Belirli bir koleksiyondaki şifreleri hash'le
  static Future<void> _migrateCollection(String collectionName) async {
    print('$collectionName koleksiyonu işleniyor...');
    
    final querySnapshot = await _firestore.collection(collectionName).get();
    
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final password = data['password'];
      
      // Eğer şifre yoksa varsayılan şifre ekle
      if (password == null) {
        final defaultPassword = '123456'; // Varsayılan şifre
        final hashedPassword = _hashPassword(defaultPassword);
        
        await doc.reference.update({
          'password': hashedPassword,
        });
        
        print('${doc.id} - Varsayılan şifre eklendi (123456)');
      }
      // Eğer şifre varsa ve henüz hash'lenmemişse
      else if (password is String && !_isHashed(password)) {
        final hashedPassword = _hashPassword(password);
        
        await doc.reference.update({
          'password': hashedPassword,
        });
        
        print('${doc.id} - Şifre hash\'lendi');
      }
    }
    
    print('$collectionName koleksiyonu tamamlandı');
  }

  // Şifrenin zaten hash'li olup olmadığını kontrol et
  static bool _isHashed(String password) {
    // SHA256 hash'i 64 karakter uzunluğundadır
    return password.length == 64 && RegExp(r'^[a-f0-9]+$').hasMatch(password);
  }

  // Test için hash hesaplayıcı
  static void printPasswordHashes() {
    print('Test şifreleri:');
    print('123456 -> ${_hashPassword('123456')}');
    print('password -> ${_hashPassword('password')}');
    print('admin123 -> ${_hashPassword('admin123')}');
  }
}
