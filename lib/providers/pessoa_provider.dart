import 'package:flutter/foundation.dart';
import 'package:freelance/models/pessoa_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PessoaProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<PessoaModel> _pessoas = [];
  bool _loading = false;
  String? _erro;
  String? _empresaId;

  List<PessoaModel> get pessoas => _pessoas;
  bool get loading => _loading;
  String? get erro => _erro;

  void inicializar(String empresaId) {
    if (_empresaId == empresaId) return;
    _empresaId = empresaId;
    _pessoas = [];
    _escutar();
  }

  void _escutar() {
    _loading = true;
    notifyListeners();

    _supabase
        .from('pessoas')
        .stream(primaryKey: ['id'])
        .eq('empresa_id', _empresaId!)
        .listen((rows) {
          _pessoas = rows.map(PessoaModel.fromMap).toList();
          _loading = false;
          notifyListeners();
        });
  }

  // Mantido para compatibilidade com initState das views
  Future<void> fetchPessoas() async {
    if (_empresaId == null) return;
    _loading = true;
    notifyListeners();
    try {
      final data = await _supabase
          .from('pessoas')
          .select()
          .eq('empresa_id', _empresaId!);
      _pessoas = (data as List).map((r) => PessoaModel.fromMap(r)).toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarPessoa(PessoaModel pessoa) async {
    if (_empresaId == null) return;
    _erro = null;
    _loading = true;
    notifyListeners();
    try {
      await _supabase.from('pessoas').insert({
        'empresa_id': _empresaId,
        'nome': pessoa.nome,
        'cpf': pessoa.cpf,
        'telefone': pessoa.telefone,
        'email': pessoa.email,
        'chave_pix': pessoa.chavePix,
        'funcao_ids': pessoa.funcaoIds,
      });
    } catch (e) {
      _erro = 'Erro ao salvar colaborador: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> removerPessoa(String id) async {
    _erro = null;
    try {
      await _supabase.from('pessoas').delete().eq('id', id);
    } catch (e) {
      _erro = 'Erro ao remover colaborador: $e';
      notifyListeners();
    }
  }

  void limpar() {
    _pessoas = [];
    _empresaId = null;
    notifyListeners();
  }
}
