import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RevenueCatService {
  static const String _androidApiKey = 'goog_caVinOeAWiSVoqTdHvLYOcvRuGG'; // RevenueCat Dashboard'dan alın
  static const String _iosApiKey = 'appl_YOUR_ACTUAL_API_KEY_HERE'; // RevenueCat Dashboard'dan alın
  
  final Logger _logger = Logger();
  bool _isInitialized = false;
  
  // Entitlements
  static const String premiumEntitlementId = 'premium';
  
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      _logger.i('🚀 RevenueCat başlatılıyor...');
      
      // Platform-specific API key
      final apiKey = _getPlatformApiKey();
      
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      
      _isInitialized = true;
      _logger.i('✅ RevenueCat başarıyla başlatıldı');
      
    } catch (e) {
      _logger.e('❌ RevenueCat başlatma hatası: $e');
      rethrow;
    }
  }
  
  String _getPlatformApiKey() {
    // Flutter'da platform kontrolü için bu kısmı daha sonra güncellenecek
    return _androidApiKey; // Şimdilik Android için
  }
  
  // Customer Info alma
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      _logger.e('Customer info alma hatası: $e');
      return null;
    }
  }
  
  // Premium durumu kontrolü
  Future<bool> isPremiumActive() async {
    try {
      final customerInfo = await getCustomerInfo();
      return customerInfo?.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    } catch (e) {
      _logger.e('Premium durumu kontrol hatası: $e');
      return false;
    }
  }
  
  // Mevcut Offerings alma
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      _logger.e('Offerings alma hatası: $e');
      return null;
    }
  }
  
  // Paket satın alma
  Future<bool> purchasePackage(Package package) async {
    try {
      _logger.i('💰 Paket satın alma başlatılıyor: ${package.identifier}');
      
      final purchaseResult = await Purchases.purchasePackage(package);
      
      // PurchaseResult'tan CustomerInfo'yu al
      final customerInfo = purchaseResult.customerInfo;
      final isPremium = customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
      
      if (isPremium) {
        _logger.i('✅ Premium üyelik başarıyla aktif edildi!');
        return true;
      } else {
        _logger.w('⚠️ Premium üyelik aktif edilemedi');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Satın alma hatası: $e');
      return false;
    }
  }
  
  // Abonelik iptali
  Future<void> cancelSubscription() async {
    try {
      _logger.i('🔄 Abonelik iptali başlatılıyor...');
      
      // RevenueCat'te abonelik genellikle App Store/Google Play üzerinden iptal edilir
      // Bu fonksiyon kullanıcıyı mağaza yönlendirmesine yönlendirir
      
      _logger.i('ℹ️ Lütfen App Store/Google Play üzerinden aboneliğinizi iptal edin');
    } catch (e) {
      _logger.e('❌ Abonelik iptali hatası: $e');
    }
  }
  
  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      _logger.i('🔄 Satın alımlar geri yükleniyor...');
      
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
      
      if (isPremium) {
        _logger.i('✅ Premium üyelik geri yüklendi!');
        return true;
      } else {
        _logger.w('⚠️ Eski satın alım bulunamadı');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Geri yükleme hatası: $e');
      return false;
    }
  }
  
  // Customer User ID ayarlama
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      _logger.i('👤 Kullanıcı ID ayarlandı: $userId');
    } catch (e) {
      _logger.e('❌ Kullanıcı ID ayarlama hatası: $e');
    }
  }
  
  // Custom attributes ekleme
  Future<void> setUserAttributes(Map<String, String> attributes) async {
    try {
      await Purchases.setAttributes(attributes);
      _logger.i('🏷️ Kullanıcı öznitelikleri eklendi: $attributes');
    } catch (e) {
      _logger.e('❌ Öznitelik ekleme hatası: $e');
    }
  }
}

// RevenueCat Provider
final revenueCatProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

// Premium Status Provider
final premiumStatusProvider = FutureProvider<bool>((ref) async {
  final revenueCat = ref.read(revenueCatProvider);
  await revenueCat.initialize();
  return await revenueCat.isPremiumActive();
});

// Offerings Provider
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final revenueCat = ref.read(revenueCatProvider);
  await revenueCat.initialize();
  return await revenueCat.getOfferings();
});
