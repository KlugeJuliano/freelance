import 'package:flutter/foundation.dart';
import 'package:freelance/models/funcao_model.dart';

class FuncaoProvider extends ChangeNotifier {
  final List<FuncaoModel> _funcoes = [];

  List<FuncaoModel> get funcoes => _funcoes;

  void addFuncao(FuncaoModel funcao) {
    _funcoes.add(funcao);
    notifyListeners();
  }

  void removeFuncao(String id) {
    _funcoes.removeWhere((f) => f.funcaoId == id);
    notifyListeners();
  }

  void clearFuncoes() {
    _funcoes.clear();
    notifyListeners();
  }

  FuncaoModel? buscarPorId(int id) {
    try {
      return _funcoes.firstWhere((funcao) => funcao.funcaoId == id);
    } catch (e) {
      return null;
    }
  }
}
