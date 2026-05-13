import 'package:flutter/foundation.dart';
import 'package:freelance/models/funcao_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FuncaoProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<FuncaoModel> _funcoes = [];
  bool _loading = false;
  String? _erro;
  String? _empresaId;

  List<FuncaoModel> get funcoes => _funcoes;
  bool get loading => _loading;
  String? get erro => _erro;

  void inicializar(String empresaId) {
    if (_empresaId == empresaId) return;
    _empresaId = empresaId;
    _funcoes = [];
    _escutar();
  }

  void _escutar() {
    _loading = true;
    notifyListeners();

    _supabase
        .from('funcoes')
        .stream(primaryKey: ['id'])
        .eq('empresa_id', _empresaId!)
        .listen((rows) {
          _funcoes = rows.map(FuncaoModel.fromMap).toList();
          _loading = false;
          notifyListeners();
        });
  }

  // Mantido para compatibilidade com initState das views
  Future<void> fetchFuncoes() async {
    if (_empresaId == null) return;
    _loading = true;
    notifyListeners();
    try {
      final data = await _supabase
          .from('funcoes')
          .select()
          .eq('empresa_id', _empresaId!);
      _funcoes = (data as List).map((r) => FuncaoModel.fromMap(r)).toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addFuncao(String nomeFuncao, double valorHora) async {
    if (_empresaId == null) return;
    _erro = null;
    try {
      await _supabase.from('funcoes').insert({
        'empresa_id': _empresaId,
        'nome_funcao': nomeFuncao,
        'valor_hora': valorHora,
      });
    } catch (e) {
      _erro = 'Erro ao salvar função: $e';
      notifyListeners();
    }
  }

  Future<void> removeFuncao(String id) async {
    _erro = null;
    try {
      await _supabase.from('funcoes').delete().eq('id', id);
    } catch (e) {
      _erro = 'Erro ao remover função: $e';
      notifyListeners();
    }
  }

  FuncaoModel? buscarPorId(String id) {
    try {
      return _funcoes.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  void limpar() {
    _funcoes = [];
    _empresaId = null;
    notifyListeners();
  }
}
