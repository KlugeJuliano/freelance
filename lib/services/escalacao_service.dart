// lib/services/escalacao_service.dart
//
// Substitui chamadas Dio/Laravel por queries diretas no Supabase.
// Tabela: pedido_escalacao
//   pedido_id    uuid FK pedidos
//   pessoa_id    uuid FK pessoas
//   status       text  ('escalado', 'confirmado', 'faltou', 'finalizado')
//   entrada_real timestamptz
//   saida_real   timestamptz
//   horas_trabalhadas numeric
//   valor_total  numeric

import 'package:freelance/models/freelancer_escalado_model.dart';
import 'package:freelance/services/supabase_client.dart';

class EscalacaoService {
  static const _tabela = 'pedido_escalacao';

  /// Retorna todos os escalados de um pedido com dados da pessoa (join).
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

  /// Escala uma pessoa para um pedido.
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

  /// Remove uma pessoa escalada de um pedido.
  static Future<void> removerEscalado(String pedidoId, String pessoaId) async {
    await supabase
        .from(_tabela)
        .delete()
        .eq('pedido_id', pedidoId)
        .eq('pessoa_id', pessoaId);
  }

  /// Marca o pedido como finalizado e atualiza status na tabela pedidos.
  static Future<void> finalizar(String pedidoId) async {
    await supabase
        .from('pedidos')
        .update({'status': 'finalizado'})
        .eq('id', pedidoId);
  }
}
