import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/content_display_service.dart';
import 'pdf_viewer_page.dart';
import 'image_viewer_page.dart';
import 'video_viewer_page.dart';
import 'doc_viewer_page.dart';
import 'audio_viewer_page.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final ContentDisplayService _contentService = ContentDisplayService();
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _contentService.loadPublicContent();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredBooks {
    List<Map<String, dynamic>> filtered = _books;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((book) {
        final title = (book['title'] ?? '').toLowerCase();
        final author = (book['author'] ?? '').toLowerCase();
        final description = (book['description'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return title.contains(query) || 
               author.contains(query) || 
               description.contains(query);
      }).toList();
    }

    if (_selectedCategory != 'all') {
      filtered = filtered.where((book) {
        return book['authorType'] == _selectedCategory;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          ref.watch(localeProvider).getString('library'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: ref.watch(localeProvider).getString('search_books'),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Categories section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watch(localeProvider).getString('categories'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryButton('all', ref.watch(localeProvider).getString('all_categories'), Icons.grid_view),
                      const SizedBox(width: 12),
                      _buildCategoryButton('doctor', ref.watch(localeProvider).getString('doctor_content'), Icons.medical_services),
                      const SizedBox(width: 12),
                      _buildCategoryButton('writer', ref.watch(localeProvider).getString('writer_content'), Icons.edit),
                      const SizedBox(width: 12),
                      _buildCategoryButton('education', ref.watch(localeProvider).getString('education_content'), Icons.school),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: _isLoading
                ? Center(
            child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : _filteredBooks.isEmpty
                    ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                            Icon(
                              Icons.library_books_outlined,
                  size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                              ref.watch(localeProvider).getString('no_books_found'),
                              style: TextStyle(
                    fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ref.watch(localeProvider).getString('try_different_search'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBooks,
                        color: Theme.of(context).colorScheme.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = _filteredBooks[index];
                            return _buildBookCard(book);
                          },
                        ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image placeholder and title
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                // File type icon
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFileIcon(book['contentType'] ?? book['fileType'] ?? 'pdf'),
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                // Premium badge
                if (book['isPremium'] == true)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                  children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ref.watch(localeProvider).getString('premium'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Title overlay
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    book['title'] ?? ref.watch(localeProvider).getString('no_title_library'),
                              style: TextStyle(
                      fontSize: 18,
                                fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      shadows: [
                        Shadow(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File info section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author info
                    _buildInfoRow(
                      Icons.person_outline,
                      ref.watch(localeProvider).getString('author'),
                      book['author'] ?? ref.watch(localeProvider).getString('unknown_author'),
                    ),
                    const SizedBox(height: 8),
                    // File type
                    _buildInfoRow(
                      Icons.insert_drive_file_outlined,
                      ref.watch(localeProvider).getString('file_type'),
                      book['contentType'] ?? book['fileType'] ?? 'pdf',
                    ),
                    const SizedBox(height: 8),
                    // File name
                    _buildInfoRow(
                      Icons.description_outlined,
                      ref.watch(localeProvider).getString('file_name'),
                      book['fileName'] ?? book['title'] ?? ref.watch(localeProvider).getString('no_title_library'),
                    ),
                    const SizedBox(height: 8),
                    // File size
                    if (book['fileSize'] != null && book['fileSize'].isNotEmpty)
                      _buildInfoRow(
                        Icons.storage_outlined,
                        ref.watch(localeProvider).getString('file_size'),
                        book['fileSize'],
                      ),
                    if (book['fileSize'] != null && book['fileSize'].isNotEmpty) const SizedBox(height: 8),
                    // Price
                    if (book['price'] != null && book['price'] != '0' && book['price'].isNotEmpty)
                      _buildInfoRow(
                        Icons.attach_money_outlined,
                        ref.watch(localeProvider).getString('price'),
                        '${book['price']} ${ref.watch(localeProvider).getString('tl_currency')}',
                      ),
                    if (book['price'] != null && book['price'] != '0' && book['price'].isNotEmpty) const SizedBox(height: 12),
                    // Description
                    Text(
                      ref.watch(localeProvider).getString('description'),
                      style: TextStyle(
                          fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['description'] ?? ref.watch(localeProvider).getString('no_description_library'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13,
                        height: 1.4,
                        ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book['authorType'] ?? 'content',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Premium/Free status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: book['isPremium'] == true 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: book['isPremium'] == true 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                        Icon(
                        book['isPremium'] == true ? Icons.star : Icons.lock_open,
                        color: book['isPremium'] == true 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        book['isPremium'] == true 
                          ? ref.watch(localeProvider).getString('premium_content')
                          : ref.watch(localeProvider).getString('free_content'),
                        style: TextStyle(
                          color: book['isPremium'] == true 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                    ),
                  ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (book['isPremium'] == true) {
                        _purchaseBook(book);
                      } else {
                        _openFile(book);
                      }
                    },
                    icon: Icon(
                      book['isPremium'] == true 
                        ? Icons.shopping_cart_outlined 
                        : Icons.open_in_new,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(
                      book['isPremium'] == true 
                        ? ref.watch(localeProvider).getString('purchase')
                        : ref.watch(localeProvider).getString('open_file'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
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


  Widget _buildCategoryButton(String value, String label, IconData icon) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'video':
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _openFile(Map<String, dynamic> book) {
    // Debug: Print book data
    print('🔍 DEBUG - Book data:');
    print('  - fileUrl: ${book['fileUrl']}');
    print('  - fileName: ${book['fileName']}');
    print('  - fileSize: ${book['fileSize']}');
    print('  - book keys: ${book.keys.toList()}');
    print('  - full book: $book');
    
    final fileUrl = book['fileUrl'];
    final fileName = book['fileName'] ?? book['title'] ?? 'Dosya';
    final fileSize = book['fileSize'] ?? '';
    
    // Get content type from multiple possible fields
    String contentType = book['contentType'] ?? 
                        book['fileType'] ?? 
                        book['type'] ?? 
                        book['metadata']?['type'] ?? 
                        'pdf';
    
    print('  - contentType: $contentType');
    
    // If contentType is still generic, try to determine from file extension
    if (contentType == 'document' || contentType == 'text') {
      final extension = fileName.split('.').last.toLowerCase();
      print('  - extension: $extension');
      switch (extension) {
        case 'pdf':
          contentType = 'pdf';
          break;
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
        case 'webp':
          contentType = 'image';
          break;
        case 'mp4':
        case 'avi':
        case 'mov':
        case 'mkv':
          contentType = 'video';
          break;
        case 'mp3':
        case 'wav':
        case 'aac':
          contentType = 'audio';
          break;
        case 'txt':
        case 'doc':
        case 'docx':
          contentType = 'text';
          break;
      }
      print('  - final contentType: $contentType');
    }

    if (fileUrl == null || fileUrl.toString().isEmpty) {
      print('❌ ERROR - fileUrl is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya bulunamadı: $fileName'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      _showFileNotFoundDialog(fileName, fileSize);
      return;
    }

    try {
      switch (contentType.toLowerCase()) {
        case 'pdf':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerPage(
                fileUrl: fileUrl,
                fileName: fileName,
                fileSize: fileSize,
              ),
            ),
          );
          break;
        case 'image':
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerPage(
                fileUrl: fileUrl,
                fileName: fileName,
                fileSize: fileSize,
              ),
            ),
          );
          break;
        case 'video':
        case 'mp4':
        case 'avi':
        case 'mov':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoViewerPage(
                fileUrl: fileUrl,
                fileName: fileName,
                fileSize: fileSize,
              ),
            ),
          );
          break;
        case 'audio':
        case 'mp3':
        case 'wav':
        case 'aac':
          // For audio files, open in-app audio viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioViewerPage(
                fileUrl: fileUrl,
                fileName: fileName,
                fileSize: fileSize,
              ),
            ),
          );
          break;
        case 'text':
        case 'txt':
        case 'doc':
        case 'docx':
          // For text files, open in-app DOC viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocViewerPage(
                fileUrl: fileUrl,
                fileName: fileName,
                fileSize: fileSize,
              ),
            ),
          );
          break;
        default:
          _launchUrl(fileUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ref.watch(localeProvider).getString('error_opening_file')}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.watch(localeProvider).getString('error_opening_file')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }


  void _showFileNotFoundDialog(String fileName, String fileSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Dosya Bulunamadı',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dosya: $fileName',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (fileSize.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Boyut: $fileSize',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
              const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu dosya henüz yüklenmemiş veya silinmiş olabilir. Lütfen yazar ile iletişime geçin.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                  ),
                ),
              ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tamam',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _purchaseBook(Map<String, dynamic> book) {
    // TODO: Implement purchase logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ref.watch(localeProvider).getString('purchase')}: ${book['title']}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}