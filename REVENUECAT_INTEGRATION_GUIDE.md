# RevenueCat Entegrasyon Rehberi

## 🚀 RevenueCat Kurulum Adımları

### 1. RevenueCat Dashboard'a Kayıt
1. [RevenueCat.app](https://app.revenuecat.com/) sitesine gidin
2. Hesap oluşturun ve giriş yapın
3. Yeni bir proje oluşturun

### 2. App Store Connect Entegrasyonu (iOS)
1. App Store Connect'e gidin
2. "Users and Access" > "Integrations" > "RevenueCat" bölümünde API anahtarlarını alın
3. RevenueCat dashboard'a geri dönün ve iOS entegrasyonunu tamamlayın

### 3. Google Play Console Entegrasyonu (Android)
1. Google Play Console'a gidin  
2. "Monetization setup" > "Monetize > Integrations" bölümünden API anahtarlarını alın
3. RevenueCat dashboard'a geri dönün ve Android entegrasyonunu tamamlayın

### 4. Product ve Offering Ayarları

#### RevenueCat Dashboard'da:
1. **Products** sekmesine gidin
2. Yeni subscription product'ları ekleyin:
   ```
   iOS Product IDs:
   - monthly_premium
   - annual_premium
   
   Android Product IDs:
   - monthly_premium
   - annual_premium
   ```

3. **Entitlements** sekmesine gidin
4. "premium" entitlement'ını oluşturun

5. **Offerings** sekmesine gidin  
6. "default" offering'ini oluşturun ve packages ekleyin:
   ```
   Package Types:
   - Monthly: monthly_premium (Aylık)
   - Annual: annual_premium (Yıllık - EN İYİ seçenek)
   ```

### 5. .env Dosyası Yapılandırması

`.env` dosyasını aşağıdaki şekilde güncelleyin:

```bash
# RevenueCat Configuration
REVENUECAT_ANDROID_API_KEY=your-actual-android-api-key
REVENUECAT_IOS_API_KEY=your-actual-ios-api-key  
REVENUECAT_ENTITLEMENT_ID=premium
REVENUECAT_ENVIRONMENT=sandbox
```

### 6. RevenueCat Service Güncellemesi

`lib/core/services/revenuecat_service.dart` dosyasında API anahtarlarını güncelleyin:

```dart
class RevenueCatService {
  static const String _androidApiKey = 'your-actual-android-api-key';
  static const String _iosApiKey = 'your-actual-ios-api-key';
  
  String _getPlatformApiKey() {
    // Platform-specific key return logic
    if (Platform.isAndroid) {
      return _androidApiKey;
    } else if (Platform.isIOS) {
      return _iosApiKey;
    }
    return _androidApiKey;
  }
}
```

## 📱 Platform Setup

### Android Setup
1. `android/app/build.gradle` dosyasına RevenueCat dependency ekleyin:
```gradle
dependencies {
    implementation 'com.revenuecat.purchases:purchases:6.+'
}
```

2. Google Play Billing Library permissions ekleyin:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### iOS Setup
1. Xcode'da Capabilities → In-App Purchase aktif edin
2. App Store Connect'te In-App Purchase products oluşturun

## 🔧 Test Etme

### Sandbox Testing
1. RevenueCat dashboard'da sandbox mode aktif edin
2. iOS: iTunes Connect'te sandbox testers oluşturun
3. Android: Google Play Console'da test accounts oluşturun

### Test Satın Alımları
```dart
// Test için fake products kullanın
await revenueCat.purchasePackage(package);
```

## 💰 Fiyatlandırma Önerileri

```
Yeni Premium Model:
📱 Aylık: $4.99/ay
📱 Yıllık: $49.99/yıl (%40 tasarruf)
```

## 🚀 Production'a Geçiş

1. `.env` dosyasında `REVENUECAT_ENVIRONMENT=production` yapın
2. RevenueCat dashboard'da production mode aktif edin
3. Store'dan production API keys alın
4. Test cihazlarında production build testi yapın

## 📊 Analytics ve Monitoring

RevenueCat Dashboard'da şunları izleyin:
- **Subscriptions**: İmzalanan abonelikler
- **Revenue**: Günlük/haftalık/aylık gelir
- **Churn Rate**: Abonelik iptal oranları
- **Trial Conversion**: Deneme sürümünden premium'a geçiş
- **Customer Lifetime Value**: Müşteri yaşam değişken değeri

## 🔒 Güvenlik

1. API keys asla git'e commit etmeyin
2. `.env` dosyasını `.gitignore`'a ekleyin
3. Production'da Firebase Security Rules kullanın
4. Receipt validation backend'de yapın

## 🆘 Sorun Giderme

### Sık Karşılaşılan Hatalar:
1. **"Offering not found"**: Dashboard'da offering ve packages doğru ayarlandığından emin olun
2. **"Product not available"**: Store'da product'ların aktif olduğunu kontrol edin  
3. **"No packages"**: Offering'e packages eklendiğini kontrol edin

### Debug Logları:
```dart
await Purchases.setLogLevel(LogLevel.debug);
```

## 📞 Destek

- RevenueCat Docs: [docs.revenuecat.com](https://docs.revenuecat.com/)
- Flutter Plugin Docs: [pub.dev/packages/purchases_flutter](https://pub.dev/packages/purchases_flutter)
- RevenueCat Support: support.revenuecat.com
