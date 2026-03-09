import 'package:flutter/material.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/services/api_services.dart';

class PedidoProvider extends ChangeNotifier {
  List<PedidoModel> _pedidos = [];
  bool _loading = false;
  String? _erro;

  List<PedidoModel> get pedidos => _pedidos;
  bool get loading => _loading;
  String? get erro => _erro;

  Future<void> carregarPedidos({String? status, String? lojaId}) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final response = await ApiService.dio.get(
        '/pedidos',
        queryParameters: {
          if (status != null) 'status': status,
          if (lojaId != null) 'loja_id': lojaId,
        },
      );
      _pedidos = (response.data as List)
          .map((json) => PedidoModel.fromJson(json))
          .toList();
    } catch (e) {
      _erro = 'Erro ao carregar pedidos: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarPedido(PedidoModel pedido) async {
    try {
      final response = await ApiService.dio.post(
        '/pedidos',
        data: {
          'loja_id': pedido.lojaId,
          'funcao_id': pedido.funcaoId,
          'quantidade': pedido.quantidade,
          'data_inicio': pedido.dataInicio.toIso8601String(),
          'data_fim': pedido.dataFim.toIso8601String(),
          'observacoes': pedido.observacoes,
        },
      );
      _pedidos.insert(0, PedidoModel.fromJson(response.data));
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao criar pedido: $e';
      notifyListeners();
    }
  }

  Future<void> atualizarStatus(String pedidoId, String novoStatus) async {
    try {
      await ApiService.dio.patch(
        '/pedidos/$pedidoId/status',
        data: {'status': novoStatus},
      );
      final index = _pedidos.indexWhere((p) => p.id == pedidoId);
      if (index != -1) {
        _pedidos[index].status = novoStatus;
        notifyListeners();
      }
    } catch (e) {
      _erro = 'Erro ao atualizar status: $e';
      notifyListeners();
    }
  }

  PedidoModel? buscarPorId(String id) {
    try {
      return _pedidos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
