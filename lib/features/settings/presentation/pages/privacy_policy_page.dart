import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              '1. GENEL BİLGİLER',
              'InnerDreams uygulaması ("Uygulama"), kullanıcıların rüya yorumlama ve içsel yolculuk deneyimini desteklemek amacıyla geliştirilmiştir. Bu gizlilik politikası, kişisel verilerinizin nasıl toplandığını, kullanıldığını ve korunduğunu açıklar.',
            ),
            
            _buildSection(
              context,
              '2. TOPLANAN VERİLER',
              'Uygulama aşağıdaki verileri toplar:\n'
              '• Hesap bilgileri (e-posta, isim)\n'
              '• Rüya kayıtları ve yorumları\n'
              '• Uygulama kullanım istatistikleri\n'
              '• Cihaz bilgileri (model, işletim sistemi)',
            ),
            
            _buildSection(
              context,
              '3. VERİ KULLANIMI',
              'Toplanan veriler şu amaçlarla kullanılır:\n'
              '• Hesap yönetimi ve kimlik doğrulama\n'
              '• Rüya analizi ve yorumlama hizmetleri\n'
              '• Uygulama performansını iyileştirme\n'
              '• Premium özelliklerin sunulması',
            ),
            
            _buildSection(
              context,
              '4. VERİ PAYLAŞIMI',
              'Kişisel verileriniz:\n'
              '• Üçüncü taraflarla paylaşılmaz\n'
              '• Yasal zorunluluklar dışında açıklanmaz\n'
              '• Firebase ve RevenueCat gibi güvenli servislerle sınırlı olarak paylaşılır',
            ),
            
            _buildSection(
              context,
              '5. VERİ GÜVENLİĞİ',
              '• Firebase güvenlik altyapısı kullanılır\n'
              '• Veriler şifrelenmiş olarak saklanır\n'
              '• Düzenli güvenlik güncellemeleri yapılır',
            ),
            
            _buildSection(
              context,
              '6. KULLANICI HAKLARI',
              'Kullanıcılar şu haklara sahiptir:\n'
              '• Verilerini görüntüleme\n'
              '• Verilerini düzeltme\n'
              '• Hesap silme\n'
              '• Veri işlemeyi reddetme',
            ),
            
            _buildSection(
              context,
              '7. ÇEREZLER',
              'Uygulama analitik ve performans çerezleri kullanır. Bu çerezler kullanıcı deneyimini iyileştirmek amacıyla kullanılır.',
            ),
            
            _buildSection(
              context,
              '8. ÇOCUKLARIN GİZLİLİĞİ',
              'Uygulama 13 yaş altı çocuklardan bilerek veri toplamaz. 13 yaş altı kullanıcıların ebeveyn izni olmadan uygulamayı kullanması önerilmez.',
            ),
            
            _buildSection(
              context,
              '9. DEĞİŞİKLİKLER',
              'Bu gizlilik politikası gerektiğinde güncellenebilir. Önemli değişiklikler kullanıcılara bildirilir.',
            ),
            
            _buildSection(
              context,
              '10. İLETİŞİM',
              'Sorularınız için: support@innerdreams.com\n'
              'Adres: InnerDreams Teknoloji A.Ş.\n'
              'İstanbul, Türkiye',
            ),
            
            const SizedBox(height: 30),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Bu gizlilik politikasını kabul ederek uygulamayı kullanmaya devam ediyorsunuz.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Son Güncelleme: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
