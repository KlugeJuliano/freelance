import 'package:flutter/foundation.dart';
import 'package:freelance/models/freelancer_escalado_model.dart';
import 'package:freelance/services/escalacao_service.dart';

class EscalacaoProvider extends ChangeNotifier {
  List<FreelancerEscaladoModel> _escalados = [];
  bool _loading = false;
  String? _erro;
  String? _empresaId;

  List<FreelancerEscaladoModel> get escalados => _escalados;
  bool get loading => _loading;
  String? get erro => _erro;

  // Chamado pelo main.dart após login — passa empresaId para o service
  void inicializar(String empresaId) {
    if (_empresaId == empresaId) return;
    _empresaId = empresaId;
    EscalacaoService.empresaId = empresaId;
  }

  Future<void> carregarEscalados(String pedidoId) async {
    _loading = true;
    _erro = null;
    notifyListeners();
    try {
      _escalados = await EscalacaoService.buscarEscalados(pedidoId);
    } catch (e) {
      _erro = 'Erro ao carregar escalação: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> escalarFreelancer(String pedidoId, String pessoaId) async {
    _erro = null;
    try {
      await EscalacaoService.escalarFreelancer(pedidoId, pessoaId);
      await carregarEscalados(pedidoId);
    } catch (e) {
      _erro = 'Erro ao escalar: $e';
      notifyListeners();
    }
  }

  Future<void> removerEscalado(String pedidoId, String pessoaId) async {
    _erro = null;
    try {
      await EscalacaoService.removerEscalado(pedidoId, pessoaId);
      await carregarEscalados(pedidoId);
    } catch (e) {
      _erro = 'Erro ao remover: $e';
      notifyListeners();
    }
  }

  Future<bool> finalizar(String pedidoId) async {
    _erro = null;
    try {
      await EscalacaoService.finalizar(pedidoId);
      return true;
    } catch (e) {
      _erro = 'Erro ao finalizar: $e';
      notifyListeners();
      return false;
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  void limpar() {
    _escalados = [];
    _empresaId = null;
    EscalacaoService.empresaId = null;
    notifyListeners();
  }
}
