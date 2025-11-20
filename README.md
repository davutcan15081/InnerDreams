# InnerDreams - Rüya Tabirleri ve AI Koçluk Uygulaması

InnerDreams, kullanıcıların rüyalarını analiz etmelerine, kişisel gelişim eğitimleri almalarına ve uzmanlarla bağlantı kurmalarına olanak tanıyan kapsamlı bir mobil uygulama ve yönetim sistemidir.

## Proje Yapısı

Bu repository iki ana bileşenden oluşmaktadır:
- **Flutter Mobil Uygulama**: iOS ve Android için cross-platform mobil uygulama
- **Node.js Backend & Admin Panel**: İçerik yönetim sistemi ve API servisleri

## 🚀 Mobil Uygulama Özellikleri

### 🌙 Rüya Analizi
- AI destekli rüya tabiri
- Detaylı rüya sembolleri veritabanı
- Kişisel rüya günlüğü
- Geçmiş rüya kayıtları ve analizleri

### 🎓 Kişisel Gelişim Eğitimleri
- Video, ses ve metin tabanlı eğitim içerikleri
- Kategori ve seviye bazlı filtreleme
- İlerleme takibi
- Favori içerikler

### 👨‍⚕️ Uzman Danışmanlık
- Sertifikalı uzmanlarla online görüşme
- Randevu sistemli seans rezervasyonu
- Grup ve bireysel seanslar
- Ödeme entegrasyonu

### 📚 Dijital Kütüphane
- PDF, EPUB formatında e-kitaplar
- Sesli kitap desteği
- Kategori bazlı arama
- Offline okuma

### 💳 Abonelik Sistemi
- RevenueCat entegrasyonu
- Farklı abonelik paketleri
- Ücretsiz deneme süresi
- Güvenli ödeme altyapısı

### 🔐 Kullanıcı Yönetimi
- Email ve Google ile giriş
- Firebase Authentication
- Güvenli profil yönetimi
- Kişiselleştirilmiş deneyim

---

## 🛠️ Backend & Admin Panel Özellikleri

### 📊 Dashboard
- Sistem genel istatistikleri
- Son aktiviteler
- Kullanıcı metrikleri
- Gelir raporları

### 👥 Kullanıcı Yönetimi
- Kullanıcı listesi ve detayları
- Abonelik durumu yönetimi
- Kullanıcı istatistikleri

### 🎓 Eğitim Yönetimi
- Eğitim içerikleri oluşturma/düzenleme
- Kategori ve seviye yönetimi
- Dosya yükleme (resim, video, ses, doküman)
- Yayın durumu kontrolü

### ✍️ Yazar Yönetimi
- Yazar profilleri
- Uzmanlık alanları
- Doğrulama sistemi
- Performans metrikleri

### 👨‍⚕️ Uzman Yönetimi
- Uzman profilleri
- Müsaitlik takvimi
- Seans türleri ve fiyatlandırma
- Randevu yönetimi

### 📅 Seans Yönetimi
- Seans oluşturma/düzenleme
- Kategori ve tür yönetimi
- Kapasite ve fiyat ayarları
- Yayın durumu kontrolü

### 🗓️ Randevu Yönetimi
- Randevu listesi
- Durum takibi
- Ödeme durumu
- İptal/erteleme işlemleri

### 📚 Kitap Yönetimi
- Kitap kataloğu
- Dosya yükleme (PDF, EPUB, sesli kitap)
- Kategori ve etiket yönetimi
- İndirme istatistikleri

### 📝 İçerik Yönetimi
- Makale/blog yazıları
- SEO optimizasyonu
- Medya yönetimi
- Yorum moderasyonu

### 🔐 Admin Yönetimi
- Admin kullanıcıları
- Rol ve yetki yönetimi
- Aktivite logları

## 🛠️ Teknoloji Stack

### Flutter Mobil Uygulama
- **Framework**: Flutter 3.0+
- **Dil**: Dart
- **State Management**: Riverpod
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Subscription**: RevenueCat
- **UI Components**: Custom widgets, Shimmer, Cached Network Image
- **File Handling**: PDF Viewer (Syncfusion), Video Player, WebView

### Backend & Admin Panel
- **Backend**: Node.js + Express.js
- **Veritabanı**: MongoDB + Mongoose, Cloud Firestore
- **Kimlik Doğrulama**: JWT, Firebase Admin SDK
- **Dosya Yükleme**: Multer + Sharp (resim işleme)
- **Validasyon**: Express-validator
- **Güvenlik**: Helmet, CORS, Rate Limiting
- **Admin Frontend**: Bootstrap 5 + Vanilla JavaScript
- **Email**: Nodemailer
- **Image Processing**: Sharp, Cloudinary

