import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../../core/services/firebase_storage_service.dart';
import '../../../../../core/models/content_model.dart';

class WriterContentManagement extends StatefulWidget {
  const WriterContentManagement({super.key});

  @override
  State<WriterContentManagement> createState() => _WriterContentManagementState();
}

class _WriterContentManagementState extends State<WriterContentManagement> {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isPremium = false;
  ContentType _selectedContentType = ContentType.document;
  String? _selectedFileUrl;
  String? _selectedFileName;
  String? _selectedFileSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'İçeriklerim',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: Text(isMobile ? 'Yeni' : 'Yeni İçerik'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _storageService.loadWriterContent(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Hata: ${snapshot.error}'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    
                    final contents = snapshot.data ?? [];

                    if (contents.isEmpty) {
                      return Center(
                        child: Text(
                          'Henüz içerik yok',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        final content = contents[index];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content['title'] ?? 'Başlıksız',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      content['description'] ?? 'Açıklama yok',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: content['isPremium'] == true 
                                              ? Theme.of(context).colorScheme.primary 
                                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          content['isPremium'] == true ? 'Premium' : 'Ücretsiz',
                                          style: TextStyle(
                                            color: content['isPremium'] == true 
                                                ? Theme.of(context).colorScheme.primary 
                                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(content),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteContent(content['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddDialog() {
    _clearControllers();
    _showDialog('Yeni İçerik Ekle');
  }

  void _showEditDialog(Map<String, dynamic> content) {
    _titleController.text = content['title'] ?? '';
    _descriptionController.text = content['description'] ?? '';
    _contentController.text = content['content'] ?? '';
    _tagsController.text = (content['tags'] as List?)?.join(', ') ?? '';
    _isPremium = content['isPremium'] ?? false;
    
    // İçerik türü ve dosya bilgilerini ayarla
    _selectedContentType = ContentType.fromString(content['type'] ?? 'document');
    _selectedFileUrl = content['fileUrl'];
    _selectedFileName = content['fileName'];
    _selectedFileSize = content['fileSize'];
    
    _showDialog('İçeriği Düzenle', contentId: content['id']);
  }

  void _showDialog(String title, {String? contentId}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        title.contains('Düzenle') ? Icons.edit : Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Başlık',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description field
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Açıklama',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Content field
                        TextField(
                          controller: _contentController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'İçerik',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tags field
                        TextField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                            labelText: 'Etiketler',
                            hintText: 'Etiketler (virgülle ayırın)',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
              const SizedBox(height: 16),
                        // Content type dropdown
              DropdownButtonFormField<ContentType>(
                value: _selectedContentType,
                decoration: InputDecoration(
                            labelText: 'İçerik Türü',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                  border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                  ),
                  enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                  ),
                  focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          ),
                          dropdownColor: Theme.of(context).colorScheme.surface,
                items: [
                  DropdownMenuItem(
                    value: ContentType.document,
                    child: Row(
                      children: [
                        Text(ContentType.document.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(ContentType.document.displayName),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContentType.video,
                    child: Row(
                      children: [
                        Text(ContentType.video.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(ContentType.video.displayName),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContentType.pdf,
                    child: Row(
                      children: [
                        Text(ContentType.pdf.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(ContentType.pdf.displayName),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContentType.audio,
                    child: Row(
                      children: [
                        Text(ContentType.audio.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(ContentType.audio.displayName),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContentType.image,
                    child: Row(
                      children: [
                        Text(ContentType.image.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(ContentType.image.displayName),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ContentType.text,
                    child: Row(
                      children: [
                        Text(ContentType.text.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(ContentType.text.displayName),
                      ],
                    ),
                  ),
                ],
                onChanged: (ContentType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedContentType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
                        // File Upload Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                      'Dosya Yükleme',
                      style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                                  ),
                                ],
                    ),
                    const SizedBox(height: 8),
                              Text(
                      'İçerik türüne uygun dosya seçin',
                      style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              print('🔍 DEBUG - File pick button pressed!');
                              _pickFile();
                            },
                            icon: const Icon(Icons.upload_file),
                            label: Text(_selectedFileName ?? 'Dosya Seç'),
                            style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                            ),
                          ),
                        ),
                        if (_selectedFileUrl != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedFileUrl = null;
                                _selectedFileName = null;
                                _selectedFileSize = null;
                              });
                            },
                            icon: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                    if (_selectedFileUrl != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFileName ?? 'Dosya seçilmedi',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (_selectedFileSize != null)
                                    Text(
                                      _selectedFileSize!,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
                        const SizedBox(height: 16),
                        // Premium switch
              Container(
                          padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                children: [
                              Icon(
                                Icons.star,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Premium İçerik',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                  Switch(
                    value: _isPremium,
                    onChanged: (value) {
                      setState(() {
                        _isPremium = value;
                      });
                    },
                                activeColor: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'İptal',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (contentId != null) {
                              await _updateContent(contentId);
                            } else {
                              await _addContent();
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                          ),
                          child: Text(
                            'Kaydet',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        ),
      ),
    );
  }

  Future<void> _addContent() async {
    print('🔍 DEBUG - _addContent method called!');
    try {
      final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      // Debug için URL'yi kontrol et
      if (kDebugMode) {
        print('🔍 DEBUG - Saving content:');
        print('  - Title: ${_titleController.text}');
        print('  - Type: ${_selectedContentType.toString().split('.').last}');
        print('  - URL: ${_selectedFileUrl ?? "BOŞ!"}');
        print('  - FileName: $_selectedFileName');
        print('  - FileSize: $_selectedFileSize');
        print('  - Description: ${_descriptionController.text}');
        print('  - Content: ${_contentController.text}');
      }

      // Firebase Storage servisi ile içerik oluştur
      await _storageService.saveWriterContent(
        title: _titleController.text,
        description: _descriptionController.text,
        content: _contentController.text,
        fileUrl: _selectedFileUrl,
        fileName: _selectedFileName,
        fileSize: _selectedFileSize,
        fileType: _selectedFileName?.split('.').last,
        contentType: _selectedContentType.toString().split('.').last,
        tags: tags,
        isPremium: _isPremium,
        metadata: {
          'type': _selectedContentType.toString().split('.').last,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İçerik başarıyla eklendi')),
      );
      
      _clearControllers();
      setState(() {}); // UI'yı yenile

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _updateContent(String contentId) async {
    try {
      final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      await _storageService.updateContent(
        'writer_content',
        contentId,
        {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'content': _contentController.text,
        'fileUrl': _selectedFileUrl,
        'fileName': _selectedFileName,
        'fileSize': _selectedFileSize,
        'fileType': _selectedFileName?.split('.').last,
        'contentType': _selectedContentType.toString().split('.').last,
        'tags': tags,
        'isPremium': _isPremium,
          'type': _selectedContentType.toString().split('.').last,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İçerik başarıyla güncellendi')),
      );

      _clearControllers();
      setState(() {}); // UI'yı yenile

    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _deleteContent(String contentId) async {
    try {
      await _storageService.deleteContent('writer_content', contentId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İçerik başarıyla silindi')),
      );

      setState(() {}); // UI'yı yenile

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    print('🔍 DEBUG - _pickFile method called!');
    try {
      FileType fileType;
      switch (_selectedContentType) {
        case ContentType.pdf:
          fileType = FileType.custom;
          break;
        case ContentType.image:
          fileType = FileType.image;
          break;
        case ContentType.video:
          fileType = FileType.video;
          break;
        case ContentType.audio:
          fileType = FileType.audio;
          break;
        default:
          fileType = FileType.any;
      }

      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: _selectedContentType == ContentType.pdf ? ['pdf'] : null,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        final fileSize = '${(result.files.first.size / 1024 / 1024).toStringAsFixed(2)} MB';

        print('🔍 DEBUG - File picked:');
        print('  - File path: ${result.files.first.path}');
        print('  - File name: $fileName');
        print('  - File size: $fileSize');
        print('  - Content type: ${_selectedContentType.toString().split('.').last}');

        // Firebase Storage'a yükle
        print('📤 Uploading to Firebase Storage...');
        final fileUrl = await _storageService.uploadWriterContent(file, 'content');
        print('✅ Upload successful: $fileUrl');

        setState(() {
          _selectedFileUrl = fileUrl;
          _selectedFileName = fileName;
          _selectedFileSize = fileSize;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya yüklendi: $fileName')),
        );
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dosya yükleme hatası: $e')),
        );
    }
  }

  void _clearControllers() {
    print('🔍 DEBUG - _clearControllers called!');
    _titleController.clear();
    _descriptionController.clear();
    _contentController.clear();
    _tagsController.clear();
    setState(() {
      _isPremium = false;
      _selectedContentType = ContentType.document;
      _selectedFileUrl = null;
      _selectedFileName = null;
      _selectedFileSize = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}