import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cloudinary Servisi - Private/Authenticated dosyalar için signed URL desteği
class CloudinaryService {
  static const String cloudName = 'dmwnlzm4g'; // Cloudinary cloud name
  static const String uploadPreset = 'innerdreams_pdf'; // Unsigned upload preset
  static const String apiKey = '963778838914592'; // API Key
  static const String apiSecret = 'T9JtLQUzJqpE0IWbEb4rGdr7f-s'; // API Secret
  
  /// Signed URL oluşturma (Private dosyalar için)
  static String generateSignedUrl(String publicId, {
    String resourceType = 'image',
    String type = 'upload',
    int? expirationTime,
  }) {
    final timestamp = expirationTime ?? 
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600; // 1 saat geçerli
    
    // Public ID'den version kısmını temizle
    String cleanPublicId = publicId;
    if (publicId.contains('/upload/v')) {
      final parts = publicId.split('/upload/');
      if (parts.length > 1) {
        final afterUpload = parts[1];
        final versionMatch = RegExp(r'v\d+/(.+)').firstMatch(afterUpload);
        if (versionMatch != null) {
          cleanPublicId = versionMatch.group(1)!;
        }
      }
    }
    
    // Cloudinary resmi dokümantasyonuna göre signature oluştur
    // https://cloudinary.com/documentation/signatures#signature_generation
    final params = {
      'timestamp': timestamp.toString(),
      'type': type,
    };
    
    final signature = _generateSignature(params, apiSecret);
    
    debugPrint('🔐 Signed URL oluşturuluyor:');
    debugPrint('📄 Public ID: $cleanPublicId');
    debugPrint('📄 Timestamp: $timestamp');
    debugPrint('📄 Signature: $signature');
    debugPrint('📄 Resource Type: $resourceType');
    debugPrint('📄 Type: $type');
    
    // Cloudinary resmi signed URL formatı - DOĞRU FORMAT
    // https://res.cloudinary.com/{cloud_name}/{resource_type}/{type}/s--{signature}--/v{timestamp}/{public_id}
    final signedUrl = 'https://res.cloudinary.com/$cloudName/$resourceType/$type/'
        's--$signature--/v$timestamp/$cleanPublicId';
    
    debugPrint('✅ Signed URL: $signedUrl');
    return signedUrl;
  }
  
  /// Raw (PDF, video vb.) dosyalar için signed URL
  /// Cloudinary dokümantasyonuna göre PDF dosyaları için resource_type: raw kullanılmalı
  static String generateSignedRawUrl(String publicId, {int? expirationTime}) {
    debugPrint('📄 PDF için signed URL oluşturuluyor...');
    debugPrint('📄 Public ID: $publicId');
    
    final signedUrl = generateSignedUrl(
      publicId,
      resourceType: 'raw', // PDF dosyaları için raw resource type
      expirationTime: expirationTime,
    );
    
    debugPrint('✅ PDF Signed URL: $signedUrl');
    return signedUrl;
  }

