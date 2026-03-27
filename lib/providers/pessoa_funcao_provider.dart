import 'package:flutter/foundation.dart';
import 'package:freelance/services/supabase_service.dart';

class PessoaFuncaoProvider extends ChangeNotifier {
  final _supabase = SupabaseService.client;

  // mapa pessoaId → lista de funcaoIds
  Map<String, List<String>> _vinculos = {};
  String? _empresaId;

  void inicializar(String empresaId) {
    if (_empresaId == empresaId) return;
    _empresaId = empresaId;
    _vinculos = {};
    _escutar();
  }

  void _escutar() {
    _supabase
        .from('pessoa_funcao')
        .stream(primaryKey: ['pessoa_id', 'funcao_id'])
        .listen((rows) {
          final mapa = <String, List<String>>{};
          for (final row in rows) {
            final pessoaId = row['pessoa_id'] as String;
            final funcaoId = row['funcao_id'] as String;
            mapa.putIfAbsent(pessoaId, () => []).add(funcaoId);
          }
          _vinculos = mapa;
          notifyListeners();
        });
  }

  Future<void> vincularPessoaFuncao(String pessoaId, String funcaoId) async {
    if (_empresaId == null) return;
    await _supabase.from('pessoa_funcao').upsert({
      'pessoa_id': pessoaId,
      'funcao_id': funcaoId,
      'empresa_id': _empresaId,
    });
  }

  Future<void> desvincularPessoaFuncao(String pessoaId, String funcaoId) async {
    await _supabase
        .from('pessoa_funcao')
        .delete()
        .eq('pessoa_id', pessoaId)
        .eq('funcao_id', funcaoId);
  }

  List<String> buscarFuncoesPorPessoa(String pessoaId) =>
      _vinculos[pessoaId] ?? [];

  void limpar() {
    _vinculos = {};
    _empresaId = null;
    notifyListeners();
  }
}
