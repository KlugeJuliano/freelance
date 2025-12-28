import 'package:flutter/material.dart';
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
}
