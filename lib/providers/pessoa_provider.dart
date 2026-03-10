import 'package:dio/dio.dart';
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
          .where((p) => p.ativo == true) // <-- só ativos
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
    } on DioException catch (e) {
      print('=== ERRO adicionarPessoa ===');
      print('Body: ${e.response?.data}'); // <-- adicionar
      _erro = e.response?.data['message'] ?? 'Erro ao adicionar freelancer';
      notifyListeners();
    }
  }

  Future<void> removerPessoa(String id) async {
    try {
      await ApiService.dio.patch('/freelancers/$id', data: {'ativo': false});
      // Atualiza localmente em vez de remover da lista
      final index = _pessoas.indexWhere((p) => p.pessoaId == id);
      if (index != -1) {
        _pessoas.removeAt(index);
      }
      notifyListeners();
    } on DioException catch (e) {
      print('=== ERRO removerPessoa ===');
      print('Body: ${e.response?.data}');
      _erro = e.response?.data['message'] ?? 'Erro ao desativar freelancer';
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
