import 'package:freelance/models/pessoa_no_pedido.dart';

class PedidoModel {
  String id;
  String lojaId;
  String gerenteId;
  DateTime dataInicio;
  DateTime dataFim;
  String funcaoId;
  int quantidade;
  String observacoes;
  String status;
  DateTime dataCriacao;
  List<PessoaNoPedidoModel> pessoas;

  PedidoModel({
    required this.id,
    required this.lojaId,
    required this.gerenteId,
    required this.dataInicio,
    required this.dataFim,
    required this.funcaoId,
    required this.quantidade,
    required this.observacoes,
    required this.status,
    required this.dataCriacao,
    List<PessoaNoPedidoModel>? pessoas,
  }) : pessoas = pessoas ?? [];

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'],
      lojaId: json['loja_id'],
      gerenteId: json['gerente_id'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      funcaoId: json['funcao_id'],
      quantidade: json['quantidade'],
      observacoes: json['observacoes'] ?? '',
      status: json['status'],
      dataCriacao: DateTime.parse(json['created_at']),
      pessoas: (json['freelancers'] as List?)
          ?.map((f) => PessoaNoPedidoModel.fromJson(f))
          .toList(),
    );
  }
}
