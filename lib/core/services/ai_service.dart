import 'dart:convert';
import 'package:dio/dio.dart';

// AI Servisleri - AnythingLLM ve OpenRouter Entegrasyonu

const String ANYTHINGLLM_API_URL = 'https://20pcoqr7.rsrv.host';
const String ANYTHINGLLM_API_KEY = '473WNPP-8RPM5HY-KQ8XZ9T-2KRKCP5';

// OpenRouter API konfigürasyonu
const String OPENROUTER_API_URL = 'https://openrouter.ai/api/v1';
const String OPENROUTER_API_KEY = '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';

class DreamData {
  final String content;
  final String date;
  final String emotion;
  final List<String> symbols;
  final UserProfile userProfile;
  final List<dynamic>? dreamHistory;
  final Map<String, dynamic>? userPreferences;

  DreamData({
    required this.content,
    required this.date,
    required this.emotion,
    required this.symbols,
    required this.userProfile,
    this.dreamHistory,
    this.userPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'date': date,
      'emotion': emotion,
      'symbols': symbols,
      'userProfile': userProfile.toJson(),
      'dreamHistory': dreamHistory,
      'userPreferences': userPreferences,
    };
  }
}

class UserProfile {
  final int age;
  final String gender;
  final String maritalStatus;

  UserProfile({
    required this.age,
    required this.gender,
    required this.maritalStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'maritalStatus': maritalStatus,
    };
  }
}

class DreamInterpretation {
  final String text;
  final List<String> symbols;
  final List<String> recommendations;
  final String confidence; // 'high' | 'medium' | 'low'
  final String analysisType; // 'psychological' | 'spiritual' | 'cultural'

  DreamInterpretation({
    required this.text,
    required this.symbols,
    required this.recommendations,
    required this.confidence,
    required this.analysisType,
  });

