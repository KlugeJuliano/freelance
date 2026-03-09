import 'package:flutter/foundation.dart';
import 'package:freelance/models/pessoa_model.dart';
import 'package:freelance/services/api_services.dart';

class PessoaProvider extends ChangeNotifier {
  List<PessoaModel> _pessoas = [];
  bool _loading = false;
  String? _erro;

  List<PessoaModel> get pessoas => _pessoas;
  bool get loading => _loading;
  String? get erro => _erro;

  Future<void> carregarFreelancers() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final response = await ApiService.dio.get('/freelancers');
      _pessoas = (response.data as List)
          .map((json) => PessoaModel.fromJson(json))
          .toList();
    } catch (e) {
      _erro = 'Erro ao carregar freelancers: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarPessoa(PessoaModel pessoa) async {
    try {
      final response = await ApiService.dio.post(
        '/freelancers',
        data: {
          'nome': pessoa.nome,
          'cpf': pessoa.cpf,
          'telefone': pessoa.telefone,
          'email': pessoa.email,
          'chave_pix': pessoa.chavePix,
          'funcoes': pessoa.funcaoIds,
        },
      );
      _pessoas.add(PessoaModel.fromJson(response.data));
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao adicionar freelancer: $e';
      notifyListeners();
    }
  }

  Future<void> removerPessoa(String id) async {
    try {
      await ApiService.dio.delete('/freelancers/$id');
      _pessoas.removeWhere((p) => p.pessoaId == id);
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao remover freelancer: $e';
      notifyListeners();
    }
  }

  PessoaModel? buscarPessoaPorId(String id) {
    try {
      return _pessoas.firstWhere((p) => p.pessoaId == id);
    } catch (e) {
      return null;
    }
  }
}
