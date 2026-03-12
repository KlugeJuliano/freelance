// lib/providers/pedido_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/services/supabase_client.dart';

class PedidoProvider extends ChangeNotifier {
  List<PedidoModel> _pedidos = [];
  bool _loading = false;
  String? _erro;

  List<PedidoModel> get pedidos => _pedidos;
  bool get loading => _loading;
  String? get erro => _erro;

  List<PedidoModel> get pedidosPendentes =>
      _pedidos.where((p) => p.status == 'solicitado').toList();

  Future<void> fetchPedidos() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('pedidos')
          .select()
          .order('created_at', ascending: false);

      _pedidos = (data as List)
          .map((row) => PedidoModel.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _erro = 'Erro ao carregar pedidos: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> adicionarPedido(PedidoModel pedido) async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('pedidos')
          .insert({
            'loja_id': pedido.lojaId,
            'funcao_id': pedido.funcaoId,
            'gerente_id': pedido.gerenteId,
            'quantidade': pedido.quantidade,
            'data_inicio': pedido.dataInicio.toIso8601String(),
            'data_fim': pedido.dataFim.toIso8601String(),
            'observacoes': pedido.observacoes,
            'status': pedido.status,
          })
          .select()
          .single();

      final novoPedido = PedidoModel.fromMap(data as Map<String, dynamic>);
      _pedidos.insert(0, novoPedido);
      return true;
    } catch (e) {
      _erro = 'Erro ao adicionar pedido: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarStatus(String id, String novoStatus) async {
    _erro = null;
    try {
      await supabase.from('pedidos').update({'status': novoStatus}).eq('id', id);

      final index = _pedidos.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pedidos[index] = _pedidos[index].copyWith(status: novoStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _erro = 'Erro ao atualizar status: $e';
      return false;
    }
  }
}
