import 'package:flutter/foundation.dart';
import 'package:freelance/models/pessoa_model.dart';

class PessoaProvider extends ChangeNotifier {
  List<PessoaModel> _pessoas = [];

  List<PessoaModel> get pessoas => _pessoas;

  adicionarPessoa(PessoaModel pessoas) {
    _pessoas.add(pessoas);
    notifyListeners();
  }

  buscarPessoaPorId(String id) {
    return _pessoas.firstWhere(
      (p) => p.pessoaId == id,
      orElse: () =>
          PessoaModel(nome: 'Pessoa não encontrada', pessoaId: 'invalid'),
    );
  }

  removerPessoa(String id) {
    _pessoas.removeWhere((p) => p.pessoaId == id);

    notifyListeners();
  }

  alterarPessoa(String id) {}
}
