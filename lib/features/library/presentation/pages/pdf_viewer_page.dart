import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../../core/providers/locale_provider.dart';

class PDFViewerPage extends ConsumerStatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileSize;

  const PDFViewerPage({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
  });

  @override
  ConsumerState<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends ConsumerState<PDFViewerPage> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode == 200) {
        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25,
            tooltip: ref.watch(localeProvider).getString('zoom_in'),
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25,
            tooltip: ref.watch(localeProvider).getString('zoom_out'),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => _pdfViewerController.zoomLevel = 1.0,
            tooltip: ref.watch(localeProvider).getString('reset_zoom'),
          ),
        ],
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ref.watch(localeProvider).getString('loading_pdf'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
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
                        ref.watch(localeProvider).getString('error_loading_pdf'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                            _pdfBytes = null;
                          });
                          _loadPDF();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(ref.watch(localeProvider).getString('retry')),
                      ),
                    ],
                  ),
                )
              : _pdfBytes != null
                  ? SfPdfViewer.memory(
                      _pdfBytes!,
                      controller: _pdfViewerController,
                    )
                  : Container(),
      floatingActionButton: !_isLoading && _errorMessage == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "page_up",
                  onPressed: () => _pdfViewerController.previousPage(),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.keyboard_arrow_up, color: Theme.of(context).colorScheme.onPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "page_down",
                  onPressed: () => _pdfViewerController.nextPage(),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            )
          : null,
    );
  }
}
