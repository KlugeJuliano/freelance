// lib/services/status_service.dart

import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/services/supabase_client.dart';

enum StatusPedido {
  solicitado,
  escalado,
  aprovado,
  recusado,
  em_andamento,
  finalizado,
  cancelado,
}

class StatusService {
  /// solicitado → cancelado (gerente)
  Future<PedidoModel> cancelarPedido(PedidoModel pedido) async {
    _validar(pedido, de: StatusPedido.solicitado);
    return _atualizar(pedido, StatusPedido.cancelado);
  }

  /// solicitado → escalado (RH — via EscalacaoService.finalizar)
  /// escalado → aprovado (gerente)
  Future<PedidoModel> aprovarPedido(PedidoModel pedido) async {
    _validar(pedido, de: StatusPedido.escalado);
    return _atualizar(pedido, StatusPedido.aprovado);
  }

  /// escalado → recusado (gerente devolve ao RH)
  Future<PedidoModel> recusarPedido(PedidoModel pedido) async {
    _validar(pedido, de: StatusPedido.escalado);
    return _atualizar(pedido, StatusPedido.recusado);
  }

  /// aprovado → em_andamento (gerente confirma início)
  Future<PedidoModel> iniciarJornada(PedidoModel pedido) async {
    _validar(pedido, de: StatusPedido.aprovado);
    return _atualizar(pedido, StatusPedido.em_andamento);
  }

  /// em_andamento → finalizado (gerente encerra)
  Future<PedidoModel> finalizarPedido(PedidoModel pedido) async {
    _validar(pedido, de: StatusPedido.em_andamento);
    return _atualizar(pedido, StatusPedido.finalizado);
  }

  void _validar(PedidoModel pedido, {required StatusPedido de}) {
    final atual = StatusPedido.values.byName(pedido.status);
    if (atual != de) {
      throw Exception(
        'Ação inválida: pedido está "${pedido.status}", esperado "${de.name}"',
      );
    }
  }

  Future<PedidoModel> _atualizar(
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
