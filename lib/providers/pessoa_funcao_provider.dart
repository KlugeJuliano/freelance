// lib/providers/pessoa_funcao_provider.dart
//
// Substitui o provider em memória anterior.
// Lê e escreve na tabela 'pessoa_funcao' (N:N) do Supabase.

import 'package:flutter/foundation.dart';
import '../services/supabase_client.dart';

class PessoaFuncaoProvider extends ChangeNotifier {
  // Cache local: pessoaId → lista de funcaoIds
  final Map<String, List<String>> _cache = {};

  /// Vincula uma pessoa a uma função.
  Future<void> vincularPessoaFuncao(String pessoaId, String funcaoId) async {
    await supabase.from('pessoa_funcao').upsert({
      'pessoa_id': pessoaId,
      'funcao_id': funcaoId,
    });

    _cache.putIfAbsent(pessoaId, () => []);
    if (!_cache[pessoaId]!.contains(funcaoId)) {
      _cache[pessoaId]!.add(funcaoId);
    }
    notifyListeners();
  }

  /// Remove o vínculo.
  Future<void> desvincularPessoaFuncao(String pessoaId, String funcaoId) async {
    await supabase
        .from('pessoa_funcao')
        .delete()
        .eq('pessoa_id', pessoaId)
        .eq('funcao_id', funcaoId);

    _cache[pessoaId]?.remove(funcaoId);
    notifyListeners();
  }

  /// Retorna ids das funções de uma pessoa.
  /// Usa cache; chame [fetchFuncoesDePessoa] para garantir dados frescos.
  List<String> buscarFuncoesPorPessoa(String pessoaId) {
    return _cache[pessoaId] ?? [];
  }

  /// Busca do banco e atualiza cache.
  Future<List<String>> fetchFuncoesDePessoa(String pessoaId) async {
    final data = await supabase
        .from('pessoa_funcao')
        .select('funcao_id')
        .eq('pessoa_id', pessoaId);

    final ids = (data as List).map((r) => r['funcao_id'] as String).toList();
    _cache[pessoaId] = ids;
    notifyListeners();
    return ids;
  }

  /// Vincula múltiplas funções de uma vez (usado no cadastro de colaborador).
  Future<void> vincularFuncoesEmLote(String pessoaId, Set<String> funcaoIds) async {
    if (funcaoIds.isEmpty) return;

    final rows = funcaoIds
        .map((fid) => {'pessoa_id': pessoaId, 'funcao_id': fid})
        .toList();

    await supabase.from('pessoa_funcao').upsert(rows);
    _cache[pessoaId] = funcaoIds.toList();
    notifyListeners();
  }
}
