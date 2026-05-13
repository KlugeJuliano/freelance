import 'package:flutter/foundation.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/services/supabase_client.dart';

class PedidoProvider extends ChangeNotifier {
  List<PedidoModel> _pedidos = [];
  bool _loading = false;
  String? _erro;
  String? _empresaId;

  List<PedidoModel> get pedidos => _pedidos;
  bool get loading => _loading;
  String? get erro => _erro;

  List<PedidoModel> get pedidosPendentes =>
      _pedidos.where((p) => p.status == 'solicitado').toList();

  void inicializar(String empresaId) {
    if (_empresaId == empresaId) return;
    _empresaId = empresaId;
    fetchPedidos();
  }

  Future<void> fetchPedidos() async {
    if (_empresaId == null) return;
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('pedidos')
          .select()
          .eq('empresa_id', _empresaId!)
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
    if (_empresaId == null) return false;
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('pedidos')
          .insert({
            'empresa_id': _empresaId,
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

      final novoPedido = PedidoModel.fromMap(data);
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
      await supabase
          .from('pedidos')
          .update({'status': novoStatus})
          .eq('id', id);

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

  void limpar() {
    _pedidos = [];
    _empresaId = null;
    notifyListeners();
  }
}
