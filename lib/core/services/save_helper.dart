import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class SaveHelper {
  static Future<void> save(List<int> bytes, String fileName) async {
    if (kIsWeb) {
      await _saveOnWeb(bytes, fileName);
    } else {
      await _saveOnMobile(bytes, fileName);
    }
  }

  static Future<void> _saveOnWeb(List<int> bytes, String fileName) async {
    // Web platform için basit indirme
    // Bu implementasyon web platformunda çalışacak
    // Gerçek web implementasyonu için dart:html kullanılmalı
    throw UnsupportedError('Web platform için SaveHelper henüz implement edilmedi');
  }

  static Future<void> _saveOnMobile(List<int> bytes, String fileName) async {
    // Android, iOS, macOS ve Windows için
    String? directory = await FilePicker.platform.getDirectoryPath();

    if (directory != null) {
      final File file = File('$directory/$fileName');
      if (file.existsSync()) {
        await file.delete();
      }
      await file.writeAsBytes(bytes);
    }
  }
}
