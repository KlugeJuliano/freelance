import 'package:flutter/foundation.dart';
import 'package:freelance/models/empresa_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  AuthStatus _status = AuthStatus.idle;
  EmpresaModel? _empresa;
  String? _erro;
  String? _role;

  AuthStatus get status => _status;
  EmpresaModel? get empresa => _empresa;
  String? get erro => _erro;
  bool get loading => _status == AuthStatus.loading;

  // Getters que as views usam
  String? get empresaId => _empresa?.id;
  bool get autenticado => _status == AuthStatus.authenticated;
  bool get isLogado => autenticado;
  String? get role => _role;
  User? get user => _supabase.auth.currentUser;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        _empresa = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        _carregarEmpresa(session.user.id);
      }
    });

    // Verifica sessão existente
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _carregarEmpresa(session.user.id);
    } else {
      _status = AuthStatus.unauthenticated;
    }
  }

  Future<void> _carregarEmpresa(String userId) async {
    try {
      // Tenta carregar como admin (cadastrou a empresa)
      final empresaData = await _supabase
          .from('empresas')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (empresaData != null) {
        // É o admin da empresa — role = diretoria
        _empresa = EmpresaModel.fromMap(empresaData);
        _role = 'diretoria';
        _status = AuthStatus.authenticated;
        notifyListeners();
        return;
      }

      // Não é admin — busca na tabela de usuários
      final usuarioData = await _supabase
          .from('usuarios')
          .select('role, empresa_id, empresas(id, nome, cnpj, email_admin)')
          .eq('id', userId)
          .maybeSingle();

      if (usuarioData != null) {
        _role = usuarioData['role'];
        _empresa = EmpresaModel.fromMap(
          usuarioData['empresas'] as Map<String, dynamic>,
        );
        _status = AuthStatus.authenticated;
      } else {
        await _supabase.auth.signOut();
        _status = AuthStatus.unauthenticated;
        _erro = null;
      }
    } catch (e) {
      await _supabase.auth.signOut();
      _status = AuthStatus.unauthenticated;
      _erro = null;
    }
    notifyListeners();
  }

  // Usado pela SplashView
  Future<void> verificarLogin() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _carregarEmpresa(session.user.id);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Retorna true/false para a LoginView
  Future<bool> login(String email, String senha) async {
    _status = AuthStatus.loading;
    _erro = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(email: email, password: senha);
      // onAuthStateChange cuida do _carregarEmpresa
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _erro = _traduzirErro(e.message);
      notifyListeners();
      return false;
    }
  }

  Future<void> cadastrarEmpresa({
    required String nome,
    required String cnpj,
    required String email,
    required String senha,
  }) async {
    _status = AuthStatus.loading;
    _erro = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: senha,
        data: {'empresa_id': null},
      );

      final user = response.user;
      if (user == null) throw Exception('Falha ao criar usuário.');

      // Usa function security definer para bypassar RLS no insert inicial
      await _supabase.rpc('cadastrar_empresa', params: {
        'p_id': user.id,
        'p_nome': nome,
        'p_cnpj': cnpj,
        'p_email_admin': email,
      });

      await _supabase.auth.updateUser(
        UserAttributes(data: {'empresa_id': user.id}),
      );

      _empresa = EmpresaModel(
        id: user.id,
        nome: nome,
        cnpj: cnpj,
        emailAdmin: email,
      );
      _status = AuthStatus.authenticated;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _erro = _traduzirErro(e.message);
    } on PostgrestException catch (e) {
      _status = AuthStatus.error;
      _erro = e.code == '23505'
          ? 'CNPJ já cadastrado.'
          : 'Erro ao salvar empresa: ${e.message}';
    } catch (e) {
      _status = AuthStatus.error;
      _erro = e.toString();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String _traduzirErro(String msg) {
    if (msg.contains('already registered')) return 'E-mail já cadastrado.';
    if (msg.contains('Invalid login')) return 'E-mail ou senha incorretos.';
    if (msg.contains('Email not confirmed')) return 'Confirme seu e-mail antes de entrar.';
    if (msg.contains('too many requests')) return 'Muitas tentativas. Aguarde alguns minutos.';
    return msg;
  }
}