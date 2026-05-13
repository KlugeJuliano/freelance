import 'package:freelance/models/freelancer_escalado_model.dart';
import 'package:freelance/services/supabase_client.dart';

class EscalacaoService {
  static const _tabela = 'pedido_escalacao';

  // Definido pelo EscalacaoProvider.inicializar() após o login
  static String? empresaId;

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
      'empresa_id': empresaId,
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

  static Future<void> finalizar(String pedidoId) async {
    await supabase
        .from('pedidos')
        .update({'status': 'escalado'})
        .eq('id', pedidoId);
  }
}
