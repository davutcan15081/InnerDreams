import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/services/firebase_service.dart';

class SessionManagement extends StatefulWidget {
  const SessionManagement({super.key});

  @override
  State<SessionManagement> createState() => _SessionManagementState();
}

class _SessionManagementState extends State<SessionManagement> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _expertController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
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
                      'Seans Yönetimi',
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
                    label: Text(isMobile ? 'Yeni' : 'Yeni Seans'),
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
                  stream: FirebaseService.sessionsCollection.snapshots(),
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

                    final sessions = snapshot.data?.docs ?? [];

                    if (sessions.isEmpty) {
                      return const Center(
                        child: Text(
                          'Henüz seans yok',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final data = session.data() as Map<String, dynamic>;
                        
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
                                      'Uzman: ${data['expert'] ?? 'Belirtilmemiş'}',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Fiyat: ${data['price'] ?? 'Belirtilmemiş'}',
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
                                    onPressed: () => _showEditDialog(session),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteSession(session.id),
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
    _showDialog('Yeni Seans Ekle');
  }

  void _showEditDialog(DocumentSnapshot session) {
    final data = session.data() as Map<String, dynamic>;
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _expertController.text = data['expert'] ?? '';
    _priceController.text = data['price'] ?? '';
    _isPremium = data['isPremium'] ?? false;
    _showDialog('Seansı Düzenle', sessionId: session.id);
  }

  void _showDialog(String title, {String? sessionId}) {
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
              _buildTextField(_expertController, 'Uzman'),
              _buildTextField(_priceController, 'Fiyat'),
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
              if (sessionId != null) {
                _updateSession(sessionId);
              } else {
                _addSession();
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

  Future<void> _addSession() async {
    await FirebaseService.sessionsCollection.add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'expert': _expertController.text,
      'price': _priceController.text,
      'isPremium': _isPremium,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _clearControllers();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _updateSession(String id) async {
    await FirebaseService.sessionsCollection.doc(id).update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'expert': _expertController.text,
      'price': _priceController.text,
      'isPremium': _isPremium,
    });

    _clearControllers();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteSession(String id) async {
    await FirebaseService.sessionsCollection.doc(id).delete();
  }

  void _clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _expertController.clear();
    _priceController.clear();
    setState(() {
      _isPremium = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _expertController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}