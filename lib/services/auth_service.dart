import 'package:dio/dio.dart';
import 'package:freelance/services/api_services.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final user = response.data['user'];

      // Salva token e dados do usuário
      await ApiService.storage.write(key: 'token', value: token);
      await ApiService.storage.write(key: 'user_id', value: user['id']);
      await ApiService.storage.write(key: 'user_nome', value: user['nome']);
      await ApiService.storage.write(key: 'user_email', value: user['email']);
      await ApiService.storage.write(key: 'user_role', value: user['role']);

      return user;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Erro ao conectar com o servidor';
      throw Exception(message);
    }
  }

  static Future<void> logout() async {
    try {
      await ApiService.dio.post('/auth/logout');
    } catch (_) {
      // ignora erro no logout
    } finally {
      await ApiService.storage.deleteAll();
    }
  }

  static Future<Map<String, String?>> getUsuarioLogado() async {
    return {
      'id': await ApiService.storage.read(key: 'user_id'),
      'nome': await ApiService.storage.read(key: 'user_nome'),
      'email': await ApiService.storage.read(key: 'user_email'),
      'role': await ApiService.storage.read(key: 'user_role'),
    };
  }

  static Future<bool> isLogado() async {
    final token = await ApiService.storage.read(key: 'token');
    return token != null;
  }
}
