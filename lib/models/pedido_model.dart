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
}