  factory DreamInterpretation.fromJson(Map<String, dynamic> json) {
    return DreamInterpretation(
      text: json['text'] ?? '',
      symbols: List<String>.from(json['symbols'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      confidence: json['confidence'] ?? 'medium',
      analysisType: json['analysisType'] ?? 'psychological',
    );
  }
}

class OpenRouterLLMProvider {
  static Map<String, dynamic> getConfig({String model = 'llama'}) {
    final models = {
      'llama': 'meta-llama/llama-3.1-8b-instruct:free',
      'gpt-oss': 'openai/gpt-oss-120b:free'
    };
    
    return {
      'provider': 'openai',
      'baseURL': OPENROUTER_API_URL,
      'apiKey': OPENROUTER_API_KEY,
      'model': models[model] ?? models['llama'],
      'temperature': 0.3,
      'maxTokens': 500
    };
  }
}

class AnythingLLMClient {
  final String baseURL;
  final String apiKey;
  String workspaceSlug;
  final Dio _dio;

  AnythingLLMClient({
    required this.baseURL,
    required this.apiKey,
    required this.workspaceSlug,
  }) : _dio = Dio(BaseOptions(
    baseUrl: baseURL,
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(minutes: 10),
    receiveTimeout: const Duration(minutes: 10),
  ));

  Future<Map<String, dynamic>> chat(String message, {Map<String, dynamic>? context}) async {
    try {
      print('AnythingLLM API çağrısı başlatılıyor...');
      print('Message: $message');
      print('Workspace Slug: $workspaceSlug');

      // Önce workspace'leri listele
      try {
        final workspacesResponse = await _dio.get('/api/workspaces');
        if (workspacesResponse.statusCode == 200) {
          final response = workspacesResponse.data;
          print('Available workspaces: ${jsonEncode(response)}');
          
          final workspaces = response['workspaces'] ?? response;
          
          // InnerDreams workspace'ini bul
          final innerDreamsWorkspace = (workspaces as List).firstWhere(
            (w) => w['name'] == 'InnerDreams' || 
                   w['slug'] == 'InnerDreams' || 
                   w['name']?.toString().toLowerCase() == 'innerdreams' ||
                   w['slug']?.toString().toLowerCase() == 'innerdreams',
            orElse: () => null,
          );
          
          if (innerDreamsWorkspace != null) {
            workspaceSlug = innerDreamsWorkspace['slug'] ?? innerDreamsWorkspace['name'];
            print('Found InnerDreams workspace: $workspaceSlug');
          } else if (workspaces.isNotEmpty) {
            workspaceSlug = workspaces[0]['slug'] ?? workspaces[0]['name'];
            print('Using first available workspace: $workspaceSlug');
          }
        }
      } catch (e) {
        print('Could not fetch workspaces, using default: $workspaceSlug');
      }

      // Workspace ayarlarını güncelle
      try {
        print('Workspace ayarları güncelleniyor...');
        
        // Cache'i temizle
        try {
          await _dio.post('/api/system/clear-cache');
          print('Cache temizlendi');
        } catch (e) {
          print('Cache temizleme başarısız: $e');
        }
        
        // Workspace'i güncelle
        final updateUrl = '/api/workspace/$workspaceSlug';
        await _dio.put(updateUrl, data: {
          'chatModel': 'openai/gpt-oss-120b:free',
          'agentModel': 'openai/gpt-oss-120b:free',
          'embeddingModel': 'llama2:7b',
          'chatProvider': 'openrouter',
          'openAiPrompt': 'Sen bir rüya yorumlama uzmanısın. ÖNCE eğitildiğin belgelerdeki bilgilere bak, eğer ilgili bilgi varsa onu kullan. Eğer belgede ilgili bilgi yoksa, kendi rüya yorumlama bilginle cevap ver. ÖNEMLİ: Kullanıcının rüyasında geçen KELİMELERİ TAM OLARAK eşleştir. "diz" ≠ "baldır", "baldız" ≠ "baldır". Belgede "evli bir kimsenin" yazıyorsa ve kullanıcı bekar ise "Bu yorum evli kişiler için geçerli" de. TÜRKÇE yanıt ver.',
          'openAiTemp': 0.1,
          'openAiHistory': 5,
          'topN': 3,
          'similarityThreshold': 0.8,
          'openAiKey': OPENROUTER_API_KEY,
          'openAiBase': OPENROUTER_API_URL,
          'openAiModel': 'openai/gpt-oss-120b:free'
        });
        print('Workspace başarıyla güncellendi');
      } catch (e) {
        print('Workspace güncelleme başarısız, mevcut ayarlar ile devam ediliyor: $e');
      }

      // Chat API'sini çağır
      final endpoints = [
        '/api/v1/workspace/$workspaceSlug/chat',
        '/api/chat',
        '/v1/chat/completions',
        '/api/v1/chat/completions'
      ];
      
      String url = endpoints[0];
      print('Calling AnythingLLM API: $url');

      // Retry mekanizması
      const maxRetries = 3;
      Response? response;
      Exception? lastError;
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          print('API çağrısı denemesi $attempt/$maxRetries');
          
          response = await _dio.post(url, data: {
            'message': message,
            'mode': 'chat',
            'sessionId': 'session-${DateTime.now().millisecondsSinceEpoch}',
            'attachments': [],
            'reset': false
          });

          if (response.statusCode == 200) {
            print('API çağrısı başarılı (deneme $attempt)');
            break;
          }
          
          print('API hatası (deneme $attempt): ${response.statusCode} ${response.statusMessage}');
          
          if (response.statusCode == 524 && attempt < maxRetries) {
            print('524 timeout hatası (deneme $attempt), ${attempt * 10} saniye bekleyip tekrar denenecek...');
            await Future.delayed(Duration(seconds: attempt * 10));
            continue;
          }
          
          break;
          
        } catch (error) {
          lastError = error is Exception ? error : Exception(error.toString());
          print('API çağrısı hatası (deneme $attempt): $error');
          
          if (attempt < maxRetries) {
            print('${attempt * 10} saniye bekleyip tekrar denenecek...');
            await Future.delayed(Duration(seconds: attempt * 10));
            continue;
          }
          
          break;
        }
      }
      
      if (response == null || response.statusCode != 200) {
        throw lastError ?? Exception('Tüm denemeler başarısız oldu');
      }

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      final responseData = response.data;
      
      // HTML yanıtı kontrolü
      if (responseData is String && responseData.trim().startsWith('<')) {
        print('HTML response detected, using mock response');
        return {
          'message': 'Rüya Yorumu: $message\n\nBu rüya, iç dünyanızda yaşadığınız duygusal süreçleri yansıtıyor olabilir. Rüyanızı günlüğünüze kaydederek daha detaylı analiz yapabilirsiniz.\n\nSemboller: Rüya sembolleri\nÖneriler: Rüya günlüğü tutmaya devam edin\nGüven Seviyesi: Orta',
          'id': 'mock-response',
          'type': 'textResponse',
          'sources': [],
          'close': true
        };
      }

      // JSON parse et
      Map<String, dynamic> data;
      if (responseData is String) {
        data = jsonDecode(responseData);
      } else {
        data = responseData;
      }
      
      print('Parsed response: $data');

      if (data['error'] != null) {
        print('API returned error: ${data['error']}');
        throw Exception(data['error']);
      }

      return {
        'message': data['textResponse'] ?? data['message'] ?? 'Yanıt alınamadı',
        'id': data['id'] ?? 'unknown',
        'type': data['type'] ?? 'textResponse',
        'sources': data['sources'] ?? [],
        'close': data['close'] ?? false
      };
      
    } catch (error) {
      print('AnythingLLM chat error: $error');
      
      if (error.toString().contains('timeout')) {
        throw Exception('AI modeli 10 dakika içinde yanıt veremedi. Lütfen daha sonra tekrar deneyin.');
      }
      
      if (error.toString().contains('524')) {
        throw Exception('Sunucu çok yavaş yanıt veriyor. Lütfen birkaç dakika sonra tekrar deneyin.');
      }
      
      if (error.toString().contains('not found')) {
        throw Exception('AI modeli bulunamadı. Lütfen model ayarlarını kontrol edin.');
      }
      
      throw Exception('AnythingLLM API hatası: $error');
    }
  }

