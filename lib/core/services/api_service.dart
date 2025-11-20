import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.170:8080/api';
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    ));

    // Interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      return response.data;
    } catch (e) {
      _logger.e('Register error: $e');
      rethrow;
    }
  }

  // Education endpoints
  Future<List<Map<String, dynamic>>> getEducations() async {
    try {
      print('🌐 API Call: GET /education');
      final response = await _dio.get('/education');
      print('📡 API Response: ${response.data}');
      
      if (response.data['success'] == true) {
        final data = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        print('✅ Parsed ${data.length} educations');
        return data;
      } else {
        _logger.e('API returned error: ${response.data['message']}');
        print('❌ API Error: ${response.data['message']}');
        return [];
      }
    } catch (e) {
      _logger.e('Get educations error: $e');
      print('❌ Exception: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getEducation(String id) async {
    try {
      final response = await _dio.get('/education/$id');
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Education not found');
      }
    } catch (e) {
      _logger.e('Get education error: $e');
      rethrow;
    }
  }

  // Sessions endpoints
  Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final response = await _dio.get('/sessions');
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      } else {
        _logger.e('API returned error: ${response.data['message']}');
        return [];
      }
    } catch (e) {
      _logger.e('Get sessions error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getSession(String id) async {
    try {
      final response = await _dio.get('/sessions/$id');
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Session not found');
      }
    } catch (e) {
      _logger.e('Get session error: $e');
      rethrow;
    }
  }

  // Books endpoints
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await _dio.get('/books');
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      } else {
        _logger.e('API returned error: ${response.data['message']}');
        return [];
      }
    } catch (e) {
      _logger.e('Get books error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getBook(String id) async {
    try {
      final response = await _dio.get('/books/$id');
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Book not found');
      }
    } catch (e) {
      _logger.e('Get book error: $e');
      rethrow;
    }
  }

  // Content endpoints
  Future<List<Map<String, dynamic>>> getContent() async {
    try {
      final response = await _dio.get('/content');
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } catch (e) {
      _logger.e('Get content error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getContentItem(String id) async {
    try {
      final response = await _dio.get('/content/$id');
      return response.data['data'];
    } catch (e) {
      _logger.e('Get content item error: $e');
      rethrow;
    }
  }

  // Authors endpoints
  Future<List<Map<String, dynamic>>> getAuthors() async {
    try {
      final response = await _dio.get('/authors');
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } catch (e) {
      _logger.e('Get authors error: $e');
      return [];
    }
  }

  // Experts endpoints
  Future<List<Map<String, dynamic>>> getExperts() async {
    try {
      final response = await _dio.get('/experts');
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } catch (e) {
      _logger.e('Get experts error: $e');
      return [];
    }
  }

  // Dream journal endpoints
  Future<List<Map<String, dynamic>>> getDreams() async {
    try {
      final response = await _dio.get('/dreams');
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } catch (e) {
      _logger.e('Get dreams error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createDream(Map<String, dynamic> dreamData) async {
    try {
      final response = await _dio.post('/dreams', data: dreamData);
      return response.data['data'];
    } catch (e) {
      _logger.e('Create dream error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateDream(String id, Map<String, dynamic> dreamData) async {
    try {
      final response = await _dio.put('/dreams/$id', data: dreamData);
      return response.data['data'];
    } catch (e) {
      _logger.e('Update dream error: $e');
      rethrow;
    }
  }

  Future<void> deleteDream(String id) async {
    try {
      await _dio.delete('/dreams/$id');
    } catch (e) {
      _logger.e('Delete dream error: $e');
      rethrow;
    }
  }
}

// Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
