import 'package:flutter/foundation.dart';
import 'package:freelance/models/empresa_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


enum AuthStatus {
  idle,
  loading,
  authenticated,
  unauthenticated,
  error,
  passwordRecovery, // novo: usuário clicou no link de recuperação
}

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
      final event = data.event;
      final session = data.session;

      // Evento especial: usuário clicou no link de recuperação de senha.
      // Aqui NÃO carregamos empresa nem autenticamos de fato — só sinalizamos
      // pra UI mostrar a tela de "criar nova senha".
      if (event == AuthChangeEvent.passwordRecovery) {
        _status = AuthStatus.passwordRecovery;
        notifyListeners();
        return;
      }

      if (session == null) {
        _empresa = null;
        _role = null;
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
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Erro ao carregar empresa: $e');
      _status = AuthStatus.unauthenticated;
      _erro = null;
    } finally {
      // Se ficamos não-autenticados, tentamos deslogar — mas isso nunca
      // pode impedir o notifyListeners() de rodar (esse era o bug do loading
      // travado: signOut() lançava exceção com refresh token inválido e
      // o notifyListeners() de sucesso nunca era alcançado).
      if (_status == AuthStatus.unauthenticated) {
        try {
          await _supabase.auth.signOut();
        } catch (_) {
          // ignora — já estamos deslogando de qualquer forma
        }
      }
      notifyListeners();
    }
  }

  // Usado pela SplashView
  Future<void> verificarLogin() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      // timeout de segurança: nunca deixa a Splash travada indefinidamente
      await _carregarEmpresa(session.user.id).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          _status = AuthStatus.unauthenticated;
          notifyListeners();
        },
      );
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
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      final user = response.user;
      if (user == null) throw const AuthException('Falha ao autenticar.');
      await _carregarEmpresa(user.id);
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
      await _supabase.rpc(
        'cadastrar_empresa',
        params: {
          'p_id': user.id,
          'p_nome': nome,
          'p_cnpj': cnpj,
          'p_email_admin': email,
        },
      );

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

  /// Envia e-mail com o link de recuperação de senha.
  /// [redirectTo] deve ser o deep link configurado no seu app
  /// (ex: 'io.supabase.freelance://reset-callback/') e também
  /// cadastrado em Authentication > URL Configuration no painel Supabase.
  Future<bool> recuperarSenha(String email, {required String redirectTo}) async {
    _status = AuthStatus.loading;
    _erro = null;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _erro = _traduzirErro(e.message);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _erro = 'Erro ao enviar e-mail de recuperação.';
      notifyListeners();
      return false;
    }
  }

  /// Chamado na tela de "nova senha", depois que o usuário chegou lá
  /// através do link de recuperação (status == AuthStatus.passwordRecovery).
  Future<bool> definirNovaSenha(String novaSenha) async {
    _status = AuthStatus.loading;
    _erro = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: novaSenha),
      );
      final user = response.user;
      if (user == null) throw const AuthException('Falha ao atualizar senha.');

      // Depois de trocar a senha, carrega os dados normalmente
      await _carregarEmpresa(user.id);
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _erro = _traduzirErro(e.message);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String _traduzirErro(String msg) {
    if (msg.contains('already registered')) return 'E-mail já cadastrado.';
    if (msg.contains('Invalid login')) return 'E-mail ou senha incorretos.';
    if (msg.contains('Email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('too many requests')) {
      return 'Muitas tentativas. Aguarde alguns minutos.';
    }
    if (msg.contains('New password should be different')) {
      return 'A nova senha deve ser diferente da atual.';
    }
    if (msg.contains('session') || msg.contains('expired')) {
      return 'Link expirado. Solicite a recuperação de senha novamente.';
    }
    return msg;
  }
}