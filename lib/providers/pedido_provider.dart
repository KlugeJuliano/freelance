// lib/providers/pedido_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/services/supabase_client.dart';

class PedidoProvider extends ChangeNotifier {
  List<PedidoModel> _pedidos = [];
  bool _loading = false;

  List<PedidoModel> get pedidos => _pedidos;
  bool get loading => _loading;

  List<PedidoModel> get pedidosPendentes =>
      _pedidos.where((p) => p.status == 'solicitado').toList();

  Future<void> fetchPedidos() async {
    _loading = true;
    notifyListeners();

    final data = await supabase
        .from('pedidos')
        .select()
        .order('created_at', ascending: false);

    _pedidos = (data as List)
        .map((row) => PedidoModel.fromMap(row as Map<String, dynamic>))
        .toList();

    _loading = false;
    notifyListeners();
  }

  Future<void> adicionarPedido(PedidoModel pedido) async {
    await supabase.from('pedidos').insert({
      'loja_id': pedido.lojaId,
      'funcao_id': pedido.funcaoId,
      'gerente_id': pedido.gerenteId,
      'quantidade': pedido.quantidade,
      'data_inicio': pedido.dataInicio.toIso8601String(),
      'data_fim': pedido.dataFim.toIso8601String(),
      'observacoes': pedido.observacoes,
      'status': pedido.status,
    });

    await fetchPedidos();
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    await supabase.from('pedidos').update({'status': novoStatus}).eq('id', id);

    final index = _pedidos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pedidos[index] = _pedidos[index].copyWith(status: novoStatus);
      notifyListeners();
    }
  }
}
