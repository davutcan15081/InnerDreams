# 🌙 InnerDreams - Rüya Tabirleri ve AI Koçluk Uygulaması

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Kullanıcıların rüyalarını analiz etmelerine, kişisel gelişim eğitimleri almalarına ve uzmanlarla bağlantı kurmalarına olanak tanıyan full-stack mobil uygulama ve yönetim sistemi.

## 📱 Ekran Görüntüleri

<p align="center">
  <img src="flutter_01.png" width="200" alt="Ana Sayfa"/>
  <img src="flutter_02.png" width="200" alt="Rüya Analizi"/>
  <img src="flutter_03.png" width="200" alt="Eğitimler"/>
  <img src="flutter_04.png" width="200" alt="Uzmanlar"/>
</p>

## 🎯 Proje Hakkında

Bu proje, modern mobil uygulama geliştirme teknolojilerini kullanarak oluşturulmuş kapsamlı bir platformdur:

- **🎨 Flutter Mobil Uygulama**: iOS ve Android için cross-platform native uygulama
- **⚙️ Node.js Backend**: RESTful API ve admin panel
- **☁️ Firebase Integration**: Authentication, Firestore, Storage
- **💳 RevenueCat**: Abonelik ve ödeme yönetimi
- **🗄️ MongoDB**: Backend veritabanı

> **Not**: Bu repository portföy amaçlı paylaşılmaktadır. Gerçek API anahtarları ve hassas bilgiler repository'de bulunmamaktadır.

## ✨ Özellikler

### 📱 Mobil Uygulama

| Özellik | Açıklama |
|---------|----------|
| 🌙 **Rüya Analizi** | AI destekli rüya tabiri, detaylı sembol veritabanı, kişisel rüya günlüğü |
| 🎓 **Eğitim Platformu** | Video/ses/metin içerikler, kategori filtreleme, ilerleme takibi |
| 👨‍⚕️ **Uzman Danışmanlık** | Sertifikalı uzmanlarla online görüşme, randevu sistemi |
| 📚 **Dijital Kütüphane** | PDF/EPUB e-kitaplar, sesli kitaplar, offline okuma |
| 💳 **Abonelik Sistemi** | RevenueCat entegrasyonu, farklı paketler, ücretsiz deneme |
| 🔐 **Authentication** | Email ve Google Sign-In, Firebase Auth |
| 🎨 **Modern UI/UX** | Material Design, custom animations, responsive layout |
| 🌍 **Çoklu Dil** | Türkçe ve İngilizce dil desteği |

### ⚙️ Backend & Admin Panel

| Özellik | Açıklama |
|---------|----------|
| 📊 **Dashboard** | Real-time istatistikler, kullanıcı metrikleri, gelir raporları |
| 👥 **Kullanıcı Yönetimi** | CRUD işlemleri, abonelik yönetimi, aktivite takibi |
| 📚 **İçerik Yönetimi** | Eğitim, kitap, makale yönetimi, medya yükleme |
| 👨‍⚕️ **Uzman & Seans** | Uzman profilleri, randevu sistemi, takvim yönetimi |
| 🔒 **Güvenlik** | JWT authentication, role-based access control |
| 📤 **Dosya Yönetimi** | Multer + Sharp ile optimize edilmiş yükleme |
| 🔔 **Bildirimler** | Email notifications (Nodemailer) |

## 🛠️ Teknoloji Stack

### 📱 Frontend (Flutter)

```
├── Framework        : Flutter 3.0+ / Dart
├── State Management : Riverpod
├── Routing          : GoRouter
├── HTTP Client      : Dio
├── Local Storage    : Shared Preferences, Secure Storage
└── UI Libraries     : Shimmer, Cached Network Image, Syncfusion PDF Viewer
```

### ⚙️ Backend (Node.js)

```
├── Runtime          : Node.js 18+
├── Framework        : Express.js
├── Authentication   : JWT, Firebase Admin SDK
├── Validation       : Express Validator
├── Security         : Helmet, CORS, Rate Limiting
├── File Upload      : Multer
└── Image Processing : Sharp, Cloudinary
```

