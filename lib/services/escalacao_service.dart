import 'package:dio/dio.dart';
import 'package:freelance/services/api_services.dart';
import 'package:freelance/models/freelancer_escalado_model.dart';

class EscalacaoService {
  static Future<List<FreelancerEscaladoModel>> buscarEscalados(
    String pedidoId,
  ) async {
    final response = await ApiService.dio.get('/pedidos/$pedidoId/escalacao');

    // Adicione um print para ver a estrutura exata
    print('Response escalacao: ${response.data}');

    final List lista;

    if (response.data is List) {
      lista = response.data;
    } else if (response.data is Map && response.data['data'] != null) {
      lista = response.data['data'];
    } else {
      lista = [];
    }

    return lista.map((json) => FreelancerEscaladoModel.fromJson(json)).toList();
  }

  static Future<void> escalarFreelancer(
    String pedidoId,
    String freelancerId,
  ) async {
    try {
      await ApiService.dio.post(
        '/pedidos/$pedidoId/escalacao',
        data: {'freelancer_id': freelancerId},
      );
    } on DioException catch (e) {
      print('=== ERRO 422 ===');
      print('Status: ${e.response?.statusCode}');
      print('Body: ${e.response?.data}');
      rethrow;
    }
  }

  static Future<void> removerEscalado(
    String pedidoId,
    String freelancerId,
  ) async {
    await ApiService.dio.delete('/pedidos/$pedidoId/escalacao/$freelancerId');
  }

  static Future<void> finalizar(String pedidoId) async {
    await ApiService.dio.post('/pedidos/$pedidoId/escalacao/finalizar');
  }
}
