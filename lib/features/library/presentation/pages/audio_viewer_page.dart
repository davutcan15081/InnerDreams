import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/providers/locale_provider.dart';

class AudioViewerPage extends ConsumerStatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileSize;

  const AudioViewerPage({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
  });

  @override
  ConsumerState<AudioViewerPage> createState() => _AudioViewerPageState();
}

class _AudioViewerPageState extends ConsumerState<AudioViewerPage> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🎵 AudioViewer - URL: ${widget.fileUrl}');
    print('🎵 AudioViewer - FileName: ${widget.fileName}');
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🎵 WebView page started: $url');
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            print('🎵 WebView page finished: $url');
            setState(() {
              _isLoading = false;
            });
            // JavaScript ile audio durumunu kontrol et
            _webViewController.runJavaScript('''
              console.log('Audio element check:');
              const audio = document.querySelector('audio');
              if (audio) {
                console.log('Audio element found');
                console.log('Audio src:', audio.src);
                console.log('Audio readyState:', audio.readyState);
                console.log('Audio networkState:', audio.networkState);
                console.log('Audio duration:', audio.duration);
                console.log('Audio currentTime:', audio.currentTime);
              } else {
                console.log('Audio element not found');
              }
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView error: ${error.description} (Code: ${error.errorCode})');
            // WebView error'ları genellikle normal, ses dosyası yine de çalışabilir
            if (error.errorCode != -2 && error.errorCode != -1) { // -2 = net::ERR_FAILED, -1 = net::ERR_FAILED, genellikle normal
              setState(() {
                _isLoading = false;
                _errorMessage = 'Ses dosyası yüklenirken hata oluştu: ${error.description}';
              });
            } else {
              print('ℹ️ WebView error ignored (normal behavior)');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🎵 Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    // HTML5 audio player ile ses dosyasını oynat
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${widget.fileName}</title>
        <style>
            body {
                margin: 0;
                padding: 20px;
                background-color: #1a1a1a;
                color: white;
                font-family: Arial, sans-serif;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
            }
            .container {
                text-align: center;
                max-width: 600px;
                width: 100%;
            }
            h1 {
                color: #ffffff;
                margin-bottom: 20px;
                font-size: 24px;
            }
            audio {
                width: 100%;
                max-width: 500px;
                margin: 20px 0;
            }
            .info {
                color: #cccccc;
                margin-top: 20px;
                font-size: 14px;
            }
            .controls {
                margin-top: 20px;
            }
            button {
                background-color: #4CAF50;
                color: white;
                border: none;
                padding: 10px 20px;
                margin: 5px;
                border-radius: 5px;
                cursor: pointer;
                font-size: 16px;
            }
            button:hover {
                background-color: #45a049;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>${widget.fileName}</h1>
            <audio controls preload="metadata" onerror="showError()" onloadstart="console.log('Audio loadstart')" oncanplay="console.log('Audio canplay')" onloadeddata="console.log('Audio loadeddata')">
                <source src="${widget.fileUrl}" type="audio/mpeg">
                <source src="${widget.fileUrl}" type="audio/wav">
                <source src="${widget.fileUrl}" type="audio/aac">
                <source src="${widget.fileUrl}" type="audio/ogg">
                <source src="${widget.fileUrl}" type="audio/mp3">
                Tarayıcınız ses dosyasını desteklemiyor.
            </audio>
            <div class="info">
                <p>Dosya Boyutu: ${widget.fileSize}</p>
                <p>Dosya Türü: Ses Dosyası</p>
                <p>URL: ${widget.fileUrl}</p>
            </div>
            <div id="error" style="display: none; color: #ff6b6b; margin-top: 20px; padding: 10px; background-color: #2d1b1b; border-radius: 5px;">
                ❌ Ses dosyası yüklenemedi. Lütfen dosya URL'sini kontrol edin.
            </div>
            <div class="controls">
                <button onclick="document.querySelector('audio').play()">▶️ Oynat</button>
                <button onclick="document.querySelector('audio').pause()">⏸️ Duraklat</button>
                <button onclick="document.querySelector('audio').currentTime = 0">⏮️ Başa Sar</button>
            </div>
        </div>
        <script>
            function showError() {
                document.getElementById('error').style.display = 'block';
                console.log('Audio loading error');
            }
            
            // Audio yükleme hatası kontrolü
            document.querySelector('audio').addEventListener('error', function(e) {
                console.log('Audio error:', e);
                showError();
            });
            
            // Audio yükleme başarı kontrolü
            document.querySelector('audio').addEventListener('loadeddata', function() {
                console.log('Audio loaded successfully');
            });
            
            // Audio yükleme başlangıcı
            document.querySelector('audio').addEventListener('loadstart', function() {
                console.log('Audio loading started');
            });
        </script>
    </body>
    </html>
    ''';

    _webViewController.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    // URL kontrolü
    if (widget.fileUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ses dosyası yüklenemedi',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Dosya URL\'si bulunamadı',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.fileSize.isNotEmpty)
              Text(
                widget.fileSize,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _webViewController.reload();
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: ref.watch(localeProvider).getString('retry'),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'Kapat',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hata',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _initializeWebView();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(ref.watch(localeProvider).getString('retry')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _webViewController),
          if (_isLoading && _errorMessage == null)
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ses dosyası yükleniyor...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
