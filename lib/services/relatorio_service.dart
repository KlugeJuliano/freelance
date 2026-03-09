import 'package:freelance/services/api_services.dart';

class RelatorioService {
  static Future<List<dynamic>> gastosPorLoja({
    String? dataInicio,
    String? dataFim,
  }) async {
    final response = await ApiService.dio.get(
      '/relatorios/gastos-por-loja',
      queryParameters: {
        if (dataInicio != null) 'data_inicio': dataInicio,
        if (dataFim != null) 'data_fim': dataFim,
      },
    );
    return response.data;
  }

  static Future<List<dynamic>> gastosPorFuncao({
    String? dataInicio,
    String? dataFim,
  }) async {
    final response = await ApiService.dio.get(
      '/relatorios/gastos-por-funcao',
      queryParameters: {
        if (dataInicio != null) 'data_inicio': dataInicio,
        if (dataFim != null) 'data_fim': dataFim,
      },
    );
    return response.data;
  }

  static Future<List<dynamic>> gastosPorGerente({
    String? dataInicio,
    String? dataFim,
  }) async {
    final response = await ApiService.dio.get(
      '/relatorios/gastos-por-gerente',
      queryParameters: {
        if (dataInicio != null) 'data_inicio': dataInicio,
        if (dataFim != null) 'data_fim': dataFim,
      },
    );
    return response.data;
  }

  static Future<List<dynamic>> gastosPorFreelancer({
    String? dataInicio,
    String? dataFim,
  }) async {
    final response = await ApiService.dio.get(
      '/relatorios/gastos-por-freelancer',
      queryParameters: {
        if (dataInicio != null) 'data_inicio': dataInicio,
        if (dataFim != null) 'data_fim': dataFim,
      },
    );
    return response.data;
  }

  static Future<List<dynamic>> evolucaoCustosLoja() async {
    final response = await ApiService.dio.get(
      '/relatorios/evolucao-custos-loja',
    );
    return response.data;
  }
}
