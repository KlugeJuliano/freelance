// lib/services/pagamento_service.dart
//
// Substitui chamadas Dio/Laravel por queries Supabase.
// Tabela: pagamentos
//   id            uuid PK
//   pedido_id     uuid FK pedidos
//   pessoa_id     uuid FK pessoas
//   total_horas   numeric
//   valor_hora    numeric
//   valor_total   numeric (gerado automaticamente via trigger ou calculado aqui)
//   status        text ('pendente', 'pago')
//   recibo_numero text
//   pago_em       timestamptz
//   created_at    timestamptz

import 'package:freelance/models/pagamento_model.dart';
import 'package:freelance/services/supabase_client.dart';

class PagamentoService {
  static const _tabela = 'pagamentos';

  /// Busca pagamentos de um pedido.
  static Future<List<PagamentoModel>> buscarPagamentos(String pedidoId) async {
    final data = await supabase
        .from(_tabela)
        .select()
        .eq('pedido_id', pedidoId)
        .order('created_at');

    return (data as List).map((row) => PagamentoModel.fromMap(row)).toList();
  }

  /// Registra horas trabalhadas e cria/atualiza o pagamento.
  static Future<void> registrarHoras({
    required String pedidoId,
    required String pessoaId,
    required DateTime entradaReal,
    required DateTime saidaReal,
    required double valorHora,
  }) async {
    final totalHoras = saidaReal.difference(entradaReal).inMinutes / 60.0;
    final valorTotal = totalHoras * valorHora;

    // Atualiza a escalação com os horários reais
    await supabase
        .from('pedido_escalacao')
        .update({
          'entrada_real': entradaReal.toIso8601String(),
          'saida_real': saidaReal.toIso8601String(),
          'horas_trabalhadas': totalHoras,
          'valor_total': valorTotal,
          'status': 'finalizado',
        })
        .eq('pedido_id', pedidoId)
        .eq('pessoa_id', pessoaId);

    // Cria ou atualiza o registro de pagamento
    await supabase.from(_tabela).upsert({
      'pedido_id': pedidoId,
      'pessoa_id': pessoaId,
      'total_horas': totalHoras,
      'valor_hora': valorHora,
      'valor_total': valorTotal,
      'status': 'pendente',
    });
  }

  /// Fecha todos os pagamentos de um pedido (marca como prontos para pagar).
  static Future<void> fecharPagamentos(String pedidoId) async {
    await supabase
        .from(_tabela)
        .update({'status': 'fechado'})
        .eq('pedido_id', pedidoId)
        .eq('status', 'pendente');
  }

  /// Marca um pagamento individual como pago.
  static Future<void> pagar(String pagamentoId) async {
    await supabase
        .from(_tabela)
        .update({'status': 'pago', 'pago_em': DateTime.now().toIso8601String()})
        .eq('id', pagamentoId);
  }
}
