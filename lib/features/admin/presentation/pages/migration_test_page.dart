import 'package:flutter/material.dart';
import '../../../../core/services/password_migration.dart';

class MigrationTestPage extends StatefulWidget {
  const MigrationTestPage({super.key});

  @override
  State<MigrationTestPage> createState() => _MigrationTestPageState();
}

class _MigrationTestPageState extends State<MigrationTestPage> {
  bool _isLoading = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Şifre Migration',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Şifre Migration',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bu sayfa Firebase\'deki users koleksiyonundaki şifreleri otomatik olarak hash\'ler.\n\nŞifresi olmayan kullanıcı hesaplarına varsayılan şifre "123456" eklenir.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _runMigration,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Migration Başlat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _showPasswordHashes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D2D44),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Test Şifre Hash\'leri Göster',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _runMigration() async {
    setState(() {
      _isLoading = true;
      _status = 'Migration başlıyor...';
    });

    try {
      await PasswordMigration.migrateAllPasswords();
      setState(() {
        _status = 'Migration başarıyla tamamlandı!\n\nUsers koleksiyonu şifreleri hash\'lendi.\nŞifresi olmayan hesaplara "123456" eklendi.';
      });
    } catch (e) {
      setState(() {
        _status = 'Migration hatası: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPasswordHashes() {
    setState(() {
      _status = 'Test şifreleri:\n\n';
    });
    
    PasswordMigration.printPasswordHashes();
    
    setState(() {
      _status += 'Terminal\'de hash\'leri görebilirsiniz.';
    });
  }
}
