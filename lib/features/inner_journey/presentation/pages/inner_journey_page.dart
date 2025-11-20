import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/journey_provider.dart';
import '../../../../core/models/journey_model.dart';

class InnerJourneyPage extends ConsumerStatefulWidget {
  const InnerJourneyPage({super.key});

  @override
  ConsumerState<InnerJourneyPage> createState() => _InnerJourneyPageState();
}

class _InnerJourneyPageState extends ConsumerState<InnerJourneyPage> {
  String _selectedTab = 'journey';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Selector
            _buildTabSelector(),
            const SizedBox(height: 22),
            
            // Content based on selected tab
            if (_selectedTab == 'journey') ...[
              // Level Progress Card
              _buildLevelProgressCard(),
              const SizedBox(height: 22),
              
              // Weekly Progress & Completed Tasks
              _buildProgressCards(),
              const SizedBox(height: 22),
              
              // Active Tasks
              _buildActiveTasks(),
              const SizedBox(height: 22),
              
              // Achievements
              _buildAchievements(),
            ] else if (_selectedTab == 'map') ...[
              // Journey Map
              _buildJourneyMap(),
              const SizedBox(height: 22),
              
              // Symbol Education
              _buildSymbolEducation(),
              const SizedBox(height: 22),
              
              // Personal Insights
              _buildPersonalInsights(),
            ],
          ],
        ),
      ),
      floatingActionButton: _selectedTab == 'journey' ? FloatingActionButton.extended(
        heroTag: "inner_journey_add_button",
        onPressed: _addNewTask,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(ref.watch(localeProvider).getString('new_task'), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7C4DFF),
      ) : null,
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton(ref.watch(localeProvider).getString('journey'), Icons.explore, _selectedTab == 'journey', 'journey')),
          Expanded(child: _buildTabButton(ref.watch(localeProvider).getString('map'), Icons.map, _selectedTab == 'map', 'map')),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon, bool isSelected, String tabKey) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800.withOpacity(0.6), Colors.indigo.shade900.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Level Circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          // Progress Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ref.watch(localeProvider).getString('level_3_traveler'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(ref.watch(localeProvider).getString('next_level_xp'), style: const TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
                ),
                const SizedBox(height: 4),
                Text(ref.watch(localeProvider).getString('xp_progress'), style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards() {
    return Row(
      children: [
        Expanded(child: _buildProgressCard(ref.watch(localeProvider).getString('weekly_progress'), '75%', Icons.show_chart, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildProgressCard(ref.watch(localeProvider).getString('completed_tasks'), '12', Icons.check_circle, Colors.green)),
      ],
    );
  }

  Widget _buildProgressCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActiveTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(ref.watch(localeProvider).getString('active_tasks'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTaskCard(ref.watch(localeProvider).getString('record_3_dreams_this_week'), Icons.nights_stay, 2, 3),
        const SizedBox(height: 12),
        _buildTaskCard(ref.watch(localeProvider).getString('learn_5_symbols'), Icons.add, 3, 5),
        const SizedBox(height: 12),
        _buildTaskCard(ref.watch(localeProvider).getString('do_meditation'), Icons.self_improvement, 0, 1),
      ],
    );
  }

  Widget _buildTaskCard(String title, IconData icon, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFF7C4DFF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: completed / total,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('$completed/$total', style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(ref.watch(localeProvider).getString('achievements'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAchievement(ref.watch(localeProvider).getString('first_dream'), Icons.nights_stay),
            _buildAchievement(ref.watch(localeProvider).getString('symbol_master'), Icons.star),
            _buildAchievement(ref.watch(localeProvider).getString('meditator'), Icons.self_improvement),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievement(String title, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.white), textAlign: TextAlign.center),
      ],
    );
  }

  void _addNewTask() {
    // TODO: Implement add new task functionality
  }

  Widget _buildJourneyProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yolculuğun',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İlerleme',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.35, // TODO: Get from provider
                      backgroundColor: const Color(0xFF141218),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '35% Tamamlandı',
                      style: TextStyle(
                        color: Color(0xFF7C4DFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seviye 3',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTask() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.task_alt,
                color: Color(0xFF7C4DFF),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Güncel Görev',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Son rüyandaki "su" sembolünü araştır ve günlükte anlamını yaz',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _startTask,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C4DFF),
                    side: const BorderSide(color: Color(0xFF7C4DFF)),
                  ),
                  child: const Text('Görevi Başlat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _completeTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tamamla'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyMap() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.map, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                ref.watch(localeProvider).getString('inner_journey_map'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ref.watch(localeProvider).getString('journey_map_description'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildSpiralJourneyMap(),
        ],
      ),
    );
  }

  Widget _buildSpiralJourneyMap() {
    final stepsAsync = ref.watch(journeyStepsProvider);

    return stepsAsync.when(
      data: (steps) => Container(
        height: 400,
        child: Stack(
          children: [
            // Spiral Path Background
            CustomPaint(
              size: const Size(400, 400),
              painter: SpiralPathPainter(primaryColor: Theme.of(context).colorScheme.primary),
            ),

            // Journey Steps
            ..._buildJourneyStepsOnMapWithData(steps),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Hata: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  List<Widget> _buildJourneyStepsOnMapWithData(List<JourneyStep> steps) {
    return steps.map((step) {
      final isCompleted = step.isCompleted;
      final isCurrent = step.isCurrent;
      final isLocked = step.isLocked;
      final position = step.position;

      return Positioned(
        left: position.dx - 30,
        top: position.dy - 30,
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (step.order * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: isLocked ? _showPremiumDialog : () => _selectJourneyStepData(step),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isLocked
                    ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
                    : isCompleted
                        ? step.color
                        : isCurrent
                            ? step.color.withOpacity(0.7)
                            : step.color.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLocked
                      ? Theme.of(context).colorScheme.outline
                      : isCurrent
                          ? Theme.of(context).colorScheme.onSurface
                          : step.color,
                  width: isCurrent ? 3 : 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: step.color.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      isLocked ? Icons.lock : step.icon,
                      color: isLocked
                          ? Theme.of(context).colorScheme.outline
                          : Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                          size: 12,
                        ),
                      ),
                    ),
                  if (isCurrent)
                    Positioned.fill(
                      child: _PulseAnimation(color: step.color),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildJourneyStepsOnMap() {
    // Deprecated - use _buildJourneyStepsOnMapWithData instead
    return [];
  }

  Widget _buildJourneySteps() {
    final steps = [
      {'title': 'Farkındalık', 'completed': true, 'current': false},
      {'title': 'Keşif', 'completed': true, 'current': false},
      {'title': 'Dönüşüm', 'completed': false, 'current': true},
      {'title': 'Entegrasyon', 'completed': false, 'current': false},
      {'title': 'Bilgelik', 'completed': false, 'current': false},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = step['completed'] as bool;
        final isCurrent = step['current'] as bool;
        final title = step['title'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : isCurrent
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                          : Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check
                      : isCurrent
                          ? Icons.play_arrow
                          : Icons.lock,
                  color: isCompleted
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted || isCurrent
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymbolEducation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.8),
            const Color(0xFF16213E).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Color(0xFF7C4DFF), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                ref.watch(localeProvider).getString('symbol_education'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ref.watch(localeProvider).getString('symbol_education_description'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          _buildSymbolCards(),
        ],
      ),
    );
  }

  Widget _buildSymbolCards() {
    final symbols = [
      {
        'symbol': ref.watch(localeProvider).getString('water_inner'),
        'frequency': 5,
        'meaning': ref.watch(localeProvider).getString('emotions_subconscious'),
        'description': 'Su sembolü genellikle duygularınızı ve bilinçaltınızı temsil eder.',
        'color': Colors.blue,
      },
      {
        'symbol': ref.watch(localeProvider).getString('house_inner'),
        'frequency': 3,
        'meaning': ref.watch(localeProvider).getString('self_security'),
        'description': 'Ev sembolü kendinizi ve iç dünyanızı temsil eder.',
        'color': Colors.green,
      },
      {
        'symbol': ref.watch(localeProvider).getString('road_inner'),
        'frequency': 2,
        'meaning': ref.watch(localeProvider).getString('life_journey'),
        'description': 'Yol sembolü hayatınızdaki yolculuğu ve kararları temsil eder.',
        'color': Colors.orange,
      },
    ];

    return Column(
      children: symbols.map((symbolData) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0E14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (symbolData['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    (symbolData['symbol'] as String)[0],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: symbolData['color'] as Color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbolData['symbol'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${symbolData['frequency']} ${ref.watch(localeProvider).getString('times_seen')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      symbolData['meaning'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: symbolData['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _learnSymbol(symbolData['symbol'] as String),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF7C4DFF),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.8),
            const Color(0xFF16213E).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.insights, color: Color(0xFF7C4DFF), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                ref.watch(localeProvider).getString('personal_insights'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ref.watch(localeProvider).getString('personal_insights_description'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  ref.watch(localeProvider).getString('transformation_notes'),
                  ref.watch(localeProvider).getString('notes_count'),
                  Icons.note_alt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  ref.watch(localeProvider).getString('awareness_moments'),
                  ref.watch(localeProvider).getString('moments_count'),
                  Icons.lightbulb,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _viewInsights,
              icon: const Icon(Icons.book, color: Colors.white),
              label: Text(ref.watch(localeProvider).getString('view_all_insights'), style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    // TODO: Navigate to analytics page
  }

  void _startTask() {
    // TODO: Start current task
  }

  void _completeTask() {
    // TODO: Complete current task
  }

  void _learnSymbol(String symbol) {
    // TODO: Navigate to symbol learning page
  }

  void _viewInsights() {
    // TODO: Navigate to insights page
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.star, color: Color(0xFF7C4DFF), size: 24),
            const SizedBox(width: 8),
            Text(ref.watch(localeProvider).getString('premium_required'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          ref.watch(localeProvider).getString('premium_required_description'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(ref.watch(localeProvider).getString('cancel_inner'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
            ),
            child: Text(ref.watch(localeProvider).getString('upgrade_to_premium')),
          ),
        ],
      ),
    );
  }

  void _selectJourneyStepData(JourneyStep step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(step.icon, color: step.color, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${step.title} - ${step.subtitle}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (step.isCompleted) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tamamlandı!',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ] else if (step.isCurrent) ...[
              Row(
                children: [
                  Icon(Icons.play_circle_outline, color: step.color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Aktif Aşama',
                    style: TextStyle(color: step.color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Seviye Gereksinimi: ${step.requiredLevel}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              'XP Ödülü: ${step.xpReward}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(ref.watch(localeProvider).getString('close_inner'), style: const TextStyle(color: Colors.grey)),
          ),
          if (step.isCurrent && !step.isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Start step activities
                _startStepActivities(step);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: step.color,
                foregroundColor: Colors.white,
              ),
              child: Text(ref.watch(localeProvider).getString('start')),
            ),
        ],
      ),
    );
  }

  void _selectJourneyStep(String stepTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.explore, color: const Color(0xFF7C4DFF), size: 24),
            const SizedBox(width: 8),
            Text('$stepTitle ${ref.watch(localeProvider).getString('stage')}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          _getStepDescription(stepTitle),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(ref.watch(localeProvider).getString('close_inner'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Start step activities
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
            ),
            child: Text(ref.watch(localeProvider).getString('start')),
          ),
        ],
      ),
    );
  }

  void _startStepActivities(JourneyStep step) {
    // TODO: Implement step activities
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${step.title} aşaması etkinlikleri başlatılıyor...'),
        backgroundColor: step.color,
      ),
    );
  }

  String _getStepDescription(String stepTitle) {
    switch (stepTitle) {
      case 'Farkındalık':
        return ref.watch(localeProvider).getString('awareness_description');
      case 'Keşif':
        return ref.watch(localeProvider).getString('discovery_description');
      case 'Dönüşüm':
        return ref.watch(localeProvider).getString('transformation_description');
      case 'Entegrasyon':
        return ref.watch(localeProvider).getString('integration_description');
      case 'Bilgelik':
        return ref.watch(localeProvider).getString('wisdom_description');
      default:
        return ref.watch(localeProvider).getString('stage_default_description');
    }
  }
}

class SpiralPathPainter extends CustomPainter {
  final Color primaryColor;

  SpiralPathPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Spiral path from center outward
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 20.0;
    final maxRadius = min(size.width, size.height) / 2 - 20;

    for (double angle = 0; angle < 3 * 3.14159; angle += 0.1) {
      final spiralRadius = radius + (angle * maxRadius / (3 * 3.14159));
      final x = center.dx + spiralRadius * cos(angle);
      final y = center.dy + spiralRadius * sin(angle);

      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Add some mystical dots along the path
    final dotPaint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (double angle = 0; angle < 3 * 3.14159; angle += 0.5) {
      final spiralRadius = radius + (angle * maxRadius / (3 * 3.14159));
      final x = center.dx + spiralRadius * cos(angle);
      final y = center.dy + spiralRadius * sin(angle);

      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Painter for pulse animation effect
class PulsePainter extends CustomPainter {
  final Color color;
  final double progress;

  PulsePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;
    final animatedRadius = baseRadius + (10 * progress);

    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - progress))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, animatedRadius, paint);
  }

  @override
  bool shouldRepaint(PulsePainter oldDelegate) => oldDelegate.progress != progress;
}

/// Pulse animation widget
class _PulseAnimation extends StatefulWidget {
  final Color color;

  const _PulseAnimation({required this.color});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: PulsePainter(
            color: widget.color,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}
