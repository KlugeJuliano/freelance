class PessoaNoPedidoModel {
  String pessoaId;
  String nome;
  String funcao;
  String? status;

  PessoaNoPedidoModel({
    required this.pessoaId,
    required this.nome,
    required this.funcao,
    this.status,
  });

  factory PessoaNoPedidoModel.fromJson(Map<String, dynamic> json) {
    return PessoaNoPedidoModel(
      pessoaId: json['id'] ?? '',
      nome: json['nome'] ?? '',
      funcao: json['pivot']?['funcao'] ?? '',
      status: json['pivot']?['status'],
    );
  }
}
