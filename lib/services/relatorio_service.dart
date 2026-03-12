// lib/services/relatorio_service.dart

import 'package:freelance/services/supabase_client.dart';

class RelatorioService {
  /// Pedidos agrupados por status, com contagem.
  /// Retorna: [{ status, total }]
  static Future<List<Map<String, dynamic>>> pedidosPorStatus() async {
    final raw = await supabase.from('pedidos').select('status');

    final Map<String, int> agrupado = {};
    for (final row in raw as List) {
      final status = row['status'] as String? ?? 'desconhecido';
      agrupado[status] = (agrupado[status] ?? 0) + 1;
    }

    return agrupado.entries
        .map((e) => {'status': e.key, 'total': e.value})
        .toList()
      ..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
  }

  /// Pedidos agrupados por loja.
  /// Retorna: [{ nome, total_pedidos }]
  static Future<List<Map<String, dynamic>>> pedidosPorLoja({
    String? dataInicio,
    String? dataFim,
  }) async {
    var query = supabase.from('pedidos').select('lojas(nome), data_inicio');

    if (dataInicio != null) query = query.gte('data_inicio', dataInicio);
    if (dataFim != null) query = query.lte('data_inicio', dataFim);

    final raw = await query;

    final Map<String, int> agrupado = {};
    for (final row in raw as List) {
      final nome = row['lojas']?['nome'] as String? ?? 'Sem loja';
      agrupado[nome] = (agrupado[nome] ?? 0) + 1;
    }

    return agrupado.entries
        .map((e) => {'nome': e.key, 'total_pedidos': e.value})
        .toList()
      ..sort(
        (a, b) =>
            (b['total_pedidos'] as int).compareTo(a['total_pedidos'] as int),
      );
  }

  /// Pedidos agrupados por função.
  /// Retorna: [{ nome, total_pedidos }]
  static Future<List<Map<String, dynamic>>> pedidosPorFuncao({
    String? dataInicio,
    String? dataFim,
  }) async {
    var query = supabase.from('pedidos').select('funcoes(nome), data_inicio');

    if (dataInicio != null) query = query.gte('data_inicio', dataInicio);
    if (dataFim != null) query = query.lte('data_inicio', dataFim);

    final raw = await query;

    final Map<String, int> agrupado = {};
    for (final row in raw as List) {
      final nome = row['funcoes']?['nome'] as String? ?? 'Sem função';
      agrupado[nome] = (agrupado[nome] ?? 0) + 1;
    }

    return agrupado.entries
        .map((e) => {'nome': e.key, 'total_pedidos': e.value})
        .toList()
      ..sort(
        (a, b) =>
            (b['total_pedidos'] as int).compareTo(a['total_pedidos'] as int),
      );
  }

  /// Custos agrupados por loja (via pagamentos).
  /// Retorna: [{ nome, total_horas, total_valor }]
  static Future<List<Map<String, dynamic>>> custosPorLoja({
    String? dataInicio,
    String? dataFim,
  }) async {
    final raw = await supabase
        .from('pagamentos')
        .select('total_horas, valor_total, pedidos(data_inicio, lojas(nome))');

    final Map<String, Map<String, dynamic>> agrupado = {};
    for (final row in raw as List) {
      final dataRow = row['pedidos']?['data_inicio'] as String?;
      if (dataInicio != null &&
          dataRow != null &&
          dataRow.compareTo(dataInicio) < 0) {
        continue;
      }
      if (dataFim != null &&
          dataRow != null &&
          dataRow.compareTo(dataFim) > 0) {
        continue;
      }

      final nome = row['pedidos']?['lojas']?['nome'] as String? ?? 'Sem loja';
      agrupado.putIfAbsent(
        nome,
        () => {'nome': nome, 'total_horas': 0.0, 'total_valor': 0.0},
      );
      agrupado[nome]!['total_horas'] += (row['total_horas'] ?? 0).toDouble();
      agrupado[nome]!['total_valor'] += (row['valor_total'] ?? 0).toDouble();
    }

    return agrupado.values.toList()..sort(
      (a, b) =>
          (b['total_valor'] as double).compareTo(a['total_valor'] as double),
    );
  }

  /// Custos agrupados por função (via pagamentos + pedido).
  /// Retorna: [{ nome, total_horas, total_valor }]
  static Future<List<Map<String, dynamic>>> custosPorFuncao({
    String? dataInicio,
    String? dataFim,
  }) async {
    final raw = await supabase
        .from('pagamentos')
        .select(
          'total_horas, valor_total, pedidos(data_inicio, funcoes(nome))',
        );

    final Map<String, Map<String, dynamic>> agrupado = {};
    for (final row in raw as List) {
      final dataRow = row['pedidos']?['data_inicio'] as String?;
      if (dataInicio != null &&
          dataRow != null &&
          dataRow.compareTo(dataInicio) < 0) {
        continue;
      }
      if (dataFim != null &&
          dataRow != null &&
          dataRow.compareTo(dataFim) > 0) {
        continue;
      }

      final nome =
          row['pedidos']?['funcoes']?['nome'] as String? ?? 'Sem função';
      agrupado.putIfAbsent(
        nome,
        () => {'nome': nome, 'total_horas': 0.0, 'total_valor': 0.0},
      );
      agrupado[nome]!['total_horas'] += (row['total_horas'] ?? 0).toDouble();
      agrupado[nome]!['total_valor'] += (row['valor_total'] ?? 0).toDouble();
    }

    return agrupado.values.toList()..sort(
      (a, b) =>
          (b['total_valor'] as double).compareTo(a['total_valor'] as double),
    );
  }

  /// Evolução mensal de custos totais.
  /// Retorna: [{ mes, total_valor }] ordenado cronologicamente.
  static Future<List<Map<String, dynamic>>> evolucaoMensal({
    String? dataInicio,
    String? dataFim,
  }) async {
    final raw = await supabase
        .from('pagamentos')
        .select('valor_total, created_at');

    final Map<String, double> agrupado = {};
    for (final row in raw as List) {
      final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
      if (createdAt == null) continue;

      final mes =
          '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
      if (dataInicio != null && mes.compareTo(dataInicio.substring(0, 7)) < 0) {
        continue;
      }
      if (dataFim != null && mes.compareTo(dataFim.substring(0, 7)) > 0) {
        continue;
      }

      agrupado[mes] =
          (agrupado[mes] ?? 0.0) + (row['valor_total'] ?? 0).toDouble();
    }

    return agrupado.entries
        .map((e) => {'mes': e.key, 'total_valor': e.value})
        .toList()
      ..sort((a, b) => (a['mes'] as String).compareTo(b['mes'] as String));
  }
}
