import 'package:flutter/foundation.dart';
import 'package:freelance/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _loading = false;
  String? _erro;

  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;
  String? get erro => _erro;
  bool get isLogado => _user != null;

  Future<void> verificarLogin() async {
    final logado = await AuthService.isLogado();
    if (logado) {
      _user = await AuthService.getUsuarioLogado();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      _user = await AuthService.login(email, password);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  String? get role => _user?['role'] as String?;
  String? get nome => _user?['nome'] as String?;
  String? get userId => _user?['id'] as String?;
}
