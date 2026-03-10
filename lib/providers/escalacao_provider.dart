// lib/providers/escalacao_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freelance/models/pessoa_no_pedido.dart';
import 'package:freelance/services/escalacao_service.dart';

class EscalacaoProvider extends ChangeNotifier {
  List<PessoaNoPedidoModel> _escalados = [];
  bool _loading = false;
  String? _erro;

  List<PessoaNoPedidoModel> get escalados => _escalados;
  bool get loading => _loading;
  String? get erro => _erro;

  Future<void> carregarEscalados(String pedidoId) async {
    _loading = true;
    _erro = null;
    notifyListeners();
    try {
      _escalados = (await EscalacaoService.buscarEscalados(
        pedidoId,
      )).cast<PessoaNoPedidoModel>();
    } on DioException catch (e) {
      _erro = e.response?.data['message'] ?? 'Erro ao carregar escalação';
    } catch (e) {
      _erro = 'Erro ao carregar escalação: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> escalarFreelancer(String pedidoId, String freelancerId) async {
    _erro = null;
    try {
      await EscalacaoService.escalarFreelancer(pedidoId, freelancerId);
      await carregarEscalados(pedidoId);
    } on DioException catch (e) {
      _erro = e.response?.data['message'] ?? 'Erro ao escalar';
      notifyListeners();
    }
  }

  Future<void> removerEscalado(String pedidoId, String freelancerId) async {
    _erro = null;
    try {
      await EscalacaoService.removerEscalado(pedidoId, freelancerId);
      await carregarEscalados(pedidoId);
    } on DioException catch (e) {
      _erro = e.response?.data['message'] ?? 'Erro ao remover';
      notifyListeners();
    }
  }

  Future<bool> finalizar(String pedidoId) async {
    _erro = null;
    try {
      await EscalacaoService.finalizar(pedidoId);
      return true;
    } on DioException catch (e) {
      _erro = e.response?.data['message'] ?? 'Erro ao finalizar';
      notifyListeners();
      return false;
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
