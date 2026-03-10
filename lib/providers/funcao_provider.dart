import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freelance/models/funcao_model.dart';
import 'package:freelance/services/api_services.dart';

class FuncaoProvider extends ChangeNotifier {
  List<FuncaoModel> _funcoes = [];
  bool _loading = false;
  String? _erro;

  List<FuncaoModel> get funcoes => _funcoes;
  bool get loading => _loading;
  String? get erro => _erro;

  Future<void> carregarFuncoes() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final response = await ApiService.dio.get('/funcoes');
      _funcoes = (response.data as List)
          .map((json) => FuncaoModel.fromJson(json))
          .toList();
    } catch (e) {
      _erro = 'Erro ao carregar funções: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addFuncao(String nome, double valorHora) async {
    // Verifica duplicata localmente
    final jaExiste = _funcoes.any(
      (f) => f.nomeFuncao.toLowerCase() == nome.toLowerCase(),
    );
    if (jaExiste) {
      _erro = 'Já existe uma função com este nome.';
      notifyListeners();
      return;
    }

    try {
      final response = await ApiService.dio.post(
        '/funcoes',
        data: {'nome': nome, 'valor_hora': valorHora},
      );
      _funcoes.add(FuncaoModel.fromJson(response.data));
      notifyListeners();
    } on DioException catch (e) {
      _erro = e.response?.data['message'] ?? 'Erro ao adicionar função';
      notifyListeners();
    }
  }

  Future<void> removeFuncao(String id) async {
    try {
      await ApiService.dio.delete('/funcoes/$id');
      _funcoes.removeWhere((f) => f.funcaoId == id);
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao remover função: $e';
      notifyListeners();
    }
  }

  FuncaoModel? buscarPorId(String id) {
    try {
      return _funcoes.firstWhere((f) => f.funcaoId == id);
    } catch (e) {
      return null;
    }
  }
}
