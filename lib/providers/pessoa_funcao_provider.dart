import 'package:flutter/material.dart';
import 'package:freelance/models/colaboradorFuncao_model.dart';

class PessoaFuncaoProvider extends ChangeNotifier {
  final List<ColaboradorfuncaoModel> _pessoasFuncoes = [];

  void vincularPessoaFuncao(String pessoaId, String funcaoId) {
    _pessoasFuncoes.add(
      ColaboradorfuncaoModel(pessoaId: pessoaId, funcaoId: funcaoId),
    );
    notifyListeners();
  }

  List<String> buscarFuncoesPorPessoa(String pessoaId) {
    return _pessoasFuncoes
        .where((pf) => pf.pessoaId == pessoaId)
        .map((pf) => pf.funcaoId)
        .toList();
  }

  List<String> buscarPessoasPorFuncao(String funcaoId) {
    return _pessoasFuncoes
        .where((pf) => pf.funcaoId == funcaoId)
        .map((pf) => pf.pessoaId)
        .toList();
  }
}
