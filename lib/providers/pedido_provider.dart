import 'package:flutter/material.dart';
import 'package:freelance/models/pessoa_no_pedido.dart';
import 'package:freelance/models/request.dart';

class PedidoProvider extends ChangeNotifier {
  final List<PedidoModel> _pedidos = [];

  List<PedidoModel> get pedidos => _pedidos;

  adicionarPedido(PedidoModel pedidos) {
    _pedidos.add(pedidos);

    notifyListeners();
  }

  buscarPorId(String id) {
    return pedidos.firstWhere((pedido) => pedido.id == id);
  }

  adicionarPessoaPedido({
    required String pedidoId,
    required String pessoaId,
    required String funcao,
  }) {
    final pedido = buscarPorId(pedidoId);

    pedido.pessoas.add(PessoaNoPedidoModel(funcao: funcao, pessoaId: pessoaId));

    notifyListeners();
  }
}
