class FreelancerEscaladoModel {
  String freelancerId;
  String nome;
  String? cpf;
  String status;
  DateTime? entradaReal;
  DateTime? saidaReal;
  double? horasTrabalhadas;
  double? valorTotal;

  FreelancerEscaladoModel({
    required this.freelancerId,
    required this.nome,
    this.cpf,
    required this.status,
    this.entradaReal,
    this.saidaReal,
    this.horasTrabalhadas,
    this.valorTotal,
  });

  factory FreelancerEscaladoModel.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] as Map<String, dynamic>? ?? {};
    return FreelancerEscaladoModel(
      freelancerId: json['id'],
      nome: json['nome'],
      cpf: json['cpf'],
      status: pivot['status'] ?? 'escalado',
      entradaReal: pivot['entrada_real'] != null
          ? DateTime.parse(pivot['entrada_real'])
          : null,
      saidaReal: pivot['saida_real'] != null
          ? DateTime.parse(pivot['saida_real'])
          : null,
      horasTrabalhadas: pivot['horas_trabalhadas'] != null
          ? double.tryParse(pivot['horas_trabalhadas'].toString())
          : null,
      valorTotal: pivot['valor_total'] != null
          ? double.tryParse(pivot['valor_total'].toString())
          : null,
    );
  }
}
