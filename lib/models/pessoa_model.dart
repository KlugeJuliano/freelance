// lib/models/pessoa_model.dart

class PessoaModel {
  final String pessoaId;
  final String nome;
  final String? cpf;
  final String? telefone;
  final String? email;
  final String? chavePix;
  final List<String> funcaoIds;
  final bool ativo;

  PessoaModel({
    required this.pessoaId,
    required this.nome,
    this.cpf,
    this.telefone,
    this.email,
    this.chavePix,
    this.funcaoIds = const [],
    this.ativo = true,
  });

  factory PessoaModel.fromMap(Map<String, dynamic> map) {
    return PessoaModel(
      pessoaId: map['id'] as String,
      nome: map['nome'] as String,
      cpf: map['cpf'] as String?,
      telefone: map['telefone'] as String?,
      email: map['email'] as String?,
      chavePix: map['chave_pix'] as String?,
      ativo: map['ativo'] as bool? ?? true,
      // Supabase retorna join como: pessoa_funcao: [{ funcao_id: '...' }]
      funcaoIds:
          (map['pessoa_funcao'] as List?)
              ?.map((f) => f['funcao_id'].toString())
              .toList() ??
          [],
    );
  }

  PessoaModel copyWith({bool? ativo}) {
    return PessoaModel(
      pessoaId: pessoaId,
      nome: nome,
      cpf: cpf,
      telefone: telefone,
      email: email,
      chavePix: chavePix,
      funcaoIds: funcaoIds,
      ativo: ativo ?? this.ativo,
    );
  }
}
