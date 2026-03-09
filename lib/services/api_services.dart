import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  //static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  static const String baseUrl = 'http://localhost:8000/api'; // iOS/Web

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expirado — limpa o storage
            _storage.delete(key: 'token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;
  static FlutterSecureStorage get storage => _storage;
}
