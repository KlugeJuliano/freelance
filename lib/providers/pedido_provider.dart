import 'package:flutter/material.dart';
import 'package:freelance/models/pessoa_no_pedido.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:freelance/viewmodels/pessoa_no_pedido_viewmodel.dart';

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
    required String nome,
  }) {
    final pedido = buscarPorId(pedidoId);

    pedido.pessoas.add(
      PessoaNoPedidoModel(funcao: funcao, pessoaId: pessoaId, nome: nome),
    );

    notifyListeners();
  }

  List<PessoaNoPedidoViewModel> getPessoasAlocadasViewModel({
    required String pedidoId,
    required PessoaProvider pessoaProvider,
  }) {
    final pedido = buscarPorId(pedidoId);

    return pedido.pessoas.map((alocacao) {
      pessoaProvider.buscarPessoaPorId(alocacao.pessoaId);
      return PessoaNoPedidoViewModel(
        funcao: alocacao.funcao,
        pessoaId: alocacao.pessoaId,
        nome: alocacao.nome,
      );
    }).toList();
  }
}