  /// Resim yükleme (Unsigned)
  static Future<Map<String, dynamic>?> uploadImageUnsigned(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path)
      );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        debugPrint('✅ Resim başarıyla yüklendi: ${jsonResponse['secure_url']}');
        return jsonResponse;
      } else {
        debugPrint('❌ Resim yükleme hatası: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Resim yükleme hatası: $e');
      return null;
    }
  }

  /// PDF/Dosya yükleme (Signed - private)
  static Future<Map<String, dynamic>?> uploadFileSigned(
    File file, {
    String folder = 'innerdreams/pdfs',
    String type = 'private', // private veya authenticated
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final params = {
        'timestamp': timestamp.toString(),
        'folder': folder,
        'type': type,
        // resource_type signature'da olmamalı, sadece request'te olmalı
      };

      final signature = _generateSignature(params, apiSecret);

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/raw/upload'
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['timestamp'] = timestamp.toString();
      request.fields['api_key'] = apiKey;
      request.fields['signature'] = signature;
      request.fields['folder'] = folder;
      request.fields['type'] = type;
      request.fields['resource_type'] = 'raw'; // PDF için raw resource type
      
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path)
      );

      debugPrint('🔐 Signed PDF yükleme başlıyor...');
      debugPrint('URL: $url');
      debugPrint('Folder: $folder');
      debugPrint('Type: $type');
      debugPrint('Signature: $signature');

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      
      debugPrint('📡 Signed Response Status: ${response.statusCode}');
      debugPrint('📡 Signed Response Body: $responseString');
      
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        debugPrint('✅ Signed PDF başarıyla yüklendi: ${jsonResponse['secure_url']}');
        return jsonResponse;
      } else {
        final errorMessage = jsonResponse['error']?['message'] ?? 'Bilinmeyen hata';
        debugPrint('❌ Signed PDF yükleme hatası: $errorMessage');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Signed PDF yükleme hatası: $e');
      return null;
    }
  }

  /// Signature oluşturma - Cloudinary resmi dokümantasyonuna göre
  /// https://cloudinary.com/documentation/signatures#signature_generation
  static String _generateSignature(Map<String, dynamic> params, String apiSecret) {
    // Parametreleri alfabetik sıraya göre sırala
    final sortedKeys = params.keys.toList()..sort();
    
    // Parametreleri string formatına çevir
    final paramString = sortedKeys
        .map((key) => '$key=${params[key]}')
        .join('&');
    
    debugPrint('🔐 Signature oluşturma:');
    debugPrint('📄 Param String: $paramString');
    debugPrint('📄 API Secret: ${apiSecret.substring(0, 8)}...');
    
    // Cloudinary dokümantasyonuna göre: paramString + apiSecret
    final stringToSign = '$paramString$apiSecret';
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);
    final signature = hex.encode(digest.bytes);
    
    debugPrint('📄 String to Sign: $stringToSign');
    debugPrint('📄 Generated Signature: $signature');
    
    return signature;
  }

  /// Public ID'den signed URL oluştur
  static String getSignedUrlFromPublicId(String publicId, {bool isPdf = false}) {
    debugPrint('🔗 Signed URL oluşturuluyor...');
    debugPrint('📄 Public ID: $publicId');
    debugPrint('📄 Is PDF: $isPdf');
    
    if (publicId.isEmpty) {
      debugPrint('❌ Public ID boş!');
      return '';
    }
    
    String signedUrl;
    if (isPdf) {
      debugPrint('📄 PDF için signed URL oluşturuluyor...');
      signedUrl = generateSignedRawUrl(publicId);
    } else {
      debugPrint('🖼️ Resim için signed URL oluşturuluyor...');
      signedUrl = generateSignedUrl(publicId);
    }
    
    debugPrint('✅ Signed URL oluşturuldu: $signedUrl');
    
    if (signedUrl.isEmpty) {
      debugPrint('❌ Signed URL boş döndü!');
    }
    
    return signedUrl;
  }

  /// URL doğrulama
  static Future<bool> validateUrl(String url) async {
    try {
      debugPrint('🔍 URL doğrulanıyor: $url');
      
      final response = await http.head(Uri.parse(url));
      debugPrint('📡 Validation Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ URL geçerli');
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('❌ URL geçersiz - 401 Unauthorized');
        return false;
      } else if (response.statusCode == 403) {
        debugPrint('❌ URL geçersiz - 403 Forbidden');
        return false;
      } else if (response.statusCode == 404) {
        debugPrint('❌ URL geçersiz - 404 Not Found');
        return false;
      } else {
        debugPrint('❌ URL geçersiz - Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ URL doğrulama hatası: $e');
      return false;
    }
  }

  /// Test bağlantısı
  static Future<bool> testConnection() async {
    try {
      final testUrl = 'https://res.cloudinary.com/$cloudName/image/upload/test.jpg';
      debugPrint('🔍 Cloudinary bağlantı testi: $testUrl');
      
      final response = await http.get(Uri.parse(testUrl));
      debugPrint('📡 Test Response Status: ${response.statusCode}');
      
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      debugPrint('❌ Cloudinary bağlantı testi hatası: $e');
      return false;
    }
  }

  /// PDF'i harici tarayıcıda aç
  static Future<void> openPdfInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('✅ PDF harici tarayıcıda açıldı: $url');
      } else {
        debugPrint('❌ PDF açılamadı: $url');
      }
    } catch (e) {
      debugPrint('❌ PDF açma hatası: $e');
    }
  }
}