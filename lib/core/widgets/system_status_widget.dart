import 'package:flutter/material.dart';
import '../services/hybrid_app_initializer.dart';
import '../services/hybrid_user_service.dart';

/// Hibrit sistem durumu widget'ı
class SystemStatusWidget extends StatelessWidget {
  const SystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blue),
            title: const Text(
              'Hibrit Sistem Durumu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Firebase + Cloudinary'),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => HybridAppInitializer.showSystemInfoDialog(context),
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: HybridAppInitializer.getSystemStatus(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final status = snapshot.data!;
              return Column(
                children: [
                  _buildStatusItem(
                    'Firebase Auth',
                    status['firebaseAuth'],
                    Icons.security,
                  ),
                  _buildStatusItem(
                    'Firestore',
                    status['firestore'],
                    Icons.storage,
                  ),
                  _buildStatusItem(
                    'Cloudinary',
                    status['cloudinary'],
                    Icons.cloud_upload,
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      status['userLoggedIn'] ? Icons.person : Icons.person_off,
                      color: status['userLoggedIn'] ? Colors.green : Colors.orange,
                    ),
                    title: const Text('Kullanıcı'),
                    subtitle: Text(status['currentUser']),
                    trailing: status['userLoggedIn']
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isReady, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: isReady ? Colors.green : Colors.red,
      ),
      title: Text(title),
      subtitle: Text(isReady ? 'Hazır' : 'Hazır Değil'),
      trailing: Icon(
        isReady ? Icons.check_circle : Icons.error,
        color: isReady ? Colors.green : Colors.red,
      ),
    );
  }
}

/// Sistem bilgileri kartı
class SystemInfoCard extends StatelessWidget {
  const SystemInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text(
              'Sistem Bilgileri',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🏗️ Mimari:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Firebase Auth - Kullanıcı yönetimi'),
                Text('• Firebase Firestore - Veri depolama'),
                Text('• Cloudinary - Dosya depolama (25GB ücretsiz)'),
                SizedBox(height: 8),
                Text('📊 Özellikler:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Kullanıcı rolleri ve izinleri'),
                Text('• İçerik yönetimi (PDF, resim, video)'),
                Text('• Premium içerik sistemi'),
                Text('• İstatistikler ve raporlama'),
                SizedBox(height: 8),
                Text('💾 Depolama:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Cloudinary: 25GB ücretsiz'),
                Text('• Firebase: Sınırsız (Firestore)'),
                Text('• Otomatik dosya optimizasyonu'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => HybridAppInitializer.showSystemInfoDialog(context),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Detaylar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final status = await HybridAppInitializer.getSystemStatus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sistem durumu: ${status['systemReady'] ? "Hazır" : "Hazır Değil"}'),
                        backgroundColor: status['systemReady'] ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
