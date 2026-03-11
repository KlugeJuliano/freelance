// lib/services/status_service.dart

import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/services/supabase_client.dart';

enum StatusPedido { solicitado, aprovado, cancelado, recusado, finalizado }

class StatusService {
  Future<PedidoModel> aprovarPedido(PedidoModel pedido) async {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.solicitado) {
      throw Exception('Pedido não pode ser aprovado');
    }

    return await _atualizarStatus(pedido, StatusPedido.aprovado);
  }

  Future<PedidoModel> cancelarPedido(PedidoModel pedido) async {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.solicitado) {
      throw Exception('Este pedido não pode ser cancelado');
    }

    return await _atualizarStatus(pedido, StatusPedido.cancelado);
  }

  // Pedido só pode ser recusado depois que foi aprovado pelo RH
  Future<PedidoModel> recusarPedido(PedidoModel pedido) async {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.aprovado) {
      throw Exception('Este pedido não pode ser recusado');
    }

    return await _atualizarStatus(pedido, StatusPedido.recusado);
  }

  Future<PedidoModel> finalizarPedido(PedidoModel pedido) async {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.aprovado) {
      throw Exception('Este pedido não pode ser finalizado');
    }

    return await _atualizarStatus(pedido, StatusPedido.finalizado);
  }

  Future<PedidoModel> _atualizarStatus(
    PedidoModel pedido,
    StatusPedido novoStatus,
  ) async {
    await supabase
        .from('pedidos')
        .update({'status': novoStatus.name})
        .eq('id', pedido.id);

    return pedido.copyWith(status: novoStatus.name);
  }
}