  Future<DreamInterpretation> interpretDream(DreamData dreamData) async {
    final prompt = _buildDreamPrompt(dreamData);
    try {
      final response = await chat(prompt, context: {
        'userProfile': dreamData.userProfile.toJson(),
        'dreamHistory': dreamData.dreamHistory,
        'symbols': dreamData.symbols
      });
      return _parseDreamResponse(response);
    } catch (error) {
      print('Rüya yorumlama hatası: $error');
      return _getFallbackInterpretation(dreamData);
    }
  }

  String _buildDreamPrompt(DreamData dreamData) {
    final symbols = dreamData.symbols.isNotEmpty 
        ? 'Semboller: ${dreamData.symbols.join(', ')}' 
        : '';
    
    final emotion = dreamData.emotion.isNotEmpty 
        ? 'Duygu: ${dreamData.emotion}' 
        : '';
    
    final context = [symbols, emotion].where((e) => e.isNotEmpty).join(' | ');
    
    return 'Rüya: ${dreamData.content}${context.isNotEmpty ? ' ($context)' : ''}. ÖNCE eğitildiğin belgelerdeki bilgilere bak, eğer ilgili bilgi varsa onu kullan. Eğer belgede ilgili bilgi yoksa, kendi rüya yorumlama bilginle cevap ver.\n\nÖNEMLİ: Rüyada geçen KELİMELERİ TAM OLARAK eşleştir. "diz" ≠ "baldır", "baldız" ≠ "baldır". \n\nBelgede "evli bir kimsenin" yazıyorsa ve kullanıcı bekar ise "Bu yorum evli kişiler için geçerli" de. TÜRKÇE yanıt ver.';
  }

  DreamInterpretation _parseDreamResponse(Map<String, dynamic> response) {
    final text = response['message'] ?? response['text'] ?? 'Rüya yorumu alınamadı.';
    
    return DreamInterpretation(
      text: text,
      symbols: [],
      recommendations: [],
      confidence: 'medium',
      analysisType: 'psychological'
    );
  }

  DreamInterpretation _getFallbackInterpretation(DreamData dreamData) {
    // Fallback interpretation when AI service fails
    return DreamInterpretation(
      text: '''
Rüyanızı analiz etmeye çalışıyorum. Şu anda AI servisimizde geçici bir sorun var, ancak rüyanızın genel anlamını paylaşabilirim:

**Rüya Analizi:**
Rüyanızda gördüğünüz olaylar ve semboller, bilinçaltınızın size gönderdiği mesajlar olabilir. Rüyalar genellikle:
- Günlük yaşamınızdaki stres ve kaygıları yansıtır
- Gelecekteki kararlarınız hakkında ipuçları verir
- Geçmiş deneyimlerinizi işlemenize yardımcı olur

**Öneriler:**
- Rüyanızı bir günlüğe kaydedin
- Rüyada hissettiğiniz duyguları not alın
- Tekrarlayan sembolleri takip edin
- Uzman desteği almayı düşünün

AI servisimiz düzeldiğinde daha detaylı analiz yapabileceğiz.
      ''',
      symbols: ['genel', 'analiz'],
      recommendations: [
        'Rüya günlüğü tutun',
        'Duygularınızı not alın',
        'Tekrarlayan sembolleri takip edin',
        'Uzman desteği almayı düşünün'
      ],
      confidence: 'medium',
      analysisType: 'psychological'
    );
  }
}

