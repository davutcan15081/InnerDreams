import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:io';
import '../models/content_model.dart';
import '../services/save_helper.dart';
import '../services/firebase_service.dart';
import '../services/cloudinary_service.dart';

class ContentViewer extends StatefulWidget {
  final ContentModel content;

  const ContentViewer({
    super.key,
    required this.content,
  });

  @override
  State<ContentViewer> createState() => _ContentViewerState();
}

class _ContentViewerState extends State<ContentViewer> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;
  
  // PDF Viewer için yeni değişkenler
  final PdfViewerController _pdfViewerController = PdfViewerController();
  Uint8List? _pdfBytes;
  bool _isPdfLoading = false;
  bool _useWebView = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    if (widget.content.type == ContentType.pdf) {
      // Debug için URL'yi kontrol et
      if (kDebugMode) {
        print('PDF Content URL: ${widget.content.url}');
        print('PDF Content Title: ${widget.content.title}');
        print('PDF Content Type: ${widget.content.type}');
      }
      _loadPdfFromUrl();
    }
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Progress göstergesi
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = 'Sayfa yüklenirken hata oluştu: ${error.description}';
            });
          },
        ),
      );
  }

  Widget _buildDocumentViewer() {
    if (widget.content.type == ContentType.pdf) {
      return _buildPdfViewer();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          widget.content.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B5CF6),
              ),
            ),
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _webViewController.reload();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                    child: const Text(
                      'Tekrar Dene',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    // Signed URL için WebView kullan
    if (_useWebView) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(
            widget.content.title,
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: _openPdfInBrowser,
              tooltip: 'Tarayıcıda Aç',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPdf,
              tooltip: 'İndir',
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B5CF6),
                ),
              ),
            if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _webViewController.reload();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                      child: const Text(
                        'Tekrar Dene',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    // Normal PDF viewer
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          widget.content.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _openFile,
            tooltip: 'Yerel Dosya Aç',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFile,
            tooltip: 'PDF Kaydet',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openPdfInBrowser,
            tooltip: 'Tarayıcıda Aç',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
            tooltip: 'İndir',
          ),
        ],
      ),
      body: _isPdfLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF8B5CF6),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'PDF yükleniyor...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : _pdfBytes != null
              ? SfPdfViewer.memory(
                  _pdfBytes!,
                  controller: _pdfViewerController,
                  enableDoubleTapZooming: true,
                  enableTextSelection: true,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  canShowPasswordDialog: true,
                  canShowPageLoadingIndicator: true,
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    setState(() {
                      _error = 'PDF yüklenemedi: ${details.error}';
                    });
                  },
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    setState(() {
                      _error = null;
                    });
                  },
                )
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'PDF yüklenirken hata oluştu: Exception: PDF yüklenemedi. HTTP Status: 401',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            // Debug bilgisi
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Debug Bilgisi:',
                                    style: TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'URL: ${widget.content.url.isEmpty ? "BOŞ URL!" : widget.content.url}',
                                    style: TextStyle(
                                      color: widget.content.url.isEmpty ? Colors.red : Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tip: ${widget.content.type}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      _error = null;
                                      _pdfBytes = null;
                                    });
                                    _loadPdfFromUrl();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Tekrar Dene'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: _openFile,
                                  icon: const Icon(Icons.folder_open),
                                  label: const Text('Yerel Dosya'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 80,
                            color: Colors.red,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'PDF Görüntüleyici',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'PDF dosyası yüklenmedi',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  void _openPdfInBrowser() async {
    final url = Uri.parse(widget.content.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF açılamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadPdf() async {
    final url = Uri.parse(widget.content.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF indirilemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// PDF dosyasını URL'den yükle
  Future<void> _loadPdfFromUrl() async {
    if (widget.content.type != ContentType.pdf) return;
    
    // URL kontrolü
    String pdfUrl = widget.content.url;
    if (pdfUrl.isEmpty) {
      setState(() {
        _isPdfLoading = false;
        _error = 'PDF URL\'si boş. Lütfen yerel dosya seçin.';
      });
      return;
    }
    
    debugPrint('🔍 PDF yükleme başlıyor...');
    debugPrint('📄 PDF URL: $pdfUrl');
    debugPrint('📄 PDF Title: ${widget.content.title}');
    debugPrint('📄 PDF Type: ${widget.content.type}');
    
    setState(() {
      _isPdfLoading = true;
      _error = null;
    });

    try {
      // Signed URL kontrolü
      if (pdfUrl.contains('s--') && pdfUrl.contains('--/')) {
        debugPrint('🔐 Signed URL tespit edildi');
        
        // Signed URL'i doğrula
        final isValid = await CloudinaryService.validateUrl(pdfUrl);
        if (!isValid) {
          debugPrint('❌ Signed URL geçersiz, yeniden oluşturuluyor...');
          
          // Public ID'yi çıkar ve yeni signed URL oluştur
          final publicId = _extractPublicIdFromSignedUrl(pdfUrl);
          if (publicId != null) {
            final newSignedUrl = CloudinaryService.getSignedUrlFromPublicId(
              publicId,
              isPdf: true,
            );
            
            debugPrint('🔄 Yeni Signed URL: $newSignedUrl');
            
            // WebView'ı yeni URL ile yükle
            setState(() {
              _isPdfLoading = false;
              _error = null;
              _useWebView = true;
            });
            
            _webViewController.loadRequest(Uri.parse(newSignedUrl));
            return;
          }
        }
        
        // Signed URL için WebView'da aç
        setState(() {
          _isPdfLoading = false;
          _error = null;
          _useWebView = true; // WebView kullan
        });
        
        // WebView'ı signed URL ile yükle
        _webViewController.loadRequest(Uri.parse(pdfUrl));
        return;
      }

      // Cloudinary URL'ini doğrula
      if (pdfUrl.contains('cloudinary.com')) {
        final isValid = await CloudinaryService.validateUrl(pdfUrl);
        if (!isValid) {
          throw Exception('Cloudinary URL\'si geçersiz veya erişilemez');
        }
      }

      // Dio ile PDF yükle
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/pdf, */*',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Cache-Control': 'no-cache',
        },
        validateStatus: (status) {
          return status != null && status < 500; // 4xx hatalarını da kabul et
        },
      ));
      
      debugPrint('🌐 HTTP Request başlıyor...');
      final response = await dio.get<List<int>>(
        pdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          maxRedirects: 5,
        ),
      );
      
      debugPrint('📡 HTTP Response Status: ${response.statusCode}');
      debugPrint('📡 HTTP Response Headers: ${response.headers}');
      
      if (response.statusCode == 200 && response.data != null) {
        debugPrint('✅ PDF başarıyla yüklendi, boyut: ${response.data!.length} bytes');
        setState(() {
          _pdfBytes = Uint8List.fromList(response.data!);
          _isPdfLoading = false;
        });
      } else {
        throw Exception('PDF yüklenemedi. HTTP Status: ${response.statusCode}');
      }
      
    } catch (e) {
      debugPrint('❌ PDF yükleme hatası: $e');
      setState(() {
        _isPdfLoading = false;
        _error = 'PDF yüklenirken hata oluştu: $e';
      });
    }
  }

  /// Dio ile PDF yükleme
  Future<void> _loadPdfWithDio() async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/pdf, */*',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept-Language': 'tr-TR,tr;q=0.9,en;q=0.8',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    ));
    
    final pdfUrl = widget.content.url.isEmpty ? '' : widget.content.url;
    final response = await dio.get<List<int>>(
      pdfUrl,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status! < 500, // 4xx hatalarını da kabul et
      ),
    );
    
    if (response.statusCode == 200 && response.data != null) {
      setState(() {
        _pdfBytes = Uint8List.fromList(response.data!);
        _isPdfLoading = false;
      });
    } else {
      throw Exception('PDF yüklenemedi. HTTP Status: ${response.statusCode}');
    }
  }

  /// HttpClient ile PDF yükleme (fallback)
  Future<void> _loadPdfWithHttpClient() async {
    final client = HttpClient();
    
    try {
      final pdfUrl = widget.content.url.isEmpty ? '' : widget.content.url;
      final request = await client.getUrl(Uri.parse(pdfUrl));
      request.headers.set('Accept', 'application/pdf, */*');
      request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
      request.headers.set('Accept-Language', 'tr-TR,tr;q=0.9,en;q=0.8');
      request.headers.set('Cache-Control', 'no-cache');
      request.headers.set('Pragma', 'no-cache');
      
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final bytes = await response.fold<Uint8List>(
          Uint8List(0),
          (previous, element) => Uint8List.fromList([...previous, ...element]),
        );
        
        setState(() {
          _pdfBytes = bytes;
          _isPdfLoading = false;
        });
      } else {
        throw Exception('PDF yüklenemedi. HTTP Status: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  /// Yerel cihazdan PDF dosyası aç
  Future<void> _openFile() async {
    FilePickerResult? filePickerResult = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (filePickerResult != null) {
      setState(() {
        _isPdfLoading = true;
      });

      try {
        if (kIsWeb) {
          _pdfBytes = filePickerResult.files.single.bytes;
        } else {
          _pdfBytes = await File(filePickerResult.files.single.path!).readAsBytes();
        }
        
        setState(() {
          _isPdfLoading = false;
        });
      } catch (e) {
        setState(() {
          _isPdfLoading = false;
          _error = 'Dosya açılırken hata oluştu: $e';
        });
      }
    }
  }

  /// PDF dosyasını yerel depolamaya kaydet
  Future<void> _saveFile() async {
    if (_pdfViewerController.pageCount > 0) {
      try {
        List<int> bytes = await _pdfViewerController.saveDocument();
        await SaveHelper.save(bytes, '${widget.content.title}.pdf');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF başarıyla kaydedildi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF kaydedilirken hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildVideoViewer() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          widget.content.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Video oynatıcı
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  if (_error != null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _webViewController.reload();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                            ),
                            child: const Text(
                              'Tekrar Dene',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Video bilgileri
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2D2D44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.content.description.isNotEmpty)
                  Text(
                    widget.content.description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.content.duration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDuration(widget.content.duration!),
                          style: const TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (widget.content.fileSize != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.content.fileSize!,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          widget.content.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Resim görüntüleyici
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  if (_error != null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _webViewController.reload();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                            ),
                            child: const Text(
                              'Tekrar Dene',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Resim bilgileri
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2D2D44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.content.description.isNotEmpty)
                  Text(
                    widget.content.description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                if (widget.content.fileSize != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.content.fileSize!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  /// Signed URL'den Public ID çıkar
  String? _extractPublicIdFromSignedUrl(String signedUrl) {
    try {
      // Signed URL formatı: https://res.cloudinary.com/cloud_name/resource_type/type/s--signature--/vtimestamp/public_id
      final regex = RegExp(r'/s--[^/]+--/v\d+/(.+)$');
      final match = regex.firstMatch(signedUrl);
      
      if (match != null) {
        final publicId = match.group(1);
        debugPrint('📄 Extracted Public ID: $publicId');
        return publicId;
      }
      
      debugPrint('❌ Public ID çıkarılamadı: $signedUrl');
      return null;
    } catch (e) {
      debugPrint('❌ Public ID çıkarma hatası: $e');
      return null;
    }
  }

  String _getViewerUrl() {
    final url = widget.content.url;
    
    switch (widget.content.type) {
      case ContentType.pdf:
        // PDF için birden fazla viewer seçeneği
        return _getPdfViewerUrl(url);
      case ContentType.document:
        // Word belgeleri için Google Docs Viewer
        return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}';
      case ContentType.image:
        // Resimler için doğrudan URL
        return url;
      case ContentType.video:
        // Videolar için doğrudan URL
        return url;
      case ContentType.audio:
        // Ses dosyaları için HTML5 audio player
        return _buildAudioPlayerHtml(url);
      case ContentType.text:
        // Metin dosyaları için doğrudan URL
        return url;
      default:
        return url;
    }
  }

  String _getPdfViewerUrl(String pdfUrl) {
    // PDF için basit HTML embed çözümü
    return _buildSimplePdfViewerHtml(pdfUrl);
  }

  String _buildSimplePdfViewerHtml(String pdfUrl) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                margin: 0;
                padding: 0;
                background-color: #1A1A2E;
                overflow: hidden;
            }
            .pdf-container {
                width: 100vw;
                height: 100vh;
                display: flex;
                flex-direction: column;
            }
            .pdf-header {
                background-color: #2D2D44;
                padding: 10px;
                color: white;
                text-align: center;
                font-family: Arial, sans-serif;
                font-size: 14px;
            }
            .pdf-viewer {
                flex: 1;
                width: 100%;
                height: calc(100vh - 50px);
                position: relative;
            }
            embed {
                width: 100%;
                height: 100%;
                border: none;
            }
            .loading {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                color: white;
                font-family: Arial, sans-serif;
                text-align: center;
            }
            .error-message {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                height: 100vh;
                color: white;
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 20px;
            }
            .error-icon {
                font-size: 64px;
                margin-bottom: 20px;
            }
            .retry-button {
                background-color: #8B5CF6;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 5px;
                cursor: pointer;
                margin-top: 20px;
            }
            .download-button {
                background-color: #10B981;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 5px;
                cursor: pointer;
                margin-top: 10px;
                text-decoration: none;
                display: inline-block;
            }
            .debug-info {
                position: absolute;
                top: 10px;
                left: 10px;
                background-color: rgba(0,0,0,0.7);
                color: white;
                padding: 5px;
                font-size: 10px;
                border-radius: 3px;
                max-width: 200px;
                word-break: break-all;
            }
        </style>
    </head>
    <body>
        <div class="pdf-container">
            <div class="pdf-header">
                PDF Görüntüleyici - ${widget.content.title}
            </div>
            <div class="debug-info" id="debugInfo">
                URL: $pdfUrl
            </div>
            <div class="pdf-viewer">
                <div class="loading" id="loadingDiv">
                    PDF yükleniyor...
                </div>
                <object data="$pdfUrl" type="application/pdf" id="pdfObject" width="100%" height="100%">
                    <p>PDF görüntülenemiyor. <a href="$pdfUrl" target="_blank">Dosyayı indirmek için tıklayın</a></p>
                </object>
            </div>
        </div>
        
        <div id="errorDiv" class="error-message" style="display: none;">
            <div class="error-icon">📄</div>
            <h2>PDF Yüklenemedi</h2>
            <p>PDF dosyası görüntülenemiyor. Bu durum şu sebeplerden olabilir:</p>
            <ul style="text-align: left; max-width: 400px;">
                <li>Dosya URL'si geçersiz</li>
                <li>İnternet bağlantısı problemi</li>
                <li>Dosya formatı desteklenmiyor</li>
                <li>Tarayıcı PDF desteği yok</li>
            </ul>
            <button class="retry-button" onclick="retryLoad()">Tekrar Dene</button>
            <a href="$pdfUrl" target="_blank" class="download-button">Dosyayı İndir</a>
        </div>
        
        <script>
            function showError() {
                document.getElementById('errorDiv').style.display = 'flex';
                document.getElementById('loadingDiv').style.display = 'none';
            }
            
            function hideLoading() {
                document.getElementById('loadingDiv').style.display = 'none';
            }
            
            function retryLoad() {
                location.reload();
            }
            
            // PDF object yüklendiğinde loading'i gizle
            const pdfObject = document.getElementById('pdfObject');
            pdfObject.addEventListener('load', function() {
                hideLoading();
            });
            
            pdfObject.addEventListener('error', function() {
                showError();
            });
            
            // 10 saniye sonra hala yüklenmemişse hata göster
            setTimeout(function() {
                if (document.getElementById('loadingDiv').style.display !== 'none') {
                    showError();
                }
            }, 10000);
        </script>
    </body>
    </html>
    ''';
  }


  String _buildAudioPlayerHtml(String audioUrl) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                margin: 0;
                padding: 20px;
                background-color: #1A1A2E;
                color: white;
                font-family: Arial, sans-serif;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
            }
            .audio-container {
                background-color: #2D2D44;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.3);
                text-align: center;
                max-width: 400px;
                width: 100%;
            }
            audio {
                width: 100%;
                margin: 20px 0;
            }
            h2 {
                margin: 0 0 20px 0;
                color: #8B5CF6;
            }
            .file-info {
                margin-top: 20px;
                font-size: 14px;
                color: #ccc;
            }
        </style>
    </head>
    <body>
        <div class="audio-container">
            <h2>Ses Dosyası</h2>
            <audio controls>
                <source src="$audioUrl" type="audio/mpeg">
                <source src="$audioUrl" type="audio/wav">
                <source src="$audioUrl" type="audio/ogg">
                Tarayıcınız ses dosyasını desteklemiyor.
            </audio>
            <div class="file-info">
                <p><strong>Dosya:</strong> ${widget.content.title}</p>
                ${widget.content.fileSize != null ? '<p><strong>Boyut:</strong> ${widget.content.fileSize}</p>' : ''}
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    // PDF için özel viewer kullan
    if (widget.content.type == ContentType.pdf) {
      return _buildPdfViewer();
    }

    // Diğer dosya türleri için URL'yi yükle
    final viewerUrl = _getViewerUrl();
    
    if (widget.content.type == ContentType.audio) {
      // Ses dosyaları için HTML content yükle
      _webViewController.loadHtmlString(viewerUrl);
    } else {
      // Diğer dosyalar için URL yükle
      _webViewController.loadRequest(Uri.parse(viewerUrl));
    }

    switch (widget.content.type) {
      case ContentType.video:
        return _buildVideoViewer();
      case ContentType.image:
        return _buildImageViewer();
      case ContentType.document:
      case ContentType.text:
      case ContentType.audio:
      default:
        return _buildDocumentViewer();
    }
  }
}
