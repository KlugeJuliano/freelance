// lib/providers/funcao_provider.dart
//
// Substitui o provider em memória anterior.
// Lê e escreve na tabela 'funcoes' do Supabase.

import 'package:flutter/foundation.dart';
import '../models/funcao_model.dart';
import '../services/supabase_client.dart';

class FuncaoProvider extends ChangeNotifier {
  List<FuncaoModel> _funcoes = [];
  bool _loading = false;
  String? _erro;

  List<FuncaoModel> get funcoes => _funcoes;
  bool get loading => _loading;
  String? get erro => _erro;

  /// Carrega todas as funções do banco.
  Future<void> fetchFuncoes() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final data = await supabase.from('funcoes').select().order('nome');

      _funcoes = (data as List)
          .map(
            (row) => FuncaoModel(
              funcaoId: row['id'] as String,
              nomeFuncao: row['nome'] as String,
              valorHora:
                  (row['valor_hora'] as num?)?.toDouble() ??
                  0.0, // Mapeando o valor
            ),
          )
          .toList();
    } catch (e) {
      _erro = "Erro ao carregar dados: $e";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Insere uma nova função.
  Future<void> addFuncao(String nome, double valorHora) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      await supabase.from('funcoes').insert({
        'nome': nome,
        'valor_hora': valorHora,
      });
      await fetchFuncoes();
    } catch (e) {
      _erro = "Erro ao adicionar função: $e";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Remove uma função por id.
  Future<void> removeFuncao(String id) async {
    await supabase.from('funcoes').delete().eq('id', id);
    _funcoes.removeWhere((f) => f.funcaoId == id);
    notifyListeners();
  }

  FuncaoModel? buscarPorId(String id) {
    try {
      return _funcoes.firstWhere((f) => f.funcaoId == id);
    } catch (_) {
      return null;
    }
  }
}
