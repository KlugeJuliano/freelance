// lib/models/freelancer_escalado_model.dart

class FreelancerEscaladoModel {
  final String pessoaId;
  final String nome;
  final String? cpf;
  final String status;
  final DateTime? entradaReal;
  final DateTime? saidaReal;
  final double? horasTrabalhadas;
  final double? valorTotal;

  FreelancerEscaladoModel({
    required this.pessoaId,
    required this.nome,
    this.cpf,
    required this.status,
    this.entradaReal,
    this.saidaReal,
    this.horasTrabalhadas,
    this.valorTotal,
  });

  factory FreelancerEscaladoModel.fromMap(Map<String, dynamic> map) {
    // O Supabase retorna join achatado — sem 'pivot'
    // Esperamos: pessoas.id, pessoas.nome, pessoas.cpf + campos da escalacao
    return FreelancerEscaladoModel(
      pessoaId: map['pessoa_id'] as String,
      nome: map['pessoas']?['nome'] as String? ?? map['nome'] as String? ?? '',
      cpf: map['pessoas']?['cpf'] as String?,
      status: map['status'] as String? ?? 'escalado',
      entradaReal: map['entrada_real'] != null
          ? DateTime.parse(map['entrada_real'] as String)
          : null,
      saidaReal: map['saida_real'] != null
          ? DateTime.parse(map['saida_real'] as String)
          : null,
      horasTrabalhadas: map['horas_trabalhadas'] != null
          ? double.tryParse(map['horas_trabalhadas'].toString())
          : null,
      valorTotal: map['valor_total'] != null
          ? double.tryParse(map['valor_total'].toString())
          : null,
    );
  }

  FreelancerEscaladoModel copyWith({String? status}) {
    return FreelancerEscaladoModel(
      pessoaId: pessoaId,
      nome: nome,
      cpf: cpf,
      status: status ?? this.status,
      entradaReal: entradaReal,
      saidaReal: saidaReal,
      horasTrabalhadas: horasTrabalhadas,
      valorTotal: valorTotal,
    );
  }
}
