import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/services/firebase_service.dart';
import '../../../../../core/providers/ai_provider.dart';
import '../../../../../core/providers/locale_provider.dart';

class SessionsPage extends ConsumerStatefulWidget {
  const SessionsPage({super.key});

  @override
  ConsumerState<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends ConsumerState<SessionsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 2; // Varsayılan olarak "Seanslarım" seçili

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await ref.read(aiCoachNotifierProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.psychology,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              ref.watch(localeProvider).getString('sessions_title'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
          ),
        ],
      ),
        centerTitle: false,
        actions: [
          // Logo
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'assets/astroloji_logo.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
                          ),
                        ),
                      ],
                    ),
      body: Column(
        children: [
          _buildSegmentedControl(),
          Expanded(
            child: _buildCurrentTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, ref.watch(localeProvider).getString('ai_coach'), Icons.psychology_outlined),
          _buildTabItem(1, ref.watch(localeProvider).getString('experts'), Icons.person_outline),
          _buildTabItem(2, ref.watch(localeProvider).getString('my_sessions'), Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAICoachContent();
      case 1:
        return _buildExpertsContent();
      case 2:
        return _buildMySessionsContent();
      default:
        return Center(child: Text(ref.watch(localeProvider).getString('error_occurred'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
    }
  }

  Widget _buildAICoachContent() {
    final aiCoachState = ref.watch(aiCoachNotifierProvider);
    return Column(
      children: [
        Expanded(
          child: aiCoachState.messages.isEmpty
              ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        ref.watch(localeProvider).getString('start_chatting_with_ai_coach'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: aiCoachState.messages.length,
                  itemBuilder: (context, index) {
                    final chatMessage = aiCoachState.messages[index];
                    return _buildChatMessage(chatMessage);
                  },
                ),
        ),
        if (aiCoachState.isLoading)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 8),
                Text(ref.watch(localeProvider).getString('ai_coach_responding'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
              ],
            ),
          ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildExpertsContent() {
    return Center(
      child: Text(
        ref.watch(localeProvider).getString('experts_list_coming_soon'),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
      ),
    );
  }

  Widget _buildMySessionsContent() {
    final currentUser = FirebaseService.currentUser;

    if (currentUser == null) {
      return Center(
        child: Text(
          ref.watch(localeProvider).getString('please_login'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('sessions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${ref.watch(localeProvider).getString('error_loading_sessions')}${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)));
        }

        final sessions = snapshot.data!.docs;

        // Yaklaşan ve Geçmiş seansları ayır
        final upcomingSessions = sessions.where((s) {
          final data = s.data() as Map<String, dynamic>;
          final sessionDate = (data['date'] as Timestamp?)?.toDate();
          // Eğer tarih yoksa, tüm seansları yaklaşan olarak göster
          return sessionDate == null || sessionDate.isAfter(DateTime.now());
        }).toList();

        final pastSessions = sessions.where((s) {
          final data = s.data() as Map<String, dynamic>;
          final sessionDate = (data['date'] as Timestamp?)?.toDate();
          // Sadece tarihi olan ve geçmişte olan seansları göster
          return sessionDate != null && sessionDate.isBefore(DateTime.now());
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(ref.watch(localeProvider).getString('upcoming_sessions'), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ref.watch(localeProvider).getString('show_all_upcoming'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                );
              }),
              const SizedBox(height: 12),
              if (upcomingSessions.isEmpty)
                _buildEmptyState(ref.watch(localeProvider).getString('no_upcoming_appointments'))
              else
                ...upcomingSessions.map((session) => _buildSessionCard(session)).toList(),
              const SizedBox(height: 32),
              _buildSectionHeader(ref.watch(localeProvider).getString('past_sessions'), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ref.watch(localeProvider).getString('show_all_past'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                );
              }),
              const SizedBox(height: 12),
              if (pastSessions.isEmpty)
                _buildEmptyState(ref.watch(localeProvider).getString('no_appointment_history'))
              else
                ...pastSessions.map((session) => _buildSessionCard(session)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            ref.watch(localeProvider).getString('all_sessions'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSessionCard(DocumentSnapshot session) {
    final data = session.data() as Map<String, dynamic>;
    final title = data['title'] ?? ref.watch(localeProvider).getString('untitled_session');
    final description = data['description'] ?? ref.watch(localeProvider).getString('no_description_sessions');
    final expertName = data['expertName'] ?? ref.watch(localeProvider).getString('unknown');
    final imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/150';
    final sessionDate = (data['date'] as Timestamp?)?.toDate();
    final formattedDate = sessionDate != null
        ? '${sessionDate.day}.${sessionDate.month}.${sessionDate.year} ${sessionDate.hour}:${sessionDate.minute.toString().padLeft(2, '0')}'
        : ref.watch(localeProvider).getString('date_not_specified');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
          Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
                  '${ref.watch(localeProvider).getString('date')}$formattedDate',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${ref.watch(localeProvider).getString('expert')}$expertName',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title${ref.watch(localeProvider).getString('join_session_message')}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      ref.watch(localeProvider).getString('join_session'),
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16),
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

  Widget _buildChatMessage(Map<String, String> message) {
    final isUser = message['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).colorScheme.primary.withOpacity(0.8) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: Text(
          message['text']!,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: ref.watch(localeProvider).getString('write_to_ai_coach'),
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}