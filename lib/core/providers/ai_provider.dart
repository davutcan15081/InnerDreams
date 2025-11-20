import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';

// AI Servisleri için Riverpod Provider'ları

final aiServiceProvider = Provider<DreamInterpretationService>((ref) {
  return dreamInterpretationService;
});

final llmProviderManagerProvider = Provider<LLMProviderManager>((ref) {
  return llmProviderManager;
});

final anythingLLMClientProvider = Provider<AnythingLLMClient>((ref) {
  return anythingLLMClient;
});

// Rüya yorumlama state'i için StateNotifier
class DreamInterpretationNotifier extends StateNotifier<AsyncValue<DreamInterpretation?>> {
  final DreamInterpretationService _service;

  DreamInterpretationNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> interpretDream(DreamData dreamData) async {
    state = const AsyncValue.loading();
    
    try {
      final interpretation = await _service.interpretDream(dreamData);
      state = AsyncValue.data(interpretation);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearInterpretation() {
    state = const AsyncValue.data(null);
  }
}

final dreamInterpretationNotifierProvider = StateNotifierProvider<DreamInterpretationNotifier, AsyncValue<DreamInterpretation?>>((ref) {
  final service = ref.watch(aiServiceProvider);
  return DreamInterpretationNotifier(service);
});

// AI Coach chat state'i için StateNotifier
class AICoachNotifier extends StateNotifier<({List<Map<String, String>> messages, bool isLoading})> {
  final DreamInterpretationService _service;

  AICoachNotifier(this._service) : super((messages: [], isLoading: false));

  Future<void> sendMessage(String message) async {
    state = (messages: [...state.messages, {'sender': 'user', 'text': message}], isLoading: true);
    
    try {
      final response = await _service.chatWithAICoach(message);
      state = (messages: [...state.messages, {'sender': 'ai', 'text': response}], isLoading: false);
    } catch (error) {
      state = (messages: [...state.messages, {'sender': 'ai', 'text': 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.'}], isLoading: false);
    }
  }

  void clearChat() {
    state = (messages: [], isLoading: false);
  }
}

final aiCoachNotifierProvider = StateNotifierProvider<AICoachNotifier, ({List<Map<String, String>> messages, bool isLoading})>((ref) {
  final service = ref.watch(aiServiceProvider);
  return AICoachNotifier(service);
});

// LLM Provider seçimi için StateNotifier
class LLMProviderNotifier extends StateNotifier<String> {
  final LLMProviderManager _manager;

  LLMProviderNotifier(this._manager) : super('openrouter-gpt-oss');

  Future<void> setProvider(String provider) async {
    try {
      await _manager.setLLMProvider(provider);
      state = provider;
    } catch (error) {
      print('LLM Provider değiştirme hatası: $error');
    }
  }
}

final llmProviderNotifierProvider = StateNotifierProvider<LLMProviderNotifier, String>((ref) {
  final manager = ref.watch(llmProviderManagerProvider);
  return LLMProviderNotifier(manager);
});
