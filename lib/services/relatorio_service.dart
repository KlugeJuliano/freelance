// lib/services/relatorio_service.dart
//
// Substitui chamadas Dio/Laravel por queries diretas no Supabase.
// Os campos retornados são compatíveis com RelatoriosConsolidadosView:
//   nome, total_pedidos, total_horas, total_valor, valor_hora (por função)
//   mes, total_valor (evolução)

import 'package:freelance/services/supabase_client.dart';

class RelatorioService {
  /// Gastos agrupados por loja.
  /// Retorna: [{ nome, total_pedidos, total_horas, total_valor }]
  static Future<List<dynamic>> gastosPorLoja({
    String? dataInicio,
    String? dataFim,
  }) async {
    var query = supabase
        .from('pagamentos')
        .select('pedidos(loja), total_horas, valor_total');

    final raw = await query;

    // Agrupamento em memória
    final Map<String, Map<String, dynamic>> agrupado = {};
    for (final row in raw as List) {
      final loja = row['pedidos']?['loja'] as String? ?? 'Sem loja';
      agrupado.putIfAbsent(
        loja,
        () => {
          'nome': loja,
          'total_pedidos': 0,
          'total_horas': 0.0,
          'total_valor': 0.0,
        },
      );
      agrupado[loja]!['total_pedidos'] += 1;
      agrupado[loja]!['total_horas'] += (row['total_horas'] ?? 0).toDouble();
      agrupado[loja]!['total_valor'] += (row['valor_total'] ?? 0).toDouble();
    }

    return agrupado.values.toList()..sort(
      (a, b) =>
          (b['total_valor'] as double).compareTo(a['total_valor'] as double),
    );
  }

  /// Gastos agrupados por função.
  /// Retorna: [{ nome, total_pedidos, total_horas, total_valor, valor_hora }]
  static Future<List<dynamic>> gastosPorFuncao({
    String? dataInicio,
    String? dataFim,
  }) async {
    final raw = await supabase
        .from('pagamentos')
        .select(
          'valor_hora, total_horas, valor_total, pessoas(pessoa_funcao(funcoes(nome)))',
        );

    final Map<String, Map<String, dynamic>> agrupado = {};
    for (final row in raw as List) {
      final funcoes = (row['pessoas']?['pessoa_funcao'] as List?) ?? [];
      final nomeFuncao = funcoes.isNotEmpty
          ? funcoes.first['funcoes']
                ? ['nome'] as String? ?? 'Sem função'
                : 'Sem função'
          : funcoes.first['funcoes']?['nome'] as String? ?? 'Sem função';

      agrupado.putIfAbsent(
        nomeFuncao,
        () => {
          'nome': nomeFuncao,
          'total_pedidos': 0,
          'total_horas': 0.0,
          'total_valor': 0.0,
          'valor_hora': (row['valor_hora'] ?? 0).toDouble(),
        },
      );
      agrupado[nomeFuncao]!['total_pedidos'] += 1;
      agrupado[nomeFuncao]!['total_horas'] += (row['total_horas'] ?? 0)
          .toDouble();
      agrupado[nomeFuncao]!['total_valor'] += (row['valor_total'] ?? 0)
          .toDouble();
    }

    return agrupado.values.toList()..sort(
      (a, b) =>
          (b['total_valor'] as double).compareTo(a['total_valor'] as double),
    );
  }

  /// Gastos agrupados por gerente (quem criou o pedido).
  /// Retorna: [{ nome, total_pedidos, total_horas, total_valor }]
  static Future<List<dynamic>> gastosPorGerente({
    String? dataInicio,
    String? dataFim,
  }) async {
    final raw = await supabase
        .from('pagamentos')
        .select('total_horas, valor_total, pedidos(criado_por, pessoas(nome))');

    final Map<String, Map<String, dynamic>> agrupado = {};
    for (final row in raw as List) {
      final nome =
          row['pedidos']?['pessoas']?['nome'] as String? ?? 'Desconhecido';
      agrupado.putIfAbsent(
        nome,
        () => {
          'nome': nome,
          'total_pedidos': 0,
          'total_horas': 0.0,
          'total_valor': 0.0,
        },
      );
      agrupado[nome]!['total_pedidos'] += 1;
      agrupado[nome]!['total_horas'] += (row['total_horas'] ?? 0).toDouble();
      agrupado[nome]!['total_valor'] += (row['valor_total'] ?? 0).toDouble();
    }

    return agrupado.values.toList()..sort(
      (a, b) =>
          (b['total_valor'] as double).compareTo(a['total_valor'] as double),
    );
  }

  /// Gastos agrupados por freelancer.
  /// Retorna: [{ nome, total_pedidos, total_horas, total_valor }]
  static Future<List<dynamic>> gastosPorFreelancer({
    String? dataInicio,
    String? dataFim,
  }) async {
    final raw = await supabase
        .from('pagamentos')
        .select('total_horas, valor_total, pessoas(nome)');

    final Map<String, Map<String, dynamic>> agrupado = {};
    for (final row in raw as List) {
      final nome = row['pessoas']?['nome'] as String? ?? 'Desconhecido';
      agrupado.putIfAbsent(
        nome,
        () => {
          'nome': nome,
          'total_pedidos': 0,
          'total_horas': 0.0,
          'total_valor': 0.0,
        },
      );
      agrupado[nome]!['total_pedidos'] += 1;
      agrupado[nome]!['total_horas'] += (row['total_horas'] ?? 0).toDouble();
      agrupado[nome]!['total_valor'] += (row['valor_total'] ?? 0).toDouble();
    }

    return agrupado.values.toList()..sort(
      (a, b) =>
          (b['total_valor'] as double).compareTo(a['total_valor'] as double),
    );
  }

  /// Evolução de custos por loja ao longo do tempo.
  /// Retorna: [{ nome, mes, total_valor }]
  static Future<List<dynamic>> evolucaoCustosLoja() async {
    final raw = await supabase
        .from('pagamentos')
        .select('valor_total, created_at, pedidos(loja)');

    final List<Map<String, dynamic>> resultado = [];
    for (final row in raw as List) {
      final loja = row['pedidos']?['loja'] as String? ?? 'Sem loja';
      final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
      final mes = createdAt != null
          ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}'
          : 'Desconhecido';

      resultado.add({
        'nome': loja,
        'mes': mes,
        'total_valor': (row['valor_total'] ?? 0).toDouble(),
      });
    }

    resultado.sort((a, b) {
      final lojaComp = (a['nome'] as String).compareTo(b['nome'] as String);
      if (lojaComp != 0) return lojaComp;
      return (a['mes'] as String).compareTo(b['mes'] as String);
    });

    return resultado;
  }
}
