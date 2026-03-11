// lib/models/pagamento_model.dart

class PagamentoModel {
  final String id;
  final String pedidoId;
  final String pessoaId;
  final double totalHoras;
  final double valorHora;
  final double valorTotal;
  final String status;
  final String? reciboNumero;
  final DateTime? pagoEm;

  PagamentoModel({
    required this.id,
    required this.pedidoId,
    required this.pessoaId,
    required this.totalHoras,
    required this.valorHora,
    required this.valorTotal,
    required this.status,
    this.reciboNumero,
    this.pagoEm,
  });

  factory PagamentoModel.fromMap(Map<String, dynamic> map) {
    return PagamentoModel(
      id: map['id'] as String,
      pedidoId: map['pedido_id'] as String,
      pessoaId: map['pessoa_id'] as String,
      totalHoras: double.tryParse(map['total_horas'].toString()) ?? 0,
      valorHora: double.tryParse(map['valor_hora'].toString()) ?? 0,
      valorTotal: double.tryParse(map['valor_total'].toString()) ?? 0,
      status: map['status'] as String,
      reciboNumero: map['recibo_numero'] as String?,
      pagoEm: map['pago_em'] != null
          ? DateTime.parse(map['pago_em'] as String)
          : null,
    );
  }

  PagamentoModel copyWith({
    String? status,
    String? reciboNumero,
    DateTime? pagoEm,
  }) {
    return PagamentoModel(
      id: id,
      pedidoId: pedidoId,
      pessoaId: pessoaId,
      totalHoras: totalHoras,
      valorHora: valorHora,
      valorTotal: valorTotal,
      status: status ?? this.status,
      reciboNumero: reciboNumero ?? this.reciboNumero,
      pagoEm: pagoEm ?? this.pagoEm,
    );
  }
}
