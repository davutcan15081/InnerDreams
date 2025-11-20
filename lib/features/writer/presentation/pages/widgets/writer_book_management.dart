import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/services/firebase_service.dart';

class WriterBookManagement extends StatefulWidget {
  const WriterBookManagement({super.key});

  @override
  State<WriterBookManagement> createState() => _WriterBookManagementState();
}

class _WriterBookManagementState extends State<WriterBookManagement> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _contentUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isPremium = false;

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
                      'Kitaplarım',
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
                    label: Text(isMobile ? 'Yeni' : 'Yeni Kitap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.booksCollection.snapshots(),
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

                    final books = snapshot.data?.docs ?? [];

                    if (books.isEmpty) {
                      return const Center(
                        child: Text(
                          'Henüz kitap yok',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        final data = book.data() as Map<String, dynamic>;
                        
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
                                      'Yazar: ${data['author'] ?? 'Bilinmiyor'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Kategori: ${data['category'] ?? 'Genel'}',
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
                                    onPressed: () => _showEditDialog(book),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteBook(book.id),
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
    _showDialog('Yeni Kitap Ekle');
  }

  void _showEditDialog(DocumentSnapshot book) {
    final data = book.data() as Map<String, dynamic>;
    _titleController.text = data['title'] ?? '';
    _authorController.text = data['author'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _imageUrlController.text = data['imageUrl'] ?? '';
    _contentUrlController.text = data['contentUrl'] ?? '';
    _categoryController.text = data['category'] ?? '';
    _tagsController.text = (data['tags'] as List?)?.join(', ') ?? '';
    _isPremium = data['isPremium'] ?? false;
    _showDialog('Kitabı Düzenle', bookId: book.id);
  }

  void _showDialog(String title, {String? bookId}) {
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
              _buildTextField(_authorController, 'Yazar'),
              _buildTextField(_descriptionController, 'Açıklama', maxLines: 3),
              _buildTextField(_imageUrlController, 'Resim URL'),
              _buildTextField(_contentUrlController, 'İçerik URL'),
              _buildTextField(_categoryController, 'Kategori'),
              _buildTextField(_tagsController, 'Etiketler (virgülle ayırın)'),
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
                    activeColor: const Color(0xFF4CAF50),
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
              if (bookId != null) {
                _updateBook(bookId);
              } else {
                _addBook();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
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
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _addBook() async {
    final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    await FirebaseService.booksCollection.add({
      'title': _titleController.text,
      'author': _authorController.text,
      'description': _descriptionController.text,
      'imageUrl': _imageUrlController.text,
      'contentUrl': _contentUrlController.text,
      'category': _categoryController.text,
      'tags': tags,
      'isPremium': _isPremium,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _clearControllers();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _updateBook(String id) async {
    final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    await FirebaseService.booksCollection.doc(id).update({
      'title': _titleController.text,
      'author': _authorController.text,
      'description': _descriptionController.text,
      'imageUrl': _imageUrlController.text,
      'contentUrl': _contentUrlController.text,
      'category': _categoryController.text,
      'tags': tags,
      'isPremium': _isPremium,
    });

    _clearControllers();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteBook(String id) async {
    await FirebaseService.booksCollection.doc(id).delete();
  }

  void _clearControllers() {
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    _contentUrlController.clear();
    _categoryController.clear();
    _tagsController.clear();
    setState(() {
      _isPremium = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _contentUrlController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
