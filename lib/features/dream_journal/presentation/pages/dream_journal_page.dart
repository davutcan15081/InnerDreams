import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';

class DreamJournalPage extends ConsumerStatefulWidget {
  const DreamJournalPage({super.key});

  @override
  ConsumerState<DreamJournalPage> createState() => _DreamJournalPageState();
}

class _DreamJournalPageState extends ConsumerState<DreamJournalPage> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _selectedSort = 'sort_by_date';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.6), 
                    Theme.of(context).colorScheme.secondary.withOpacity(0.6)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref.watch(localeProvider).getString('dream_journal_title'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text(ref.watch(localeProvider).getString('dream_journal_subtitle'), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 20),
                  _buildSummaryCards(),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 22),

            // Filter Options
            _buildFilterOptions(),
            const SizedBox(height: 16),

            // Sort Options
            _buildSortOptions(),
            const SizedBox(height: 22),

            // Dream List
            _buildDreamsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "dream_journal_add_button",
        onPressed: _addNewDream,
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final dreams = _getMockDreams();
    final int totalDreams = dreams.length;
    final int analyzedDreams = dreams.where((d) => d.isAnalyzed).length;
    final int favoriteDreams = dreams.where((d) => d.isFavorite).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard('Rüya', totalDreams),
        _buildSummaryCard('Analiz', analyzedDreams),
        _buildSummaryCard('Favori', favoriteDreams),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: TextEditingController(text: _searchQuery),
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          hintText: ref.watch(localeProvider).getString('search_dreams'),
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Expanded(child: _buildFilterButton(ref.watch(localeProvider).getString('all'), Icons.check_circle_outline)),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton(ref.watch(localeProvider).getString('favorites'), Icons.favorite_border)),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton('Analiz Edilmiş', Icons.psychology_outlined)),
      ],
    );
  }

  Widget _buildFilterButton(String title, IconData icon) {
    final isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title, 
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sıralama:', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSortButton(ref.watch(localeProvider).getString('sort_by_date'), Icons.calendar_today)),
            const SizedBox(width: 8),
            Expanded(child: _buildSortButton(ref.watch(localeProvider).getString('sort_by_title'), Icons.sort_by_alpha)),
            const SizedBox(width: 8),
            Expanded(child: _buildSortButton('Duruma Göre', Icons.sentiment_satisfied_alt)),
          ],
        ),
      ],
    );
  }

  Widget _buildSortButton(String title, IconData icon) {
    final isSelected = _selectedSort == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedSort = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title, 
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDreamsList() {
    final dreams = _getMockDreams();
    
    if (dreams.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: dreams.map((dream) => _buildDreamCard(dream)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(Icons.nights_stay_outlined, size: 60, color: Colors.white38),
          const SizedBox(height: 16),
          const Text('Henüz rüya girişin yok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('İlk rüyanı kaydetmeye başla', style: TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addNewDream,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Rüya Ekle', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamCard(DreamEntry dream) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewDream(dream),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getDreamIcon(dream.title),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dream.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('${dream.date.day} Ocak ${dream.date.year}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    if (dream.isAnalyzed) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.psychology_outlined, color: Color(0xFF7C4DFF), size: 20)),
                    if (dream.isFavorite) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.favorite, color: Colors.red, size: 20))
                    else const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.favorite_border, color: Colors.white54, size: 20)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(dream.description, style: const TextStyle(fontSize: 14, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: dream.tags.map((tag) => _buildTag(tag)).toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDreamIcon(String title) {
    Color bgColor;
    Widget iconWidget;

    switch (title) {
      case 'Uçma Rüyası':
        bgColor = Colors.green.shade700.withOpacity(0.2);
        iconWidget = const Icon(Icons.sentiment_satisfied_alt, color: Colors.greenAccent, size: 24);
        break;
      case 'Eski Ev Rüyası':
        bgColor = Colors.purple.shade700.withOpacity(0.2);
        iconWidget = const Icon(Icons.self_improvement, color: Color(0xFF7C4DFF), size: 24);
        break;
      case 'Kaybolma Rüyası':
        bgColor = Colors.orange.shade700.withOpacity(0.2);
        iconWidget = const Icon(Icons.sentiment_very_dissatisfied, color: Colors.orangeAccent, size: 24);
        break;
      default:
        bgColor = Colors.blueGrey.shade700.withOpacity(0.2);
        iconWidget = Icon(Icons.nights_stay, color: Colors.blueGrey.shade400, size: 24);
    }

    return CircleAvatar(radius: 20, backgroundColor: bgColor, child: iconWidget);
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Text('#$tag', style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }

  void _addNewDream() {
    // TODO: Navigate to add new dream page
  }

  void _viewDream(DreamEntry dream) {
    // TODO: Navigate to dream detail page
  }

  List<DreamEntry> _getMockDreams() {
    return [
      DreamEntry(
        id: '1',
        title: 'Uçma Rüyası',
        date: DateTime(2024, 1, 15),
        description: 'Gökyüzünde özgürce uçuyordum. Bulutların arasından geçerken kendimi çok hafif hissediyordum...',
        isAnalyzed: true,
        isFavorite: true,
        tags: ['flying', 'freedom', 'sky'],
      ),
      DreamEntry(
        id: '2',
        title: 'Eski Ev Rüyası',
        date: DateTime(2024, 1, 14),
        description: 'Çocukluğumun evinde dolaşıyordum. Her oda farklı anılarla doluydu...',
        isAnalyzed: false,
        isFavorite: false,
        tags: ['house', 'childhood', 'memories'],
      ),
      DreamEntry(
        id: '3',
        title: 'Kaybolma Rüyası',
        date: DateTime(2024, 1, 13),
        description: 'Büyük bir şehirde kaybolmuştum. Tanıdık yolları bulamıyordum...',
        isAnalyzed: true,
        isFavorite: false,
        tags: ['lost', 'city', 'road'],
      ),
    ];
  }
}

class DreamEntry {
  final String id;
  final String title;
  final DateTime date;
  final String description;
  final bool isAnalyzed;
  final bool isFavorite;
  final List<String> tags;

  DreamEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    this.isAnalyzed = false,
    this.isFavorite = false,
    this.tags = const [],
  });
}
