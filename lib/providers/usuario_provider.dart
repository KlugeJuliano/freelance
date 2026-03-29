import 'package:flutter/foundation.dart';
import 'package:freelance/models/usuario_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<UsuarioModel> _usuarios = [];
  bool _loading = false;
  String? _erro;
  String? _empresaId;

  List<UsuarioModel> get usuarios => _usuarios;
  bool get loading => _loading;
  String? get erro => _erro;

  void inicializar(String empresaId) {
    if (_empresaId == empresaId) return;
    _empresaId = empresaId;
    _usuarios = [];
    _escutar();
  }

  void _escutar() {
    _loading = true;
    notifyListeners();

    _supabase
        .from('usuarios')
        .stream(primaryKey: ['id'])
        .eq('empresa_id', _empresaId!)
        .listen((rows) {
      _usuarios = rows.map(UsuarioModel.fromMap).toList();
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> criarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String role,
  }) async {
    if (_empresaId == null) return;
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      await _supabase.rpc('criar_usuario', params: {
        'p_nome': nome,
        'p_email': email,
        'p_senha': senha,
        'p_role': role,
        'p_empresa_id': _empresaId,
      });
    } on PostgrestException catch (e) {
      _erro = e.message.contains('E-mail já cadastrado')
          ? 'E-mail já cadastrado.'
          : 'Erro ao criar usuário: ${e.message}';
    } catch (e) {
      _erro = 'Erro inesperado: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> removerUsuario(String id) async {
    _erro = null;
    try {
      await _supabase.from('usuarios').delete().eq('id', id);
    } catch (e) {
      _erro = 'Erro ao remover usuário: $e';
      notifyListeners();
    }
  }

  void limpar() {
    _usuarios = [];
    _empresaId = null;
    notifyListeners();
  }
}