## 📦 Kurulum

### Gereksinimler
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / Xcode
- Node.js (v18+)
- MongoDB (v5+)
- Firebase hesabı

### Flutter Mobil Uygulama Kurulumu

1. **Projeyi klonlayın**
```bash
git clone <repository-url>
cd InnerDreamsFlutter
```

2. **Flutter bağımlılıklarını yükleyin**
```bash
flutter pub get
```

3. **Firebase yapılandırması**
- Firebase Console'da yeni bir proje oluşturun
- Android için `google-services.json` dosyasını `android/app/` dizinine ekleyin
- iOS için `GoogleService-Info.plist` dosyasını `ios/Runner/` dizinine ekleyin
- Cloud Firestore ve Firebase Storage'ı aktifleştirin
- Firebase Authentication'da Email/Password ve Google Sign-In'i etkinleştirin

4. **RevenueCat yapılandırması**
- RevenueCat hesabınızda yeni bir proje oluşturun
- API anahtarlarınızı alın
- Ürün kimliklerinizi tanımlayın

5. **Uygulamayı çalıştırın**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Release build
flutter build apk --release
flutter build ios --release
```

### Backend & Admin Panel Kurulumu

1. **Backend dizinine gidin**
```bash
cd InnerDreamsFlutter
```

2. **Node.js bağımlılıklarını yükleyin**
```bash
npm install
```

3. **Çevre değişkenlerini ayarlayın**
```bash
cp env.example .env
```

`.env` dosyasını düzenleyin:
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/innerdreams
JWT_SECRET=your-super-secret-jwt-key
ADMIN_EMAIL=admin@innerdreams.com
ADMIN_PASSWORD=admin123
```

