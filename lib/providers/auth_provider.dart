// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _role;
  bool _loading = false;
  String? _erro;

  User? get user => _user;
  bool get isLogado => _user != null;
  String? get role => _role;
  bool get loading => _loading;
  String? get erro => _erro;

  AuthProvider() {
    supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _role = _user!.userMetadata?['role'] as String?;
      } else {
        _role = null;
      }
      notifyListeners();
    });
  }

  /// Chamado pelo SplashView — restaura sessão persistida e carrega o role.
  Future<void> verificarLogin() async {
    _user = supabase.auth.currentUser;
    if (_user != null) {
      _role = _user!.userMetadata?['role'] as String?;
    }
    notifyListeners();
  }

  /// Login com email e senha. Retorna true em caso de sucesso.
  Future<bool> login(String email, String password) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      _role = _user?.userMetadata?['role'] as String?;
      return true;
    } on AuthException catch (e) {
      _erro = e.message;
      return false;
    } catch (e) {
      _erro = 'Erro ao conectar. Tente novamente.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cadastro de novo usuário.
  /// [role] deve ser 'gerente', 'rh' ou 'diretoria'.
  Future<void> signUp(String email, String password, String role) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
      );
      _user = response.user;
      _role = role;
    } on AuthException catch (e) {
      _erro = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Logout.
  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    _role = null;
    _erro = null;
    notifyListeners();
  }
}
