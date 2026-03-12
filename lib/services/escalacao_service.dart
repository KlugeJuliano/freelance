// lib/services/escalacao_service.dart

import 'package:freelance/models/freelancer_escalado_model.dart';
import 'package:freelance/services/supabase_client.dart';

class EscalacaoService {
  static const _tabela = 'pedido_escalacao';

  static Future<List<FreelancerEscaladoModel>> buscarEscalados(
    String pedidoId,
  ) async {
    final data = await supabase
        .from(_tabela)
        .select('*, pessoas(nome, cpf)')
        .eq('pedido_id', pedidoId);

    return (data as List)
        .map((row) => FreelancerEscaladoModel.fromMap(row))
        .toList();
  }

  static Future<void> escalarFreelancer(
    String pedidoId,
    String pessoaId,
  ) async {
    await supabase.from(_tabela).upsert({
      'pedido_id': pedidoId,
      'pessoa_id': pessoaId,
      'status': 'escalado',
    });
  }

  static Future<void> removerEscalado(String pedidoId, String pessoaId) async {
    await supabase
        .from(_tabela)
        .delete()
        .eq('pedido_id', pedidoId)
        .eq('pessoa_id', pessoaId);
  }

  /// Finaliza a escalação — muda o pedido para 'escalado'
  /// para que o gerente possa aprovar ou recusar.
  static Future<void> finalizar(String pedidoId) async {
    await supabase
        .from('pedidos')
        .update({'status': 'escalado'})
        .eq('id', pedidoId);
  }
}