class LLMProviderManager {
  late AnythingLLMClient _anythingLLMClient;
  final Map<String, DreamInterpretation> _cache = {};
  String _currentProvider = 'openrouter-gpt-oss';

  LLMProviderManager() {
    _anythingLLMClient = AnythingLLMClient(
      baseURL: ANYTHINGLLM_API_URL,
      apiKey: ANYTHINGLLM_API_KEY,
      workspaceSlug: 'InnerDreams',
    );
    setLLMProvider('openrouter-gpt-oss');
  }

  Future<void> setLLMProvider(String provider) async {
    _currentProvider = provider;
    print('LLM Provider değiştirildi: $provider');
    
    try {
      final updateUrl = '${_anythingLLMClient.baseURL}/api/workspace/${_anythingLLMClient.workspaceSlug}';
      
      Map<String, dynamic> requestBody = {
        'chatProvider': provider.startsWith('openrouter') ? 'openrouter' : 'ollama',
        'chatModel': provider == 'ollama' ? 'llama2:7b' : 
                     provider == 'openrouter-llama' ? 'meta-llama/llama-3.1-8b-instruct:free' :
                     'openai/gpt-oss-120b:free'
      };
      
      if (provider.startsWith('openrouter')) {
        final modelType = provider == 'openrouter-llama' ? 'llama' : 'gpt-oss';
        final openRouterConfig = OpenRouterLLMProvider.getConfig(model: modelType);
        requestBody.addAll({
          'openAiKey': openRouterConfig['apiKey'],
          'openAiBase': openRouterConfig['baseURL'],
          'openAiModel': openRouterConfig['model']
        });
      }
      
      await _anythingLLMClient._dio.put(updateUrl, data: requestBody);
      print('$provider provider başarıyla ayarlandı');
    } catch (error) {
      print('$provider provider ayarlama hatası: $error');
    }
  }

  Future<DreamInterpretation> interpretDream(DreamData dreamData) async {
    final dreamHash = _generateDreamHash(dreamData);
    final cached = _cache[dreamHash];
    if (cached != null) return cached;

    try {
      print('$_currentProvider ile rüya yorumlanıyor...');
      final interpretation = await _anythingLLMClient.interpretDream(dreamData);
      
      _cache[dreamHash] = interpretation;
      Future.delayed(const Duration(days: 1), () => _cache.remove(dreamHash));
      return interpretation;
    } catch (error) {
      print('Rüya yorumlama hatası: $error');
      throw Exception('$_currentProvider ile rüya yorumlama başarısız');
    }
  }

  Future<String> chatWithAICoach(String message) async {
    try {
      print('=== LLMProviderManager.chatWithAICoach BAŞLADI ===');
      print('$_currentProvider ile AI Coach chat...');
      print('Gelen mesaj: $message');
      
      final aiCoachPrompt = 'Sen bir rüya yorumlama uzmanısın. ÖNCE eğitildiğin belgelerdeki bilgilere bak, eğer ilgili bilgi varsa onu kullan. Eğer belgede ilgili bilgi yoksa, kendi rüya yorumlama bilginle cevap ver.\n\nÖNEMLİ: Kullanıcının rüyasında geçen KELİMELERİ TAM OLARAK eşleştir. "diz" ≠ "baldır", "baldız" ≠ "baldır". \n\nBelgede "evli bir kimsenin" yazıyorsa ve kullanıcı bekar ise "Bu yorum evli kişiler için geçerli" de. Türkçe yanıt ver. Kullanıcı mesajı: $message';
      
      print('AI Koç prompt oluşturuldu: $aiCoachPrompt');
      print('AnythingLLMClient.chat çağrılıyor...');
      
      final response = await _anythingLLMClient.chat(aiCoachPrompt);
      
      print('AnythingLLMClient yanıtı: $response');
      print('Response tipi: ${response.runtimeType}');
      print('Response.message: ${response['message']}');
      print('Response.textResponse: ${response['textResponse']}');
      
      final finalResponse = response['message'] ?? response['textResponse'] ?? 'Bir sorun oluştu, lütfen tekrar deneyin.';
      print('Final yanıt: $finalResponse');
      print('=== LLMProviderManager.chatWithAICoach BİTTİ ===');
      
      return finalResponse;
    } catch (error) {
      print('AI Coach chat error: $error');
      print('Hata durumunda fallback yanıt döndürülüyor');
      return 'AI Koç şu anda meşgul. Lütfen daha sonra tekrar deneyin.';
    }
  }

