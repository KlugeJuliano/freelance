import 'package:freelance/models/request.dart';

enum StatusPedido { solicitado, aprovado, cancelado, recusado, finalizado }

class StatusService {
  PedidoModel aprovarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.solicitado) {
      throw Exception("Pedido não pode ser aprovado");
    }

    pedido.status = StatusPedido.aprovado.name;

    return pedido;
  }

  PedidoModel cancelarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.solicitado) {
      throw Exception('Este pedido não pode ser cancelado');
    }

    pedido.status = StatusPedido.cancelado.name;

    return pedido;
  }

  //Pedido só pode ser recusado depois que foi aprovado pelo RH
  PedidoModel recusarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.aprovado) {
      throw Exception('Este pedido não pode ser recusado');
    }

    pedido.status = StatusPedido.recusado.name;
    return pedido;
  }

  PedidoModel finalizarPedido(PedidoModel pedido) {
    final statusAtual = StatusPedido.values.byName(pedido.status);

    if (statusAtual != StatusPedido.aprovado) {
      throw Exception('Este pedido não pode ser finalizado ');
    }
    pedido.status = StatusPedido.finalizado.name;
    return pedido;
  }
}
