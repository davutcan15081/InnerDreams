import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileSize;

  const ImageViewerPage({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
  });

  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  final TransformationController _transformationController = TransformationController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🖼️ ImageViewer - URL: ${widget.fileUrl}');
    print('🖼️ ImageViewer - FileName: ${widget.fileName}');
    print('🖼️ ImageViewer - FileSize: ${widget.fileSize}');
    
    // URL kontrolü
    if (widget.fileUrl.isEmpty) {
      print('❌ ImageViewer - URL is empty!');
    } else {
      print('✅ ImageViewer - URL is valid');
    }
    
    // Resim yükleme başlat
    print('🔄 ImageViewer - Starting image load...');
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _zoomIn() {
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.scale(1.25);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.scale(0.8);
    _transformationController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    print('🖼️ ImageViewer build() called - isLoading: $_isLoading, errorMessage: $_errorMessage');
    
    // URL kontrolü
    if (widget.fileUrl.isEmpty) {
      print('❌ ImageViewer - URL is empty in build()');
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
                'Resim yüklenemedi',
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.fileSize,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _zoomIn,
            tooltip: ref.watch(localeProvider).getString('zoom_in'),
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _zoomOut,
            tooltip: ref.watch(localeProvider).getString('zoom_out'),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _resetZoom,
            tooltip: ref.watch(localeProvider).getString('reset_zoom'),
          ),
        ],
        centerTitle: false,
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            widget.fileUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              print('🔄 Image loadingBuilder called - progress: $loadingProgress');
              if (loadingProgress == null) {
                print('✅ Image loaded successfully: ${widget.fileUrl}');
                // setState() during build hatasını önlemek için WidgetsBinding.instance.addPostFrameCallback kullan
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                });
                return child;
              }
              print('🔄 Image loading progress: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
              // setState() during build hatasını önlemek için WidgetsBinding.instance.addPostFrameCallback kullan
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ref.watch(localeProvider).getString('loading_image'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Image loading error: $error');
              print('❌ Image loading stackTrace: $stackTrace');
              print('❌ Image URL: ${widget.fileUrl}');
              // setState() during build hatasını önlemek için WidgetsBinding.instance.addPostFrameCallback kullan
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = error.toString();
                  });
                }
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Resim yüklenemedi',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hata: ${error.toString()}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'URL: ${widget.fileUrl}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
