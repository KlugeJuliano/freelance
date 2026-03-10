class PessoaModel {
  String pessoaId;
  String nome;
  String? cpf;
  String? telefone;
  String? email;
  String? chavePix;
  List<String> funcaoIds;
  bool ativo; // <-- adicionar

  PessoaModel({
    required this.pessoaId,
    required this.nome,
    this.cpf,
    this.telefone,
    this.email,
    this.chavePix,
    this.funcaoIds = const [],
    this.ativo = true, // <-- default true
  });

  factory PessoaModel.fromJson(Map<String, dynamic> json) {
    return PessoaModel(
      pessoaId: json['id'],
      nome: json['nome'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      email: json['email'],
      chavePix: json['chave_pix'],
      ativo: json['ativo'] ?? true, // <-- adicionar
      funcaoIds:
          (json['funcoes'] as List?)?.map((f) => f['id'].toString()).toList() ??
          [],
    );
  }
}
