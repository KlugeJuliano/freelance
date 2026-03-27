class PessoaModel {
  final String id;
  final String empresaId;
  final String nome;
  final String? cpf;
  final String? telefone;
  final String? email;
  final String? chavePix;
  final List<String> funcaoIds;

  const PessoaModel({
    required this.id,
    required this.empresaId,
    required this.nome,
    this.cpf,
    this.telefone,
    this.email,
    this.chavePix,
    this.funcaoIds = const [],
    required String pessoaId,
  });

  // Alias para compatibilidade com as views existentes
  String get pessoaId => id;

  factory PessoaModel.fromMap(Map<String, dynamic> map) => PessoaModel(
    id: map['id'] ?? '',
    empresaId: map['empresa_id'] ?? '',
    nome: map['nome'],
    cpf: map['cpf'],
    telefone: map['telefone'],
    email: map['email'],
    chavePix: map['chave_pix'],
    funcaoIds: List<String>.from(map['funcao_ids'] ?? []),
    pessoaId: '',
  );
}