  String _generateDreamHash(DreamData dreamData) {
    final content = dreamData.content.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final symbols = dreamData.symbols.toList()..sort();
    return '$content-${symbols.join(',')}-${dreamData.emotion}';
  }
}

class DreamInterpretationService {
  late AnythingLLMClient _client;
  final Map<String, DreamInterpretation> _cache = {};

  DreamInterpretationService() {
    _client = AnythingLLMClient(
      baseURL: ANYTHINGLLM_API_URL,
      apiKey: ANYTHINGLLM_API_KEY,
      workspaceSlug: 'InnerDreams',
    );
  }

  Future<DreamInterpretation> interpretDream(DreamData dreamData) async {
    final dreamHash = _generateDreamHash(dreamData);
    final cached = _cache[dreamHash];
    if (cached != null) return cached;

    try {
      final interpretation = await _client.interpretDream(dreamData);
      _cache[dreamHash] = interpretation;
      Future.delayed(const Duration(days: 1), () => _cache.remove(dreamHash));
      return interpretation;
    } catch (error) {
      print('Rüya yorumlama hatası: $error');
      return _getBasicInterpretation(dreamData);
    }
  }

  Future<String> chatWithAICoach(String message) async {
    try {
      final shortMessage = message.length > 100 ? '${message.substring(0, 100)}...' : message;
      final response = await _client.chat(shortMessage);
      return response['message'] ?? response['textResponse'] ?? 'Bir sorun oluştu, lütfen tekrar deneyin.';
    } catch (error) {
      print('AI Coach chat error: $error');
      return 'AI Koç şu anda meşgul. Lütfen daha sonra tekrar deneyin.';
    }
  }

  String _generateDreamHash(DreamData dreamData) {
    final content = dreamData.content.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final symbols = dreamData.symbols.toList()..sort();
    return '$content-${symbols.join(',')}-${dreamData.emotion}';
  }

  DreamInterpretation _getBasicInterpretation(DreamData dreamData) {
    // Basic interpretation when AI service fails
    return DreamInterpretation(
      text: '''
Rüyanızı analiz etmeye çalışıyorum. Şu anda AI servisimizde geçici bir sorun var, ancak rüyanızın genel anlamını paylaşabilirim:

**Rüya Analizi:**
Rüyanızda gördüğünüz olaylar ve semboller, bilinçaltınızın size gönderdiği mesajlar olabilir. Rüyalar genellikle:
- Günlük yaşamınızdaki stres ve kaygıları yansıtır
- Gelecekteki kararlarınız hakkında ipuçları verir
- Geçmiş deneyimlerinizi işlemenize yardımcı olur

**Öneriler:**
- Rüyanızı bir günlüğe kaydedin
- Rüyada hissettiğiniz duyguları not alın
- Tekrarlayan sembolleri takip edin
- Uzman desteği almayı düşünün

AI servisimiz düzeldiğinde daha detaylı analiz yapabileceğiz.
      ''',
      symbols: ['genel', 'analiz'],
      recommendations: [
        'Rüya günlüğü tutun',
        'Duygularınızı not alın',
        'Tekrarlayan sembolleri takip edin',
        'Uzman desteği almayı düşünün'
      ],
      confidence: 'medium',
      analysisType: 'psychological'
    );
  }
}

// Singleton instances
final anythingLLMClient = AnythingLLMClient(
  baseURL: ANYTHINGLLM_API_URL,
  apiKey: ANYTHINGLLM_API_KEY,
  workspaceSlug: 'InnerDreams',
);

final dreamInterpretationService = DreamInterpretationService();
final llmProviderManager = LLMProviderManager();
