class PagamentoModel {
  String id;
  String pedidoFreelancerId;
  double totalHoras;
  double valorHora;
  double valorTotal;
  String status;
  String? reciboNumero;
  DateTime? pagoEm;

  PagamentoModel({
    required this.id,
    required this.pedidoFreelancerId,
    required this.totalHoras,
    required this.valorHora,
    required this.valorTotal,
    required this.status,
    this.reciboNumero,
    this.pagoEm,
  });

  factory PagamentoModel.fromJson(Map<String, dynamic> json) {
    return PagamentoModel(
      id: json['id'],
      pedidoFreelancerId: json['pedido_freelancer_id'],
      totalHoras: double.tryParse(json['total_horas'].toString()) ?? 0,
      valorHora: double.tryParse(json['valor_hora'].toString()) ?? 0,
      valorTotal: double.tryParse(json['valor_total'].toString()) ?? 0,
      status: json['status'],
      reciboNumero: json['recibo_numero'],
      pagoEm: json['pago_em'] != null ? DateTime.parse(json['pago_em']) : null,
    );
  }
}
