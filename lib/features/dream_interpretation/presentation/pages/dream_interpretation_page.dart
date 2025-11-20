import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/ai_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/ai_service.dart';
// removed SystemStatusWidget import

class DreamInterpretationPage extends ConsumerStatefulWidget {
  const DreamInterpretationPage({super.key});

  @override
  ConsumerState<DreamInterpretationPage> createState() => _DreamInterpretationPageState();
}

class _DreamInterpretationPageState extends ConsumerState<DreamInterpretationPage> {
  String? _selectedInterpreter = 'ai';
  String? _selectedInterpretationType = 'psychological';
  final TextEditingController _dreamController = TextEditingController();
  DreamInterpretation? _currentInterpretation;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top pill (Kalan)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.book, size: 16, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text('${ref.watch(localeProvider).getString('remaining')}: 2', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Yorumcu Seçimi
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface, size: 20),
                      const SizedBox(width: 8),
                      Text(ref.watch(localeProvider).getString('interpreter_selection'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _interpreterCard(
                    title: ref.watch(localeProvider).getString('ai_interpreter_card'),
                    subtitle: ref.watch(localeProvider).getString('ai_interpreter_desc'),
                    icon: Icons.smart_toy,
                    value: 'ai',
                  ),
                  const SizedBox(height: 12),
                  _interpreterCard(
                    title: ref.watch(localeProvider).getString('expert_interpreter'),
                    subtitle: ref.watch(localeProvider).getString('expert_interpreter_desc'),
                    icon: Icons.person,
                    value: 'expert',
                    isPremium: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Dream input card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nights_stay, color: Theme.of(context).colorScheme.onSurface, size: 20),
                      const SizedBox(width: 8),
                      Text(ref.watch(localeProvider).getString('dream_interpretation_title'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(ref.watch(localeProvider).getString('dream_interpretation_subtitle'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dreamController,
                    maxLines: 5,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      hintText: ref.watch(localeProvider).getString('enter_dream'),
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.fromLTRB(14, 14, 80, 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  // mic & attach floating buttons
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _miniPill(Icons.mic),
                        const SizedBox(width: 8),
                        _miniPill(Icons.attach_file),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _dreamController.text.isNotEmpty && _selectedInterpreter != null
                    ? _interpretDream
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(ref.watch(localeProvider).getString('interpret_dream'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 22),

            // Rüya Bekleniyor / Yorumlama Sonucu
            Container(
              height: 200, // Sabit yükseklik
              width: double.infinity, // Tam genişlik
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              ),
              child: _isLoading 
                ? _buildLoadingState()
                : _currentInterpretation != null 
                  ? _buildInterpretationResult()
                  : _buildWaitingState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.nights_stay, size: 60, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(ref.watch(localeProvider).getString('waiting_for_dream'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(ref.watch(localeProvider).getString('enter_your_dream'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(ref.watch(localeProvider).getString('analyzing_dream'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(ref.watch(localeProvider).getString('please_wait_dream'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInterpretationResult() {
    return SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
          children: [
              Icon(Icons.psychology, size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(ref.watch(localeProvider).getString('dream_interpretation_result'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentInterpretation = null;
                  });
                },
                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 16),
            Text(
            _currentInterpretation!.text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 14, height: 1.5),
          ),
          if (_currentInterpretation!.symbols.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(ref.watch(localeProvider).getString('symbols'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentInterpretation!.symbols.map((symbol) => Chip(
                label: Text(symbol, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              )).toList(),
            ),
          ],
          if (_currentInterpretation!.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(ref.watch(localeProvider).getString('recommendations_dream'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._currentInterpretation!.recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _currentInterpretation!.confidence == 'high' 
                      ? Colors.green.withOpacity(0.2)
                      : _currentInterpretation!.confidence == 'medium' 
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _currentInterpretation!.confidence == 'high' 
                        ? Colors.green
                        : _currentInterpretation!.confidence == 'medium'
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                child: Text(
                  '${ref.watch(localeProvider).getString('confidence')}${_currentInterpretation!.confidence == 'high' ? ref.watch(localeProvider).getString('confidence_high') : _currentInterpretation!.confidence == 'medium' ? ref.watch(localeProvider).getString('confidence_medium') : ref.watch(localeProvider).getString('confidence_low')}',
                  style: TextStyle(
                    color: _currentInterpretation!.confidence == 'high' 
                        ? Colors.green
                        : _currentInterpretation!.confidence == 'medium'
                            ? Colors.orange
                            : Colors.red,
                    fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPill(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant, 
        borderRadius: BorderRadius.circular(12)
      ),
      child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
    );
  }

  Widget _interpreterCard({required String title, required String subtitle, required IconData icon, required String value, bool isPremium = false}) {
    final selected = _selectedInterpreter == value;
    return InkWell(
      onTap: () => setState(() => _selectedInterpreter = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3), 
            width: selected ? 2 : 1
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Premium', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                    ),
                ]),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
              ]),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedInterpreter,
              onChanged: (v) => setState(() => _selectedInterpreter = v),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeCard(String title, String desc, String value) {
    final selected = _selectedInterpretationType == value;
    return InkWell(
      onTap: () => setState(() => _selectedInterpretationType = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3), width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.mood, color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(desc, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
            ])),
            Radio<String>(
              value: value,
              groupValue: _selectedInterpretationType,
              onChanged: (v) => setState(() => _selectedInterpretationType = v),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentCard(String title, String interpreter, String preview, String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0B0A0E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Text(date, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        Text(interpreter, style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(preview, style: const TextStyle(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }


  void _interpretDream() async {
    if (_dreamController.text.isEmpty) return;

    // Loading state'i göster
    setState(() {
      _isLoading = true;
    });

    try {
      // DreamData oluştur
      final dreamData = DreamData(
        content: _dreamController.text,
        date: DateTime.now().toIso8601String(),
        emotion: 'neutral', // Varsayılan duygu
        symbols: [], // Boş sembol listesi
        userProfile: UserProfile(
          age: 25, // Varsayılan yaş
          gender: 'unknown', // Varsayılan cinsiyet
          maritalStatus: 'unknown', // Varsayılan medeni durum
        ),
      );

      // AI servisi ile rüya yorumla
      final interpretation = await ref.read(aiServiceProvider).interpretDream(dreamData);

      // Sonucu state'e kaydet
      setState(() {
        _currentInterpretation = interpretation;
        _isLoading = false;
      });

    } catch (error) {
      // Hata durumunda loading'i kapat
      setState(() {
        _isLoading = false;
      });

      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ref.watch(localeProvider).getString('dream_interpretation_error')}$error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
