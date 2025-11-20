import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../../core/services/firebase_service.dart';
import '../../../../../core/models/content_model.dart';

class EducationManagement extends StatefulWidget {
  const EducationManagement({super.key});

  @override
  State<EducationManagement> createState() => _EducationManagementState();
}

class _EducationManagementState extends State<EducationManagement> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
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
                      'Eğitim Yönetimi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: Text(isMobile ? 'Yeni' : 'Yeni Eğitim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.educationsCollection.snapshots(),
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

                    final educations = snapshot.data?.docs ?? [];

                    if (educations.isEmpty) {
                      return const Center(
                        child: Text(
                          'Henüz eğitim yok',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: educations.length,
                      itemBuilder: (context, index) {
                        final education = educations[index];
                        final data = education.data() as Map<String, dynamic>;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1820),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? 'Başlık yok',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['description'] ?? 'Açıklama yok',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Süre: ${data['duration'] ?? 'Belirtilmemiş'}',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (data['isPremium'] == true)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Premium',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(education),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEducation(education.id),
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
    _showDialog('Yeni Eğitim Ekle');
  }

  void _showEditDialog(DocumentSnapshot education) {
    final data = education.data() as Map<String, dynamic>;
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _durationController.text = data['duration'] ?? '';
    _contentController.text = data['content'] ?? '';
    _isPremium = data['isPremium'] ?? false;
    _showDialog('Eğitimi Düzenle', educationId: education.id);
  }

  void _showDialog(String title, {String? educationId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F0E14),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_titleController, 'Başlık'),
              _buildTextField(_descriptionController, 'Açıklama', maxLines: 3),
              _buildTextField(_durationController, 'Süre'),
              
              // İçerik Türü Seçimi (Basitleştirilmiş)
              const SizedBox(height: 16),
              const Text('İçerik Türü:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<ContentType>(
                value: _selectedContentType,
                dropdownColor: const Color(0xFF2D2D44),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
                  ),
                ),
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
              
              // Dosya seçimi
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dosya Yükleme',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'İçerik türüne uygun dosya seçin',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.upload_file),
                            label: Text(_selectedFileName ?? 'Dosya Seç'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C4DFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                                    _selectedFileName!,
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
              
              Row(
                children: [
                  const Text('Premium İçerik:', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: _isPremium,
                    onChanged: (value) {
                      setState(() {
                        _isPremium = value;
                      });
                    },
                    activeColor: const Color(0xFF7C4DFF),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (educationId != null) {
                _updateEducation(educationId);
              } else {
                _addEducation();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white30),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      // İçerik türüne göre dosya türü belirle
      FileType fileType = FileType.any;
      
      switch (_selectedContentType) {
        case ContentType.video:
          fileType = FileType.video;
          break;
        case ContentType.audio:
          fileType = FileType.audio;
          break;
        case ContentType.image:
          fileType = FileType.image;
          break;
        case ContentType.pdf:
          fileType = FileType.custom;
          break;
        case ContentType.document:
        case ContentType.text:
        default:
          fileType = FileType.any;
          break;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: _getAllowedExtensions(),
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        
        // Dosya türü kontrolü
        if (!_isValidFileType(file.name)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seçilen dosya türü "${_selectedContentType.displayName}" için uygun değil.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        
        // Firebase Storage'a dosya yükle
        try {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          final ref = FirebaseStorage.instance.ref().child('educations/$fileName');
          
          final uploadTask = ref.putFile(File(file.path!));
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();
          
          setState(() {
            _selectedFileName = file.name;
            _selectedFileSize = _formatFileSize(file.size);
            _selectedFileUrl = downloadUrl;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dosya başarıyla yüklendi!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dosya yüklenirken hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya seçilirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<String> _getAllowedExtensions() {
    switch (_selectedContentType) {
      case ContentType.video:
        return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'];
      case ContentType.audio:
        return ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a'];
      case ContentType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
      case ContentType.pdf:
        return ['pdf'];
      case ContentType.document:
        return ['doc', 'docx', 'txt', 'rtf'];
      case ContentType.text:
        return ['txt', 'md', 'rtf'];
    }
  }

  bool _isValidFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return _getAllowedExtensions().contains(extension);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _addEducation() async {
    await FirebaseService.educationsCollection.add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'duration': _durationController.text,
      'type': _selectedContentType.toString(),
      'url': _selectedFileUrl ?? '',
      'fileSize': _selectedFileSize,
      'isPremium': _isPremium,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _clearControllers();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _updateEducation(String id) async {
    await FirebaseService.educationsCollection.doc(id).update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'duration': _durationController.text,
      'type': _selectedContentType.toString(),
      'url': _selectedFileUrl ?? '',
      'fileSize': _selectedFileSize,
      'isPremium': _isPremium,
    });

    _clearControllers();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteEducation(String id) async {
    await FirebaseService.educationsCollection.doc(id).delete();
  }

  void _clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _durationController.clear();
    _contentController.clear();
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
    _durationController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}