4. **Firebase Admin SDK yapılandırması**
- Firebase Console'dan Service Account Key dosyasını indirin
- `service-account-key.json` olarak kaydedin (bu dosya .gitignore'da)

5. **MongoDB'yi başlatın**
```bash
# Windows
net start MongoDB

# macOS/Linux
sudo systemctl start mongod
```

6. **Backend'i başlatın**
```bash
# Development
npm run dev

# Production
npm start
```

7. **Admin paneline erişin**
```
http://localhost:3000/admin
```

## 🔑 Varsayılan Admin Hesabı

- **Email**: admin@innerdreams.com
- **Şifre**: admin123

⚠️ **Güvenlik**: İlk girişten sonra mutlaka şifrenizi değiştirin!

## 📁 Proje Yapısı

```
InnerDreamsFlutter/
├── lib/                          # Flutter kaynak kodları
│   ├── core/                     # Çekirdek işlevsellik
│   │   ├── providers/            # Riverpod provider'ları
│   │   ├── services/             # API servisleri
│   │   ├── utils/                # Yardımcı fonksiyonlar
│   │   └── constants/            # Sabitler
│   ├── features/                 # Özellik bazlı modüller
│   │   ├── auth/                 # Kimlik doğrulama
│   │   ├── dreams/               # Rüya analizi
│   │   ├── education/            # Eğitimler
│   │   ├── experts/              # Uzman danışmanlık
│   │   ├── library/              # Dijital kütüphane
│   │   └── profile/              # Kullanıcı profili
│   ├── shared/                   # Paylaşılan bileşenler
│   │   ├── widgets/              # Ortak widget'lar
│   │   └── models/               # Veri modelleri
│   └── main.dart                 # Ana uygulama dosyası
│
├── android/                      # Android platformu
├── ios/                          # iOS platformu
├── assets/                       # Görsel ve medya dosyaları
├── pubspec.yaml                  # Flutter bağımlılıkları
│
├── models/                       # Backend MongoDB modelleri
│   ├── User.js                   # Kullanıcı modeli
│   ├── Admin.js                  # Admin modeli
│   ├── Education.js              # Eğitim modeli
│   ├── Author.js                 # Yazar modeli
│   ├── Expert.js                 # Uzman modeli
│   ├── Session.js                # Seans modeli
│   ├── Appointment.js            # Randevu modeli
│   ├── Book.js                   # Kitap modeli
│   └── Content.js                # İçerik modeli
│
├── routes/                       # Backend API rotaları
│   ├── auth.js                   # Kimlik doğrulama
│   ├── admin.js                  # Admin yönetimi
│   ├── education.js              # Eğitim yönetimi
│   ├── authors.js                # Yazar yönetimi
│   ├── experts.js                # Uzman yönetimi
│   └── users.js                  # Kullanıcı yönetimi
│
├── middleware/                   # Backend ara yazılımlar
│   ├── auth.js                   # Kimlik doğrulama
│   ├── validation.js             # Veri doğrulama
│   └── upload.js                 # Dosya yükleme
│
├── views/                        # Admin panel HTML
│   └── admin.html                # Admin panel arayüzü
│
├── public/                       # Statik dosyalar
├── uploads/                      # Yüklenen dosyalar
│
├── firebase.json                 # Firebase yapılandırması
├── firestore.rules               # Firestore güvenlik kuralları
├── storage.rules                 # Storage güvenlik kuralları
│
├── server.js                     # Backend ana sunucu
├── package.json                  # Node.js bağımlılıkları
├── .gitignore                    # Git ignore kuralları
└── README.md                     # Bu dosya
```

## 🔌 API Endpoints

### Kimlik Doğrulama
- `POST /api/auth/login` - Admin girişi
- `GET /api/auth/profile` - Profil bilgileri
- `PUT /api/auth/profile` - Profil güncelleme
- `PUT /api/auth/change-password` - Şifre değiştirme
- `POST /api/auth/logout` - Çıkış yapma

### Admin Yönetimi
- `GET /api/admin` - Admin listesi
- `POST /api/admin` - Yeni admin oluşturma
- `PUT /api/admin/:id` - Admin güncelleme
- `DELETE /api/admin/:id` - Admin silme

### Eğitim Yönetimi
- `GET /api/education` - Eğitim listesi
- `POST /api/education` - Yeni eğitim oluşturma
- `PUT /api/education/:id` - Eğitim güncelleme
- `DELETE /api/education/:id` - Eğitim silme
- `PATCH /api/education/:id/publish` - Yayın durumu değiştirme

### Diğer Modüller
Benzer CRUD işlemleri tüm modüller için mevcuttur.

## 🔒 Güvenlik Özellikleri

- **JWT Token**: Güvenli kimlik doğrulama
- **Rate Limiting**: API istek sınırlaması
- **CORS**: Cross-origin istek kontrolü
- **Helmet**: HTTP güvenlik başlıkları
- **Input Validation**: Veri doğrulama
- **File Upload Security**: Güvenli dosya yükleme
- **Password Hashing**: Şifre şifreleme

## 📊 Dosya Yükleme

### Desteklenen Formatlar
- **Resimler**: JPEG, PNG, GIF, WebP
- **Dokümanlar**: PDF, EPUB, TXT
- **Ses**: MP3, WAV, OGG
- **Video**: MP4, WebM, OGG

### Özellikler
- Otomatik resim boyutlandırma
- Thumbnail oluşturma
- Dosya boyutu sınırlaması
- Güvenli dosya adlandırma

## 🚀 Production Deployment

### Environment Variables
```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://your-production-db
JWT_SECRET=your-super-secure-secret
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### PM2 ile Deployment
```bash
npm install -g pm2
pm2 start server.js --name "innerdreams-backend"
pm2 startup
pm2 save
```

### Nginx Konfigürasyonu
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 🧪 Test

```bash
# Test çalıştırma
npm test

# Coverage raporu
npm run test:coverage
```

## 📝 Loglama

Uygulama aşağıdaki logları tutar:
- Kimlik doğrulama işlemleri
- CRUD işlemleri
- Dosya yükleme işlemleri
- Hata logları
- Performans metrikleri

## 🔐 Güvenlik Notları

### Hassas Bilgiler
Aşağıdaki dosyalar **ASLA** git'e commit edilmemelidir:
- `.env` - Environment variables
- `service-account-key.json` - Firebase admin credentials
- `android/app/google-services.json` - Firebase Android config
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS config
- `android/key.properties` - Android signing keys
- `android/app/upload-keystore.jks` - Android keystore

### Güvenlik Özellikleri
- JWT token tabanlı authentication
- Firebase Security Rules
- API rate limiting
- Input validation ve sanitization
- Password hashing (bcrypt)
- CORS politikaları
- Helmet.js güvenlik başlıkları

## 📱 Uygulama Ekran Görüntüleri

Proje dizininde `flutter_01.png` - `flutter_08.png` dosyalarında uygulama ekran görüntüleri bulunmaktadır.

## 📄 Dökümanlar

- [Privacy Policy](PRIVACY_POLICY.md)
- [Terms of Service](TERMS_OF_SERVICE.md)
- [RevenueCat Integration Guide](REVENUECAT_INTEGRATION_GUIDE.md)

## 🤝 Katkıda Bulunma

Bu proje private bir repository'dir. Geliştirme takımı üyeleri:
1. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
2. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
3. Branch'inizi push edin (`git push origin feature/amazing-feature`)
4. Pull Request oluşturun

## 📞 İletişim

Teknik destek ve sorularınız için:
- Email: support@innerdreams.com
- Geliştirici: InnerDreams Team

---

**InnerDreams** - Rüya analizi ve kişisel gelişim platformu 🌙✨