### ☁️ Cloud Services

```
├── Authentication   : Firebase Auth (Email, Google Sign-In)
├── Database         : Cloud Firestore, MongoDB Atlas
├── Storage          : Firebase Storage
├── Subscription     : RevenueCat
└── Hosting          : Firebase Hosting (Optional)
```

### 🎨 Key Technical Highlights

- **Clean Architecture**: Feature-based modular structure
- **State Management**: Centralized state with Riverpod
- **Responsive Design**: Adaptive layouts for tablets and phones
- **Offline Support**: Local caching and data persistence
- **Real-time Updates**: Firebase Realtime listeners
- **Security**: Environment variables, Firebase Security Rules
- **Performance**: Image optimization, lazy loading, pagination

## 🚀 Kurulum

> **Önemli**: Bu proje demo/portföy amaçlıdır. Çalıştırmak için kendi Firebase ve API anahtarlarınızı oluşturmanız gerekmektedir.

### Gereksinimler

- Flutter SDK 3.0+
- Node.js 18+
- Firebase hesabı
- MongoDB (local veya Atlas)
- RevenueCat hesabı (opsiyonel)

### Hızlı Başlangıç

```bash
# Repository'yi klonlayın
git clone https://github.com/davutcan15081/InnerDreams.git
cd InnerDreams

# Flutter bağımlılıkları
flutter pub get

# Backend bağımlılıkları
npm install

# Environment dosyasını oluşturun
cp env.example .env
# .env dosyasını kendi bilgilerinizle güncelleyin

# Uygulamayı çalıştırın
flutter run
```

### 🔧 Yapılandırma

1. **Firebase Setup**
   - Firebase Console'da yeni proje oluşturun
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
   - Authentication, Firestore, Storage'ı aktifleştirin

2. **Backend Setup**
   - `.env` dosyasında MongoDB URI'yi güncelleyin
   - JWT secret key ekleyin
   - Firebase service account key'i ekleyin

3. **RevenueCat (Opsiyonel)**
   - RevenueCat dashboard'da proje oluşturun
   - API key'i kodda güncelleyin

Detaylı kurulum için [INSTALLATION.md](docs/INSTALLATION.md) dosyasına bakabilirsiniz.

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

Katkılarınızı memnuniyetle karşılıyorum! Katkıda bulunmak için:

1. Bu repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

### Katkı Alanları

- 🐛 Bug fixes
- ✨ Yeni özellikler
- 📝 Dokümantasyon iyileştirmeleri
- 🌍 Çeviri ve lokalizasyon
- 🎨 UI/UX iyileştirmeleri
- ⚡ Performance optimizasyonları

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakabilirsiniz.

## 👨‍💻 Geliştirici

**Davut Can**
- GitHub: [@davutcan15081](https://github.com/davutcan15081)
- Email: davutcan15081@gmail.com

## 🙏 Teşekkürler

Bu proje aşağıdaki açık kaynak teknolojiler sayesinde mümkün oldu:
- [Flutter](https://flutter.dev) - UI Framework
- [Firebase](https://firebase.google.com) - Backend Services
- [Riverpod](https://riverpod.dev) - State Management
- [RevenueCat](https://www.revenuecat.com) - Subscription Management

## 📊 Proje İstatistikleri

![GitHub repo size](https://img.shields.io/github/repo-size/davutcan15081/InnerDreams)
![GitHub code size](https://img.shields.io/github/languages/code-size/davutcan15081/InnerDreams)
![GitHub language count](https://img.shields.io/github/languages/count/davutcan15081/InnerDreams)
![GitHub top language](https://img.shields.io/github/languages/top/davutcan15081/InnerDreams)

---

<p align="center">
  <b>InnerDreams</b> - Rüya analizi ve kişisel gelişim platformu 🌙✨
  <br/>
  Made with ❤️ using Flutter & Node.js
</p>
