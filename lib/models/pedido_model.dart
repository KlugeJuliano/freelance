// lib/models/pedido_model.dart

class PedidoModel {
  final String id;
  final String lojaId;
  final String funcaoId;
  final String gerenteId;
  final int quantidade;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? observacoes;
  final String status;
  final DateTime dataCriacao;

  PedidoModel({
    required this.id,
    required this.lojaId,
    required this.funcaoId,
    required this.gerenteId,
    required this.quantidade,
    required this.dataInicio,
    required this.dataFim,
    this.observacoes,
    required this.status,
    required this.dataCriacao,
  });

  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    return PedidoModel(
      id: map['id'] as String,
      lojaId: map['loja_id'] as String,
      funcaoId: map['funcao_id'] as String,
      gerenteId: map['gerente_id'] as String,
      quantidade: map['quantidade'] as int,
      dataInicio: DateTime.parse(map['data_inicio'] as String),
      dataFim: DateTime.parse(map['data_fim'] as String),
      observacoes: map['observacoes'] as String?,
      status: map['status'] as String,
      dataCriacao: DateTime.parse(map['created_at'] as String),
    );
  }

  PedidoModel copyWith({String? status}) {
    return PedidoModel(
      id: id,
      lojaId: lojaId,
      funcaoId: funcaoId,
      gerenteId: gerenteId,
      quantidade: quantidade,
      dataInicio: dataInicio,
      dataFim: dataFim,
      observacoes: observacoes,
      status: status ?? this.status,
      dataCriacao: dataCriacao,
    );
  }
}
