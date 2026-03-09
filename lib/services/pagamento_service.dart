import 'package:freelance/models/pagamento_model.dart';
import 'package:freelance/services/api_services.dart';

class PagamentoService {
  static Future<List<PagamentoModel>> buscarPagamentos(String pedidoId) async {
    final response = await ApiService.dio.get('/pedidos/$pedidoId/pagamentos');
    return (response.data as List)
        .map((json) => PagamentoModel.fromJson(json))
        .toList();
  }

  static Future<void> registrarHoras({
    required String pedidoId,
    required String freelancerId,
    required DateTime entradaReal,
    required DateTime saidaReal,
  }) async {
    await ApiService.dio.post(
      '/pedidos/$pedidoId/horas',
      data: {
        'freelancer_id': freelancerId,
        'entrada_real': entradaReal.toIso8601String(),
        'saida_real': saidaReal.toIso8601String(),
      },
    );
  }

  static Future<void> fecharPagamentos(String pedidoId) async {
    await ApiService.dio.post('/pedidos/$pedidoId/pagamentos/fechar');
  }

  static Future<void> pagar(String pagamentoId) async {
    await ApiService.dio.patch('/pagamentos/$pagamentoId/pagar');
  }
}
